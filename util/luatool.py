#!/usr/bin/env python2
#
# ESP8266 luatool
# Author e-mail: 4ref0nt@gmail.com
# Site: http://esp8266.ru
# Contributions from: https://github.com/sej7278
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301 USA.

import sys
import serial
from time import sleep
import socket
import argparse
from os.path import basename


version = "0.6.4"


class TransportError(Exception):
    """Custom exception to represent errors with a transport
    """
    def __init__(self, message):
        self.message = message


class AbstractTransport:
    def __init__(self):
        raise NotImplementedError('abstract transports cannot be instantiated.')

    def close(self):
        raise NotImplementedError('Function not implemented')

    def read(self, length):
        raise NotImplementedError('Function not implemented')

    def writeln(self, data, check=1):
        raise NotImplementedError('Function not implemented')

    def writer(self, data):
        self.writeln("file.writeline([==[" + data + "]==])\r")

    def performcheck(self, expected):
        line = ''
        char = ''
        i = -1
        while char != chr(62):  # '>'
            char = self.read(1)
            if char == '':
                raise Exception('No proper answer from MCU')
            if char == chr(13) or char == chr(10):  # LF or CR
                if line != '':
                    line = line.strip()
                    if line+'\r' == expected:
                        sys.stdout.write(" -> ok")
                    elif line+'\r' != expected:
                        if line[:4] == "lua:":
                            sys.stdout.write("\r\n\r\nLua ERROR: %s" % line)
                            raise Exception('ERROR from Lua interpreter\r\n\r\n')
                        else:
                            expected = expected.split("\r")[0]
                            sys.stdout.write("\r\n\r\nERROR")
                            sys.stdout.write("\r\n send string    : '%s'" % expected)
                            sys.stdout.write("\r\n expected echo  : '%s'" % expected)
                            sys.stdout.write("\r\n but got answer : '%s'" % line)
                            sys.stdout.write("\r\n\r\n")
                            raise Exception('Error sending data to MCU\r\n\r\n')
                    line = ''
            else:
                line += char
                if char == chr(62) and expected[i] == char:
                    char = ''
                i += 1


class SerialTransport(AbstractTransport):
    def __init__(self, port, baud, delay):
        self.port = port
        self.baud = baud
        self.serial = None
        self.delay = delay

        try:
            self.serial = serial.Serial(port, baud)
        except serial.SerialException as e:
            raise TransportError(e.strerror)

        self.serial.timeout = 3
        self.serial.interCharTimeout = 3

    def writeln(self, data, check=1):
        if self.serial.inWaiting() > 0:
            self.serial.flushInput()
        if len(data) > 0:
            sys.stdout.write("\r\n->")
            sys.stdout.write(data.split("\r")[0])
        self.serial.write(data)
        sleep(self.delay)
        if check > 0:
            self.performcheck(data)
        else:
            sys.stdout.write(" -> send without check")

    def read(self, length):
        return self.serial.read(length)

    def close(self):
        self.serial.flush()
        self.serial.close()


class TcpSocketTransport(AbstractTransport):
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.socket = None

        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        except socket.error as e:
            raise TransportError(e.strerror)

        try:
            self.socket.connect((host, port))
        except socket.error as e:
            raise TransportError(e.strerror)
        # read intro from telnet server (see telnet_srv.lua)
        self.socket.recv(50)

    def writeln(self, data, check=1):
        if len(data) > 0:
            sys.stdout.write("\r\n->")
            sys.stdout.write(data.split("\r")[0])
        self.socket.sendall(data)
        if check > 0:
            self.performcheck(data)
        else:
            sys.stdout.write(" -> send without check")

    def read(self, length):
        return self.socket.recv(length)

    def close(self):
        self.socket.close()


    


if __name__ == '__main__':
    transport = SerialTransport("/dev/tty.wchusbserial1410", 115200, 0.3)
    transport.writeln("local l = file.list();for k,v in pairs(l) do print('name:'..k..', size:'..v)end\r", 0)
    while True:
        char = transport.read(1)
        if char == '' or char == chr(62):
            break
        sys.stdout.write(char)

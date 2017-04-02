import socket
import curses

UDP_IP = "192.168.178.117"
UDP_PORT = 4242

def send_command(command):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(bytes(command, "utf-8"), (UDP_IP, UDP_PORT))

stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
stdscr.addstr(0, 0, "Welcome to the robot control center",
              curses.A_REVERSE)
stdscr.refresh()

while 1:
    c = stdscr.getch()
    stdscr.addstr(20, 20, "%i" %c, curses.A_REVERSE)
    if c == ord('q'):
        break

    elif c == 260:
        send_command("turn_left")

    elif c == 261:
        send_command("turn_right")

    elif c == 258:
        send_command("backward")

    elif c == 259:
        send_command("forward")

    elif c == 32:
        send_command("stop")

    elif c == ord('m'):
        stdscr.addstr(10, 10, "sending message", curses.A_REVERSE)
        send_command("message hallo")

curses.endwin()

import socket
import curses
import threading
import time

stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)

STOP = "stop"
FORWARD = "forward"
BACKWARD = "backward"
TURN_RIGHT = "turn_right"
TURN_LEFT = "turn_left"


def send_command(command):
    UDP_IP = "192.168.178.117"
    UDP_PORT = 4242
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.sendto(bytes(command, "utf-8"), (UDP_IP, UDP_PORT))
    except OSError:
        clear_screen()
        stdscr.addstr(5, 0, "ERROR connecting to robot", curses.A_BOLD)



record_mode = False
command_stack = []

REVERSE_COMMANDS = {
    STOP: STOP,
    FORWARD: BACKWARD,
    BACKWARD: FORWARD,
    TURN_LEFT: TURN_RIGHT,
    TURN_RIGHT: TURN_LEFT
}


class Command:
    def __init__(self, name):
        self.name = name
        self.start = int(time.time() * 1000)
        self.end = None

    def run(self):
        send_command(self.name)

    def get_reverse_command(self):
        return REVERSE_COMMANDS[self.name]

    def run_reverse(self):
        send_command(self.get_reverse_command())


def read_message_from_terminal():
    string = ""
    while 1:
        c = stdscr.getch()
        if c == 10:
            break
        string += chr(c)
        stdscr.addstr(5, 0, "Message: " + string, curses.A_REVERSE)
    return string


def end_last_command():
    if len(command_stack) > 0:
        command_stack[len(command_stack)-1].end = int(time.time() * 1000)


def add_command_to_stack(command):
    if(record_mode):
        end_last_command()
        command_stack.append(command)


def replay_commands():
    stdscr.addstr(5, 5, "Replaying commands...", curses.A_REVERSE)
    stdscr.refresh()
    while len(command_stack) > 0:
        command = command_stack.pop()
        duration = command.end - command.start
        if duration == 0:
            duration = 1
        clear_screen()
        command.run_reverse()
        time.sleep(duration / 1000.0)
    stdscr.addstr(5, 6, "Done - All commands replayed", curses.A_REVERSE)
    stdscr.refresh


def clear_screen():
    stdscr.clear()
    stdscr.addstr(0, 0, "Robot control center # v3.133.7 # (c) robotlabls 2017", curses.A_REVERSE)
    r = "On" if record_mode else "Off"
    stdscr.addstr(1, 0, "record_mode=%s -- Send command" % record_mode, curses.A_BOLD)
    stdscr.refresh()


replay_thread = None

while 1:
    clear_screen()
    c = stdscr.getch()

    if c == ord('q'):
        break

    elif c == 260:
        command = Command(TURN_LEFT)
        add_command_to_stack(command)
        command.run()

    elif c == 261:
        command = Command(TURN_RIGHT)
        add_command_to_stack(command)
        command.run()

    elif c == 258:
        command = Command(BACKWARD)
        add_command_to_stack(command)
        command.run()

    elif c == 259:
        command = Command(FORWARD)
        add_command_to_stack(command)
        command.run()

    elif c == 32:
        command = Command(STOP)
        add_command_to_stack(command)
        command.run()

    elif c == ord('r'):
        stdscr.addstr(3, 0, "Record mode on", curses.A_REVERSE)
        stdscr.refresh()
        record_mode = True
        command_stack = []
        command_stack.append(Command(STOP))

    elif c == ord('p'):
        stdscr.addstr(3, 0, "Record mode off - Replaying commands", curses.A_REVERSE)
        stdscr.refresh()
        record_mode = False
        end_last_command()
        replay_thread = threading.Thread(target=replay_commands)
        replay_thread.start()

    elif c == ord('z'):
        stdscr.addstr(3, 0, "Reset record mode", curses.A_REVERSE)
        stdscr.refresh()
        time.sleep(1)
        record_mode = False
        command_stack = []

    elif c == ord('m'):
        stdscr.addstr(3, 0, "Enter message to send", curses.A_REVERSE)
        stdscr.refresh()
        message = read_message_from_terminal()
        if message:
            send_command("message " + message)
        clear_screen()

curses.endwin()

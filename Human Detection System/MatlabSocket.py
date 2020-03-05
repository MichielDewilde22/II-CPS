import sys
import socket
import threading
import time
import struct

UDP_IP = 'localhost'
UDP_PORT = 6969


class MatlabSocket:
    def __init__(self):
        self.sock = None
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.sock.bind((UDP_IP, UDP_PORT))
        except socket.error as msg:
            print("Problem opening UDP socket. Exiting...")
            sys.exit(0)

        self.stop_thread = 0
        self.listen_thread = threading.Thread(target=self.__listen__)

    def __del__(self):
        self.stop_thread = 1
        time.sleep(1)
        self.sock.close()

    def __listen__(self):
        while not self.stop_thread:
            data, addr = self.sock.recvfrom(1024)

            floats = struct.unpack('f', data)
            print(str(data))
            print(str(floats))



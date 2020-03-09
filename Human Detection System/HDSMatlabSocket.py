import sys
import socket
import threading
import time

# MATLABSOCKET is a class that creates a thread for receiving the angles that are being send through UDP by Matlab.

UDP_IP = "localhost"
UDP_PORT = 6969
STOP_SIGNAL_BYTES = str("stop").encode()


class HDSMatlabSocket:
    # Constructor method
    def __init__(self):
        self.sock = None
        self.listen_thread = None
        self.last_received_time = None
        self.horizontal_angle = None
        self.azimuth_angle = None
        self.new_data = 0

    # Destructor method
    def __del__(self):
        self.stop_listening()

    # Method for starting the listening thread
    def start_listening(self):
        if self.listen_thread is None:
            self.listen_thread = threading.Thread(target=self.__listen__)
        if not self.listen_thread.is_alive():
            self.listen_thread.start()

    # Method for stopping the listening thread
    def stop_listening(self):
        if self.sock is not None:
            self.sock.sendto(STOP_SIGNAL_BYTES, (UDP_IP, UDP_PORT))
            time.sleep(1)
        self.listen_thread = None

    # Method for checking if there is new data
    def is_new_data(self):
        return self.new_data

    # Method for getting the new data + time of arrival of the data
    def get_data(self):
        self.new_data = 0
        return self.horizontal_angle, self.azimuth_angle, self.last_received_time

    # Method for executing in thread for listening and parsing the data
    def __listen__(self):
        # 1: opening socket
        self.__open_socket__()

        # 2: listening until a stop signal is received
        print("Listen thread started.")
        stop_thread = 0
        while not stop_thread:
            data, addr = self.sock.recvfrom(1024)
            data_string = str(data)
            print("Data received: " + data_string)
            if data == STOP_SIGNAL_BYTES:
                stop_thread = 1
                print("Received stop signal")
            else:
                try:
                    # The received string has the following format: " b'<FLOAT_1>,<FLOAT_2>' "
                    # In this command we remove the first two and last characters and split the string into two
                    # substrings containing the two floats.
                    angles_str = data_string[2:len(data_string)-1].split(',')
                    self.horizontal_angle = float(angles_str[0])
                    self.azimuth_angle = float(angles_str[1])
                    self.last_received_time = time.time_ns()
                    self.new_data = 1

                except ValueError as msg:
                    print("Error in parsing string to floats: " + str(msg))
        print("Listen thread stopped.")

        # 3: closing socket
        self.sock.close()
        self.sock = None

    # Method for opening the socket
    def __open_socket__(self):
        if self.sock is not None:
            self.sock.close()
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.sock.bind((UDP_IP, UDP_PORT))
        except socket.error as msg:
            print("Problem opening UDP socket. Exiting..." + msg[0])
            sys.exit(0)

        print("Socket successfully opened.")


import cv2
import numpy as np
import time
import threading

H_MIN = 30
S_MIN = 0
V_MIN = 117
H_MAX = 38
S_MAX = 255
V_MAX = 255


class HDSVideoCapture:
    # Constructor method
    def __init__(self):
        self.cap = None
        self.capture_thread = None
        self.stop_thread = 0

    def __del__(self):
        self.stop_capture()

    # Method for starting the video capture thread
    def start_capture(self):
        if self.capture_thread is None:
            self.capture_thread = threading.Thread(target=self.__capture__)
        if not self.capture_thread.is_alive():
            self.capture_thread.start()

    # Method for stopping the video capture thread
    def stop_capture(self):
        if self.capture_thread is not None:
            self.stop_thread = 1
            time.sleep(2)
            self.capture_thread = None

    # Method for executing in thread for video capturing and processing data
    def __capture__(self):
        print("Capture thread started.")
        self.stop_thread = 0
        frame_number = 1

        cap = cv2.VideoCapture(0)

        while not self.stop_thread:
            # Capture frame by frame
            ret, frame = cap.read()

            # Operations on the frame come here
            hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

            lower = np.array([H_MIN, S_MIN, V_MIN])  # lower HSV boundaries
            upper = np.array([H_MAX, S_MAX, V_MAX])  # upper HSV boundaries

            # Threshold the HSV image to get only yellow colors
            mask = cv2.inRange(hsv, lower, upper)

            # Bitwise-AND mask and original image
            result = cv2.bitwise_and(frame, frame, mask=mask)

            # Display the resulting frame
            cv2.imshow('frame', frame)
            cv2.imshow('mask', mask)
            cv2.imshow('result', result)
            k = cv2.waitKey(5) & 0xFF
            # if cv2.waitKey(1) & 0xFF == ord('q'):
            if k == 27:
                break

            print("Processed frame: " + str(frame_number))
            frame_number = frame_number + 1

        cap.release()
        cv2.destroyAllWindows()
        print("Capture thread stopped.")

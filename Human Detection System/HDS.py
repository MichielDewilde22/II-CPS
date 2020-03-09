import HDSMatlabSocket
import HDSVideoCapture
import time

print("1: Test started")
matlab_socket = HDSMatlabSocket.HDSMatlabSocket()
video_capture = HDSVideoCapture.HDSVideoCapture()

matlab_socket.start_listening()
video_capture.start_capture()

print("2: Threads are started")
time.sleep(30)

print("3: stopping threads")
matlab_socket.stop_listening()
video_capture.stop_capture()
time.sleep(5)

print("4: Deleting classes")
matlab_socket.__del__()
video_capture.__del__()

print("5: Test done")


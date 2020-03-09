import MatlabSocket
import time


matlab = MatlabSocket.MatlabSocket()
print("1: TEST STARTED!")
matlab.start_listening()
time.sleep(60)
matlab.__del__()
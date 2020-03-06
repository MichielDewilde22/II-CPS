import MatlabSocket
import time

matlab = MatlabSocket.MatlabSocket()
print("1: TEST STARTED!")
matlab.start_listening()
time.sleep(5)

print("1: DOUBLE STOP TEST STARTED!")
matlab.stop_listening()
time.sleep(5)
matlab.stop_listening()
time.sleep(5)

print("1: DOUBLE START TEST STARTED!")
matlab.start_listening()
time.sleep(5)
matlab.start_listening()
time.sleep(5)


print("1: STOP DELETE TEST STARTED!")
matlab.stop_listening()
time.sleep(5)
matlab.__del__()

print("Test Done!")


import numpy as np
import cv2

cap = cv2.VideoCapture(0)
# Set horizontal resolution
# ret = cap.set(3,1280)
# Set vertical resolution
# ret = cap.set(4,720)
print("Resolution: ", cap.get(3), " x ", cap.get(4))

while(True):
    # Capture frame by frame
    ret, frame = cap.read()
    
    # Operations on the frame come here
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    
    # Define range of yellow in HSV (hue range is [0,179], saturation range is [0,255], and value range is [0,255])
    lower = np.array([30, 0, 117]) # 26 or 30   40, 0, 117
    upper = np.array([38, 255, 255]) # 42 or 38   57, 255, 255
    
    # Threshold the HSV image to get only yellow colors
    mask = cv2.inRange(hsv, lower, upper)
    
    # Bitwise-AND mask and original image
    result = cv2.bitwise_and(frame, frame, mask= mask)
    
    # Display the resulting frame
    cv2.imshow('frame', frame)
    cv2.imshow('mask', mask)
    cv2.imshow('result', result)
    k = cv2.waitKey(5) & 0xFF
    # if cv2.waitKey(1) & 0xFF == ord('q'):
    if k == 27:
        break
    
# When everything is done, release the capture
cap.release()
cv2.destroyAllWindows()
import HDSMatlabSocket
import HDSVideoCapture
import HDSAngleCalculator
import time
import argparse
import logging
import signal
import sys

print("HUMAN DETECTION SYSTEM STARTED")
stop = 0
matlab_socket = None
video_capture = None


###############################################
# 1) SIGNAL HANDLER
###############################################
def signal_handler(signal, frame):
    global stop, matlab_socket, video_capture
    print("You pressed ctrl^c. Exiting in three seconds...")
    stop = 1
    if matlab_socket is not None:
        matlab_socket.__del__()
    if video_capture is not None:
        video_capture.__del__()
    time.sleep(3)
    sys.exit(0)


# activating signal handler
signal.signal(signal.SIGINT, signal_handler)


###############################################
# 2) ARGUMENT PARSING
###############################################
parser = argparse.ArgumentParser()
parser.add_argument("--ipconfig", type=str,
                    help="The IP configuration of the application. Supported are: 'lab', 'Toon' & 'Michiel'. (default "
                         "configuration is 'Lab'.")
parser.add_argument("--logger", type=str,
                    help="Logger options: DEBUG, INFO, WARNING, ERROR, CRITICAL (default configuration is INFO).")

args = parser.parse_args()

# setup logger
logger = logging.getLogger()
handler = logging.StreamHandler(sys.stdout)
formatter = logging.Formatter('LOG %(levelname)s : %(message)s')
handler.setFormatter(formatter)

# parsing logger argument
if args.logger:
    log_str = str(args.logger)
    if log_str == "DEBUG":
        logger.setLevel(logging.DEBUG)
        handler.setLevel(logging.DEBUG)
        logger.addHandler(handler)
        logger.info("Logger configuration: DEBUG")
    elif log_str == "INFO":
        logger.setLevel(logging.INFO)
        handler.setLevel(logging.INFO)
        logger.addHandler(handler)
        logger.info("Logger configuration: INFO")
    elif log_str == "WARNING":
        logger.setLevel(logging.WARNING)
        handler.setLevel(logging.WARNING)
        logger.addHandler(handler)
    elif log_str == "ERROR":
        logger.setLevel(logging.ERROR)
        handler.setLevel(logging.ERROR)
        logger.addHandler(handler)
    elif log_str == "CRITICAL":
        logger.setLevel(logging.CRITICAL)
        handler.setLevel(logging.CRITICAL)
        logger.addHandler(handler)
    else:
        logger.setLevel(logging.INFO)
        handler.setLevel(logging.INFO)
        logger.addHandler(handler)
        logger.info("Logger configuration: INFO")
else:
    logger.setLevel(logging.INFO)
    handler.setLevel(logging.INFO)
    logger.addHandler(handler)
    logger.info("Logger configuration: INFO")


# parsing IP configuration argument
ip_address = "192.168.1.10"  # default IP address for lab
if args.ipconfig:
    ipconfig_str = str(args.ipconfig)
    if ipconfig_str == "Toon":
        ip_address = "192.168.69.10"
    elif ipconfig_str == "Michiel":
        ip_address = "192.168.1.10"

logger.info("IP Configuration: " + ip_address)

###############################################
# 3) INITIALIZING PARAMETERS
###############################################
matlab_socket = HDSMatlabSocket.HDSMatlabSocket(logger, ip_address, 6969)
video_capture = HDSVideoCapture.HDSVideoCapture(logger)
angle_calculator = HDSAngleCalculator.HDSAngleCalculator(logger)

###############################################
# 4) MAIN LOOP
###############################################
matlab_socket.start_listening()
video_capture.start_capture()
logger.info("Matlab Socket & Video Capture threads are started.")

logger.info("Starting main loop: ")
while 1:
    if matlab_socket.is_new_data():
        h_angle, v_angle, r_time = matlab_socket.get_data()
        h_pixel, v_pixel = angle_calculator.angle_to_pixel(h_angle, v_angle)
        msg_str = "CALCULATION: "
        logger.info(msg_str)
        msg_str = " - h angle = " + str(h_angle) + " , v angle = " + str(v_angle)
        logger.info(msg_str)
        msg_str = " - h pixel = " + str(h_pixel) + " , v pixel = " + str(v_pixel)
        logger.info(msg_str)

        # check if we can shoot this pixel

        # set fire signal to true or false

    else:
        time.sleep(0.010)

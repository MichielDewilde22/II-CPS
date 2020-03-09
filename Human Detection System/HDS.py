import HDSMatlabSocket
import HDSVideoCapture
import time
import argparse
import logging
import signal
import sys

print("HUMAN DETECTION SYSTEM STARTED")
stop = 0


###############################################
# 1) SIGNAL HANDLER
###############################################
def signal_handler(signal, frame):
    global stop
    print("You pressed ctrl^c.")
    stop = 1


# activating signal handler
signal.signal(signal.SIGINT, signal_handler)


###############################################
# 2) ARGUMENT PARSING
###############################################
parser = argparse.ArgumentParser()
parser.add_argument("--ipconfig", type=str,
                    help="The IP configuration of the application. Supported are: 'lab', 'Toon' & 'Michiel'. (default "
                         "configuration is 'Lab'.")
parser.add_argument("--logger", action="store_true",
                    help="Logger options: DEBUG, INFO, WARNING, ERROR, CRITICAL (default configuration is INFO).")

args = parser.parse_args()

# setup logger
logger = logging.getLogger()
handler = logging.StreamHandler(sys.stdout)
formatter = logging.Formatter('LOG: %(message)s')
handler.setFormatter(formatter)

# parsing logger argument
if args.logger:
    log_str = str(args.logger)
    if log_str == "DEBUG":
        logger.setLevel(logging.DEBUG)
        handler.setLevel(logging.DEBUG)
        logger.addHandler(handler)
    elif log_str == "INFO":
        logger.setLevel(logging.INFO)
        handler.setLevel(logging.INFO)
        logger.addHandler(handler)
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
else:
    logger.setLevel(logging.INFO)
    handler.setLevel(logging.INFO)
    logger.addHandler(handler)
logger.info("Logger configuration: " + str(logger.level))

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

###############################################
# 3) INITIALIZING PARAMETERS
###############################################

matlab_socket.start_listening()
video_capture.start_capture()

###############################################
# 4) MAIN LOOP
###############################################
matlab_socket.start_listening()
video_capture.start_capture()
logger.info("Matlab Socket & Video Capture threads are started")

time.sleep(60)

logger.info("Stopping threads")
matlab_socket.stop_listening()
video_capture.stop_capture()
time.sleep(5)

logger.info("Deleting classes")
matlab_socket.__del__()
video_capture.__del__()

print("Exiting...")

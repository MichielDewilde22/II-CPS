# import HDSVideoCapture
import logging
import math

# camera angle constants in degrees
HORIZONTAL_ANGLE_V1 = 53.50
VERTICAL_ANGLE_V1 = 41.41
HORIZONTAL_ANGLE_V2 = 62.2
VERTICAL_ANGLE_V2 = 48.8

# camera focal length in m
FOCAL_LENGTH_V1 = 0.0036
FOCAL_LENGTH_V2 = 0.00304

# camera sensor dimensions in m
SENSOR_WIDTH_V1 = 0.0037
SENSOR_HEIGHT_V1 = 0.00274
SENSOR_WIDTH_V2 = 0.00368
SENSOR_HEIGHT_V2 = 0.00376

# This Angle Calculator class translates camera pixel coordinates into two angles and vice versa.
# The two angles are measured perpendicular to the camera lens orientation. The first angle is the vertical angle. The
# second angle is the horizontal angle. Both angles are measured in degrees and angle zero corresponds to
# the centre pixel. We assume there is no lens distortion.
# We assume the following sign convention:
# - vertical positive = up
# - vertical negative = down
# - horizontal positive = right
# - horizontal negative = left
# We use the following pixel convention:
# - pixel (0,0) is located in the top left corner


class HDSAngleCalculator:
    # Constructor
    def __init__(self, camera_type, logger):
        self.logger = logger
        self.h_res = 720
        self.v_res = 480
        self.h_centre_pixel = self.h_res / 2
        self.v_centre_pixel = self.v_res / 2

        if camera_type == 2:
            # camera constants for camera version 2
            self.focal_length = FOCAL_LENGTH_V2
            self.sensor_width = SENSOR_WIDTH_V2
            self.sensor_height = SENSOR_HEIGHT_V2
            self.h_meters_pp = SENSOR_WIDTH_V2 / self.h_res  # meters per pixel
            self.v_meters_pp = SENSOR_HEIGHT_V2 / self.v_res

            # constants for old formula
            self.h_degrees_pp = HORIZONTAL_ANGLE_V2 / self.h_res
            self.v_degrees_pp = VERTICAL_ANGLE_V2 / self.v_res
        else:
            # camera constants for camera version 1
            self.focal_length = FOCAL_LENGTH_V1
            self.sensor_width = SENSOR_WIDTH_V1
            self.sensor_height = SENSOR_HEIGHT_V1
            self.h_meters_pp = SENSOR_WIDTH_V1 / self.h_res  # meters per pixel
            self.v_meters_pp = SENSOR_HEIGHT_V1 / self.v_res

            # constants for old formula
            self.h_degrees_pp = HORIZONTAL_ANGLE_V1 / self.h_res
            self.v_degrees_pp = VERTICAL_ANGLE_V1 / self.v_res

    def __del__(self):
        pass

    # Conversion formula for converting pixels to angles (see camera pinhole model)
    def pixel_to_angle(self, h_pixel, v_pixel):
        # calculation of pixel position on camera sensor
        h_pixel = h_pixel - self.h_centre_pixel
        v_pixel = v_pixel - self.v_centre_pixel
        h_pixel_pos = h_pixel * self.h_meters_pp
        v_pixel_pos = v_pixel * self.v_meters_pp

        # calculation of angle with focal length
        h_angle_rad = math.atan(h_pixel_pos / self.focal_length)
        v_angle_rad = math.atan(v_pixel_pos / self.focal_length) * (-1.0)
        h_angle = math.degrees(h_angle_rad)
        v_angle = math.degrees(v_angle_rad)

        return h_angle, v_angle

    # Conversion formula for converting angles to pixels (see camera pinhole model)
    def angle_to_pixel(self, h_angle, v_angle):
        # conversion of degrees to radians
        h_angle_rad = math.radians(h_angle)
        v_angle_rad = math.radians(v_angle * (-1.0))

        # calculation of angle converted to position of pixel position on camera sensor
        h_pixel_pos = self.focal_length * math.tan(h_angle_rad)
        v_pixel_pos = self.focal_length * math.tan(v_angle_rad)

        # converting position on sensor to pixel
        h_pixel = round(h_pixel_pos / self.h_meters_pp) + self.h_centre_pixel
        v_pixel = round(v_pixel_pos / self.v_meters_pp) + self.v_centre_pixel

        print("intermediate pixel result: h=" + str(h_pixel) + " , v=" + str(v_pixel))

        # if the pixel is out of bounds (larger/smaller than min/max resolution), we return -1
        if (h_pixel < 0) or (h_pixel > self.h_res):
            h_pixel = -1
        if (v_pixel < 0) or (v_pixel > self.v_res):
            v_pixel = -1

        return h_pixel, v_pixel

    # the 'old' linear pixel to angle conversion (faulty)
    def pixel_to_angle_old(self, h_pixel, v_pixel):
        h_angle = ((h_pixel - self.h_centre_pixel) * (-1.0)) * self.h_degrees_pp
        v_angle = (v_pixel - self.v_centre_pixel) * self.v_degrees_pp
        return h_angle, v_angle

    # the 'old' linear angle to pixel conversion (faulty)
    def angle_to_pixel_old(self, h_angle, v_angle):
        h_pixel = round(((h_angle / self.h_degrees_pp) * (-1.0)) + self.h_centre_pixel)
        v_pixel = round((v_angle / self.v_degrees_pp) + self.v_centre_pixel)
        if h_pixel < 0 or h_pixel > self.h_res:
            h_pixel = -1
        if v_pixel < 0 or v_pixel > self.v_res:
            v_pixel = -1
        return h_pixel, v_pixel

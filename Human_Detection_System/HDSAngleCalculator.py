import HDSVideoCapture
import logging

# camera angle constants
HORIZONTAL_ANGLE = 53.50
VERTICAL_ANGLE = 41.41


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
    def __init__(self, logger):
        self.logger = logger
        self.h_res = HDSVideoCapture.HORIZONTAL_RES
        self.v_res = HDSVideoCapture.VERTICAL_RES
        self.h_centre_pixel = self.h_res / 2
        self.v_centre_pixel = self.v_res / 2
        self.h_degrees_pp = HORIZONTAL_ANGLE / self.h_centre_pixel
        self.v_degrees_pp = VERTICAL_ANGLE / self.v_centre_pixel

    def __del__(self):
        pass

    def convert_pixel_to_angle(self, h_pixel, v_pixel):
        h_angle = ((h_pixel - self.h_centre_pixel) * (-1.0)) * self.h_degrees_pp
        v_angle = (v_pixel - self.v_centre_pixel) * self.v_degrees_pp
        return h_angle, v_angle

    def convert_angle_to_pixel(self, h_angle, v_angle):
        h_pixel = round(((h_angle / self.h_degrees_pp) * (-1.0)) + self.h_centre_pixel)
        v_pixel = round((v_angle / self.v_degrees_pp) + self.v_centre_pixel)
        if h_pixel < 0 or h_pixel > self.h_res:
            h_pixel = -1
        if v_pixel < 0 or v_pixel > self.v_res:
            v_pixel = -1
        return h_pixel, v_pixel

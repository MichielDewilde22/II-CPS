import HDSAngleCalculator

calculator = HDSAngleCalculator.HDSAngleCalculator(1, 1)
h_angle, v_angle = calculator.pixel_to_angle(0, 0)
print("angle result: h="+str(h_angle)+" , v="+str(v_angle))
h_pixel, v_pixel = calculator.angle_to_pixel(h_angle, v_angle)
print("pixel result: h="+str(h_pixel)+" , v="+str(v_pixel))

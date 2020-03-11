import HDSAngleCalculator

calculator = HDSAngleCalculator.HDSAngleCalculator(1, 1)
h_angle, v_angle = calculator.pixel_to_angle(720, 470)
print("result: h="+str(h_angle)+" , v="+str(v_angle))

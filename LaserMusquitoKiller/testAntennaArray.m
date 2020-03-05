angle1 = pi/3;
angle2 = pi/4;
locationArray = [1,1,1];
length = 100;
endpoint = locationArray;
endpoint(3) = endpoint(3)+(length*cos(angle2));
endpoint(1) = endpoint(1)+(length*sin(angle2)*cos(angle1));
endpoint(2) = endpoint(2)+(length*sin(angle2)*sin(angle1));
plot3([endpoint(1) locationArray(1)],[endpoint(2) locationArray(2)],[endpoint(3) locationArray(3)]);
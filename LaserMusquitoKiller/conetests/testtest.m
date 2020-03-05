pos = [20,20,20];
angle1 = pi/3;
angle2 = pi/4;
locationArray = [1,1,1];
length = 100;
endpoint = locationArray;
endpoint(3) = endpoint(3)+(length*cos(angle2));
endpoint(1) = endpoint(1)+(length*sin(angle2)*cos(angle1));
endpoint(2) = endpoint(2)+(length*sin(angle2)*sin(angle1));
test = [0,50];
%Cone(locationArray,endpoint,test,1000,'r',0,0)

disance = point_to_line(pos, locationArray,endpoint)

function d = point_to_line(pt, v1, v2)
      a = v1 - v2;
      b = pt - v2;
      d = norm(cross(a,b)) / norm(a);
end
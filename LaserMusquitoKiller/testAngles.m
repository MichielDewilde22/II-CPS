locationMusquito = [7,8,9];
locationLaser = [1,1,1];
bestpos = locationMusquito,

directionVectors = bestpos - locationLaser;
angle1 = atan2((bestpos(2) - locationLaser(2)),(bestpos(1) - locationLaser(1)));
%angle1 = angle1+pi;
updateLocationLaser = locationLaser;
updateLocationLaser(1) = updateLocationLaser(1)+(2*cos(angle1));
updateLocationLaser(2) = updateLocationLaser(2)+(2*sin(angle1));
angle2 = atan2(sqrt((bestpos(1) - updateLocationLaser(1)).^2 + (bestpos(2) - updateLocationLaser(2)).^2),((bestpos(3) - updateLocationLaser(3))));
updateLocationLaser
angle1
%angle2 = angle2+pi;
angle2
testlocation = updateLocationLaser;
testlocation(3) = testlocation(3)+(5*cos(angle2));
testlocation(1) = testlocation(1)+(5*sin(angle2)*cos(angle1));
testlocation(2) = testlocation(2)+(5*sin(angle2)*sin(angle1));
plot3([7 updateLocationLaser(1)],[8 updateLocationLaser(2)],[9 updateLocationLaser(3)]);
hold;
plot3([1 updateLocationLaser(1)],[1 updateLocationLaser(2)],[1 updateLocationLaser(3)]);
plot3(locationLaser(1),locationLaser(2),locationLaser(3),'o');
plot3(bestpos(1),bestpos(2),bestpos(3),'o');
%plot3(testlocation(1),testlocation(2),testlocation(3),'o');
plot3(updateLocationLaser(1), updateLocationLaser(2),updateLocationLaser(3), 'o');
xlabel('x(cm)')
ylabel('y(cm)')
zlabel('z(cm)')
title('Aiming laser two steps')
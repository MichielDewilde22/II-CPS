locationMusquito = [1,2,3];
locationLaser = [4,5,6];
lengthLaserPos = 2;
numberParticles = 500;

%updateLocation;
%LocationMusquito = updateLocation;
 bestpos = locationMusquito;

% xm = locationMusquito(1);
% ym = locationMusquito(2);
% zm = locationMusquito(3);
% 
% initialVariationLoc = 0.01;
% initialVariationSpeed = 0.01;
% initialVariationAngle = 1;
% initialVariationAcceleration = 0.01;
% initialVariationSpeedAngle = 0.1;
% changeVariationLoc = 0.01;
% changeVariationSpeed = 0.01;
% changeVariationAngle = 0.4;
% changeVariationAcceleration = 0.01;
% changeVariationSpeedAngle = 0.1;
% 
% particlecloud = rand(numberParticles,24);
% 
% %initial variantion but with avarage zero and then + initial value making
% %the initial value the average
% particlecloud(:,1) = particlecloud(:,1) * initialVariationLoc - (initialVariationLoc/2) + xm;
% particlecloud(:,2) = particlecloud(:,2) * initialVariationLoc - (initialVariationLoc/2) + ym;
% particlecloud(:,3) = particlecloud(:,3) * initialVariationLoc - (initialVariationLoc/2) + zm;
% % initial variation of speed with zero as the average
% particlecloud(:,4) = particlecloud(:,4) * initialVariationSpeed - (initialVariationSpeed/2);
% % initial variation of the angle with zero as average
% particlecloud(:,5) = particlecloud(:,5) * initialVariationAngle - (initialVariationAngle/2);
% particlecloud(:,6) = particlecloud(:,6) * initialVariationAngle - (initialVariationAngle/2);
% % initial variation of acceleration with zero as the average
% particlecloud(:,7) = particlecloud(:,7) * initialVariationAcceleration - (initialVariationAcceleration/2);
% % initial variation of the speed of the angle with zero as average
% particlecloud(:,8) = particlecloud(:,8) * initialVariationSpeedAngle - (initialVariationSpeedAngle/2);
% particlecloud(:,9) = particlecloud(:,9) * initialVariationSpeedAngle - (initialVariationSpeedAngle/2);
% particlecloud(:,10) = 0; % weight
% particlecloud(:,11) = 0; % previous weight
% particlecloud(:,12) = 0; % the one before and so on
% particlecloud(:,13) = 0;
% particlecloud(:,14) = 0;
% particlecloud(:,15) = 0;
% particlecloud(:,16) = 0;
% particlecloud(:,17) = 0;
% particlecloud(:,18) = 0;
% particlecloud(:,19) = 0;
% particlecloud(:,20) = 0;
% particlecloud(:,21) = 0;
% particlecloud(:,22) = 0;
% particlecloud(:,23) = 0;
% particlecloud(:,24) = 0;
% 
% while true
%     %updateLocation;
%     
%   particlecloud(:,1) = particlecloud(:,1) + particlecloud(:,4) .* cos(particlecloud(:,5));
%   particlecloud(:,2) = particlecloud(:,2) + particlecloud(:,4) .* sin(particlecloud(:,5));
%   particlecloud(:,3) = particlecloud(:,3) + particlecloud(:,4) .* sin(particlecloud(:,6));
%   particlecloud(:,4) = particlecloud(:,4) + particlecloud(:,7);
%   particlecloud(:,5) = particlecloud(:,5) + particlecloud(:,8);
%   particlecloud(:,6) = particlecloud(:,6) + particlecloud(:,9);
%   particlecloud(:,7) = particlecloud(:,7);
%   particlecloud(:,8) = particlecloud(:,8);
%   particlecloud(:,9) = particlecloud(:,9);
%   
%   %L2 difference
%   weight = sqrt(measuredPos(1) - particlecloud(:,1)).^2 + (measuredPos(2) - particlecloud(:,2) + (measuredPos(1) - particlecloud(:,1)).^2);
%   weight = 1./weight;
%   weight = weight ./ sum(weight);
%   
%   particlecloud(:,24) = particlecloud(:,23);
%   particlecloud(:,23) = particlecloud(:,22);
%   particlecloud(:,22) = particlecloud(:,21);
%   particlecloud(:,21) = particlecloud(:,20);
%   particlecloud(:,20) = particlecloud(:,19);
%   particlecloud(:,19) = particlecloud(:,18);
%   particlecloud(:,18) = particlecloud(:,17);
%   particlecloud(:,17) = particlecloud(:,16);
%   particlecloud(:,16) = particlecloud(:,15);
%   particlecloud(:,15) = particlecloud(:,14);
%   particlecloud(:,14) = particlecloud(:,13);
%   particlecloud(:,13) = particlecloud(:,12);
%   particlecloud(:,12) = particlecloud(:,11);
%   particlecloud(:,11) = weight;
%   particlecloud(:,10) = (3*particlecloud(:,11)+particlecloud(:,12)+particlecloud(:,13)+particlecloud(:,14)+particlecloud(:,15)+particlecloud(:,16)+particlecloud(:,17)+particlecloud(:,18)+particlecloud(:,19)+particlecloud(:,20)+particlecloud(:,21)+particlecloud(:,22)+particlecloud(:,23)+particlecloud(:,24))./18;
%   particlecloud(:,10) = particlecloud(:,10) ./ sum(particlecloud(:,10));
%   
%   [valueMax indexMax]=max(particlecloud(:,7));
%   bestPos = [particlecloud(indexMax,1),particlecloud(indexMax,2), particlecloud(indexMax,3)];
%   
%   selecting = particlecloud;
%   selecting(:,7) = (40*particlecloud(:,8)+particlecloud(:,9)+particlecloud(:,10)+particlecloud(:,11)+particlecloud(:,12)+particlecloud(:,13)+particlecloud(:,14)+particlecloud(:,15)+particlecloud(:,16)+particlecloud(:,17)+particlecloud(:,18)+particlecloud(:,19)+particlecloud(:,20))./14;
%   selecting(:,7) = selecting(:,7) ./ sum(selecting(:,7));
%   [~,idx] = sort(selecting(:,7)); % sort just the first column
%   selecting = selecting(idx,:);   % sort the whole matrix using the sort indices
% 
%   for i=1:(numberParticles*0.1)
%     particlecloud(i+numberParticles*0.9,:) = selecting(numberParticles-i,:);
%   end
%   weight = cumsum(weight);
%   for i=1:(numberParticles*0.9)
%     selected(i,1) = find(weight >= rand(1),1);
%   end
%   for i=1:(numberParticles*0.9)
%     particlecloud(i,:) = particlecloud(selected(i,1),:);
%     %for j=1:6
%         particlecloud(i,1) = particlecloud(i,1) + (rand()*changeVariationLoc - (changeVariationLoc/2));
%         particlecloud(i,2) = particlecloud(i,2) + (rand()*changeVariationLoc - (changeVariationLoc/2));
%         particlecloud(i,3) = particlecloud(i,3) + (rand()*changeVariationLoc - (changeVariationLoc/2));
%         particlecloud(i,4) = particlecloud(i,4) * (rand()*changeVariationSpeed - (changeVariationSpeed/2));
%         particlecloud(i,5) = particlecloud(i,5) + (rand()*changeVariationAngle - (changeVariationAngle));
%         particlecloud(i,6) = particlecloud(i,6) + (rand()*changeVariationAngle - (changeVariationAngle/2));
%         particlecloud(i,7) = particlecloud(i,7) * (rand()*changeVariationAcceleration - (changeVariationAcceleration/2));
%         particlecloud(i,8) = particlecloud(i,8) * (rand()*changeVariationSpeedAngle - (changeVariationSpeedAngle/2));
%         particlecloud(i,9) = particlecloud(i,9) * (rand()*changeVariationSpeedAngle - (changeVariationSpeedAngle/2));
%     %end
%   end
  
  directionVectors = locationLaser - bestpos;
  %angle1 = arctan2((locationLaser(2) - bestPos(2))/(locationLaser(1) - bestPos(1)));
  %angle2 = arctan2(sqrt((locationLaser(1) - bestPos(1))^2 + (locationLaser(2) - bestPos(2))^2)/((locationLaser(3) - bestPos(3))));
  %reality inverse kinematics  TODO
  
  %done avoid inverse kinematics
  
  %calculate the first angle
  angle1 = atan2((bestpos(2) - locationLaser(2)),(bestpos(1) - locationLaser(1)));
  %update Laser location based on angle and the distance between joints
  updateLocationLaser = locationLaser;
  updateLocationLaser(1) = updateLocationLaser(1)+(lengthLaserPos*cos(angle1));
  updateLocationLaser(2) = updateLocationLaser(2)+(lengthLaserPos*sin(angle1));
  %calculate second angle based on musquitto and updated location
  angle2 = atan2(sqrt((bestpos(1) - updateLocationLaser(1)).^2 + (bestpos(2) - updateLocationLaser(2)).^2),((bestpos(3) - updateLocationLaser(3))));
  updateLocationLaser
  angle1
  angle2
  % create a testlocation to check the angles
  testlocation = updateLocationLaser;
  testlocation(3) = testlocation(3)+(3*cos(angle2));
  testlocation(1) = testlocation(1)+(3*sin(angle2)*cos(angle1));
  testlocation(2) = testlocation(2)+(3*sin(angle2)*sin(angle1));
  angles = [angle1 angle2];
  sendData(angles);
  plotData(bestpos,locationLaser,updateLocationLaser,testlocation);
% end

function sendData(angles)
%TODO
end
function plotData(bestpos, locationLaser,updateLocationLaser,testlocation)
  plot3([bestpos(1) updateLocationLaser(1)],[bestpos(2) updateLocationLaser(2)],[bestpos(3) updateLocationLaser(3)]);
  hold;
  plot3([locationLaser(1) updateLocationLaser(1)],[locationLaser(2) updateLocationLaser(2)],[locationLaser(3) updateLocationLaser(3)]);
  plot3(locationLaser(1),locationLaser(2),locationLaser(3),'o');
  plot3(bestpos(1),bestpos(2),bestpos(3),'o');
  plot3(testlocation(1),testlocation(2),testlocation(3),'o');
  plot3(updateLocationLaser(1), updateLocationLaser(2),updateLocationLaser(3), 'o');
end
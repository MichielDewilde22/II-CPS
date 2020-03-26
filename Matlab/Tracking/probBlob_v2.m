function[mosqX,mosqY,mosqZ] = getMosqCoords;

arrayLoc1 = sixDOF(1:3); %in mm, so adjust
arrayLoc2 = sixDOF(1:3);
arrayLoc3 = sixDOF(1:3);

%gather azimuths and angles from arrays here

%[azimuth, elevation]
angles = [az1, el1;
          az2, el2;
          az3,el3];
      
%add additional rotations to arrays if needed (from sixDOF(4:6)).
endpoint = [cos(angles(:,2))*cos(angles(:,1)), cos(angles(:,2))*sin(angles(:,1)), sin(angles(:,2))];

matCone1=intensityCone3D(arrayLoc1,endpoint(1));
matCone2=intensityCone3D(arrayLoc2,endpoint(2));
matCone3=intensityCone3D(arrayLoc3,endpoint(3));

coneMat=matCone1.*matCone2.*matCone3;
[mxv,index] = max(coneMat,[],[1 2 3],'linear');
[mosqX,mosqY,mosqZ] = ind2sub(size(coneMat),index);

idx = find((0.25>coneMat)&(0<coneMat));
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'B')
hold on
xlim([0 100])
ylim([0 100])
zlim([0 100])
idx = find((0.5>coneMat)&(0.25<coneMat));
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'Gr')
idx = find((0.75>coneMat)&(0.5<coneMat));
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'Y')
idx = find(coneMat>0.75);
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'R')

function pos = getCurrentPosition(q)
  % in milimeter
  global sixDof
  [~, ~, sixDof] = QMC(q);
  pos = sixDof(1:2)/1000;
end
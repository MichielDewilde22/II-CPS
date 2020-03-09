function[mosqX,mosqY,mosqZ] = getMosqCoords

%Initialize Qualisys object and get current position of array. Find way to
%locate different [m objects.
q = QMC('QMC_conf.txt');
getCurrentPosition(q); %update 6DOF
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
end

function pos = getCurrentPosition(q)
  % in milimeter
  global sixDof
  [~, ~, sixDof] = QMC(q);
  pos = sixDof(1:2)/1000;
end
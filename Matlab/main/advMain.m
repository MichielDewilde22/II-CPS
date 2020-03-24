%Parameters
array1 = [1 1 1 0 0 0]; %figure out rotations
array2 = [1 80 1 0 0 0];
array3 = [1 1 80 0 0 0];
usedArray = 'Dense';
%usedArray = 'Sparse';

beamformInit();
% Ground truth X,Y,Z coordinates from path created by Robbe (Nx3)
soundLocations = createPath();

%start simulink here

% - nodes                : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
nodes = [array1; array2; array3];
%generate mic array output
arraysBFData = generateMicArrayData(nodes,soundLocations, usedArray);
%Do beamforming
AzElArray = getAzEl();
endpoints = [cos(angles(:,2))*cos(angles(:,1)), cos(angles(:,2))*sin(angles(:,1)), sin(angles(:,2))];

%use TDoA to find the approximate position of the mosquito
mosqCoords = getMosqCoords(nodes, endpoints);
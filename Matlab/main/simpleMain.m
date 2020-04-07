%Parameters
array1 = [1 1 1 0 0 0]; %figure out rotations
array2 = [1 80 1 0 0 0];
array3 = [1 1 80 0 0 0];
nodes = [array1; array2; array3];
usedArray = 'Dense';
%usedArray = 'Sparse';
samplerate = 22500;

beamformInit();
% Ground truth X,Y,Z coordinates from path created by Robbe (Nx3)
soundLocations = createPath();
arraysBFData = generateMicArrayData(nodes,soundLocations, usedArray, samplerate);

%start simulink here
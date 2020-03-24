%Parameters
array1 = [1 1 1 0 0 0]; %figure out rotations
array2 = [1 80 1 0 0 0];
array3 = [1 1 80 0 0 0];
usedArray = 'Dense';
%usedArray = 'Sparse';

beamformInit();
% Ground truth X,Y,Z coordinates from path created by Robbe (Nx3)
soundLocations = createPath();

% - nodes                : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
nodes = [array1; array2; array3];
arraysBFData = generateBFData(nodes,soundLocations, usedArray);
AzElArray = getAzEl();

for i = 1: size(AzElArray,1)
    
end

a = lineIntersect3D([ 1 1 1; 2 2 2], [2 2 2; 3 3 3]);
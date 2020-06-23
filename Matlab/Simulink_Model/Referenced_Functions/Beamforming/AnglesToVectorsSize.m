function vectors = AnglesToVectorsSize(position_nodes, directions, sizeVector)
%ANGLESTOINTERSECTION Calculates intersection point of the directions.
% This function calculates the coordinate in [X,Y,Z] of the point to which
% the directions of the sonar arrays point. 
% - position_nodes contains a matrix of NODES X 6DOF cells. 
% (number of arrays x 6)
% - direction contains a matrix NODES X DIRECTIONS cells. 
% (number of arrays x 2). 
% A single direction is expressed as [azimuth, elevation] in degrees. 
% - sizeVector is the size of the vector 

n_nodes = size(position_nodes, 1);
vectors = zeros(n_nodes, 6);

for index = 1:n_nodes
    % 
    azimuth = deg2rad(directions(index, 1));
    elevation = deg2rad(directions(index, 2));
    
    % calculating x,y,z components relative to array
    rx_array = cos(elevation) * cos(azimuth) * sizeVector;
    ry_array = cos(elevation) * sin(azimuth) * sizeVector;
    rz_array = sin(elevation) * sizeVector;
    
    % calculating rotation matrix of array
    [R, ~] = AxelRotS0(position_nodes(index, 4),position_nodes(index, 5),position_nodes(index, 6));
    p_zero = [rx_array ry_array rz_array]; % direction of components before rotation
    rotated_array = (p_zero*R); % directions after rotation
    
    vector = [position_nodes(index, 1) position_nodes(index, 2) ...
        position_nodes(index, 3) rotated_array(1), rotated_array(2), rotated_array(3)];
    vectors(index,:) = vector;
end

end

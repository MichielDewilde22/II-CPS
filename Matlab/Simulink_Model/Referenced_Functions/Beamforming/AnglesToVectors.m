function vectors = AnglesToVectors(position_nodes, directions)
%ANGLESTOINTERSECTION Calculates intersection point of the directions.
% This function calculates the coordinate in [X,Y,Z] of the point to which
% the directions of the sonar arrays point. 
% - position_nodes contains a matrix of NODES X 6DOF cells. 
% (number of arrays x 6)
% - direction contains a matrix NODES X DIRECTIONS cells. 
% (number of arrays x 2). 
% A single direction is expressed as [azimuth, elevation] in radians. 

n_nodes = size(position_nodes, 1);
vectors = zeros(n_nodes, 6);

for index = 1:n_nodes
    azimuth = directions(index, 1);
    elevation = directions(index, 2);
    
    x_component = cos(elevation)*cos(azimuth);
    y_component = cos(elevation)*sin(azimuth);
    z_component = sin(elevation);
    
    vector = [position_nodes(index, 1) position_nodes(index, 2) ...
        position_nodes(index, 3) x_component, y_component, z_component];
    vectors(index,:) = vector;
 
end

end


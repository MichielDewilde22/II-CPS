function array = AddRefPointsToArray(array)
%ADDREFPOINTSTOARRAY Adds reference points to sonar array location.
%   This function adds:
%    - 1 point at the top-center of the array (facing forward)
%    - 2 points at the bottom corner of the array (facing forward)
x = 0.05;
% top center
y_1 = mean(array(2,:));
z_1 = max(array(3,:));
% bottem left
y_2 = min(array(2,:));
z_2 = min(array(3,:));

y_3 = max(array(2,:));
z_3 = z_2;

p1 = [x; y_1; z_1];
p2 = [x; y_2; z_2];
p3 = [x; y_3; z_3];

array = [array, p1, p2, p3];

end


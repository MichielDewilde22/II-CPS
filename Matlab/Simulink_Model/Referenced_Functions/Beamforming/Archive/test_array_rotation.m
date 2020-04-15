clear
close all;
node_pos = [0 0 0 0 -90 0];
array1 = NodePosToArrayPosWithRefs([0 0 0 0 0 0], 5);
array2 = NodePosToArrayPosWithRefs(node_pos, 5);

input_angles = [30 40; 30 40];

vectors = AnglesToVectors([node_pos; node_pos], input_angles);

figure;
hold on; 
grid on; 
xlabel('x'); 
ylabel('y'); 
zlabel('z'); 
axis equal;
scatter3(array1(1,:), array1(2,:), array1(3,:), 'MarkerFaceColor', [0 0 1]);
quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6));
view(20,20);



% figure;
% hold on; 
% grid on; 
% xlabel('x'); 
% ylabel('y'); 
% zlabel('z'); 
% axis equal;
% scatter3(array2(1,:), array2(2,:), array2(3,:), 'MarkerFaceColor', [0 0 1]);
% scatter3(p_rot(1), p_rot(2), p_rot(3), 'MarkerFaceColor', [1 0 0]);
% view(20,20);
% 
% [azimuth, elevation, ~] = cart2sph(p_rot(1), p_rot(2), p_rot(3));
% azimuth = rad2deg(azimuth);
% elevation = rad2deg(elevation);
% Position of the mic arrays is expressed as 6-DOF data. The nodes are 
% positioned in a triangle on the floor.
position_array_1 = [0 1 0 0 0 0];
position_array_2 = [0 2.5 0 0 0 0];
position_array_3 = [0 4 0 0 0 0];
position_nodes = [position_array_1; position_array_2; position_array_3];

array_type = 5;

figure;
hold on; 
grid on; 
xlabel('x'); 
ylabel('y'); 
zlabel('z'); 
axis equal;
for node_i = 1:size(position_nodes,1)
    array = NodePosToArrayPos(position_nodes(node_i,:), array_type);
    scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [0 0 1]);
end
legend();
view(20,20);

n_positions = 100;
sets = 6000;
positions = linspace(0,5,n_positions);
pos_per_set = n_positions/sets;
for set = 1:sets
    pos_ind = ceil(set*pos_per_set);
    fprintf(string(positions(pos_ind)));
end








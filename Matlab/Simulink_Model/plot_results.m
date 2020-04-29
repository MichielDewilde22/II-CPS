close all;

%% SUMMARY
% This is a script for plotting simulation data from the main model. 

%% 0: LOADING DATA
az1_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\1_azimuth.mat');
az2_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\2_azimuth.mat');
az3_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\3_azimuth.mat');
az1 = az1_data.ans.data(:);
az2 = az2_data.ans.data(:);
az3 = az3_data.ans.data(:);
clear az1_data az2_data az3_data;

el1_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\1_elevation.mat');
el2_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\2_elevation.mat');
el3_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\3_elevation.mat');
el1 = el1_data.ans.data(:);
el2 = el2_data.ans.data(:);
el3 = el3_data.ans.data(:);
clear el1_data el2_data el3_data;

posX_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\x_beam.mat');
posY_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\y_beam.mat');
posZ_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\z_beam.mat');
posX = posX_data.ans.data(:);
posY = posY_data.ans.data(:);
posZ = posZ_data.ans.data(:);
clear posX_data posY_data posZ_data;

dir1_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\degrees_servo_1.mat');
dir2_data = load('C:\Users\toons\Documents\MATLAB\II-CPS\Matlab\Simulink_Model\Simulation_Data\WithUDP\degrees_servo_2.mat');
dir1 = dir1_data.ans.data(:);
dir2 = dir2_data.ans.data(:);
clear dir1_data dir2_data;

%% 1: PLOTTING THE ROOM
figure;
hold on; 
grid on; 
xlabel('x'); 
ylabel('y'); 
zlabel('z'); 
axis equal;
xlim([0 pos.room_size(1)]);
ylim([0 pos.room_size(2)]);
zlim([0 pos.room_size(3)]);

% plotting path mosquito
scatter3(pos.sound_locations(:,1), pos.sound_locations(:,2), ...
    pos.sound_locations(:,3), 'MarkerFaceColor', [0 0 1], 'Marker','.');

% plotting microphone arrays
for node_i = 1:size(pos.arrays,1)
    array = NodePosToArrayPos(pos.arrays(node_i,:), BF.array_type);
    scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [1 0 0]);
end

% plot camera
scatter3(pos.camera(1), pos.camera(2), pos.camera(3), ...
    'MarkerFaceColor', [1 1 0]);

% plot laser
scatter3(pos.laser(1), pos.laser(2), pos.laser(3), ...
    'MarkerFaceColor', [1 0 1]);

scatter3(posX, posY, posZ, 'Marker','.');

legend('Path Mosquito', 'Array 1', 'Array 2', 'Array 3', 'Camera', 'Laser', 'Calculated');
title('Room Plot');
view(20,20);

%% 2: plotting beamforming steps
timestep_BF = 60/size(az1,1);

timepoints = [10 20 30 40 50];
samplepoints = floor(timepoints.*(1/timestep_BF));
n_samplepoints = size(samplepoints,2);

loc_per_s = pos.n_sound_locations/60;
locSamplepoints = floor(timepoints.*loc_per_s);


for iSample = 1:n_samplepoints
    %% plotting the room
    figure('Position', [50 50 900 600]);
    hold on; 
    grid on; 
    xlabel('x'); 
    ylabel('y'); 
    zlabel('z'); 
    axis equal;
    xlim([0 pos.room_size(1)]);
    ylim([0 pos.room_size(2)]);
    zlim([0 pos.room_size(3)]);

    %% calculating vectors
    directions = [az1(samplepoints(iSample)) el1(samplepoints(iSample)); ...
        az2(samplepoints(iSample)) el2(samplepoints(iSample));...
        az3(samplepoints(iSample)) el3(samplepoints(iSample))];
    vectors = AnglesToVectors(pos.arrays, directions);
    
    vector_laser = AnglesToLaserVector(pos.laser, dir1(samplepoints(iSample)), dir2(samplepoints(iSample)));
    
    % plotting array directions
    quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6));
    
    % plotting laser
    quiver3(vector_laser(1), vector_laser(2), vector_laser(3), vector_laser(4), vector_laser(5), vector_laser(6));
    
    % plotting location mosquito
    scatter3(pos.sound_locations(locSamplepoints(iSample),1), pos.sound_locations(locSamplepoints(iSample),2), ...
        pos.sound_locations(locSamplepoints(iSample),3), 'MarkerFaceColor', [0 0 1], 'Marker','o');
    
    % plotting calculated locations
    scatter3(posX(samplepoints(iSample)), posY(samplepoints(iSample)), posZ(samplepoints(iSample)), ...
        'MarkerFaceColor', [0 0 0]);
    
    % plotting microphone arrays
    for node_i = 1:size(pos.arrays,1)
        array = NodePosToArrayPos(pos.arrays(node_i,:), BF.array_type);
        scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [1 0 0]);
    end

    % plot laser
    scatter3(pos.laser(1), pos.laser(2), pos.laser(3), ...
        'MarkerFaceColor', [1 0 1]);
    
    error_dist = norm([ posX(samplepoints(iSample)), posY(samplepoints(iSample)), ...
        posZ(samplepoints(iSample)) ] - [ pos.sound_locations(locSamplepoints(iSample),1), ...
        pos.sound_locations(locSamplepoints(iSample),2), ...
        pos.sound_locations(locSamplepoints(iSample),3) ]);
    
    titleString = 'Error at '+string(timepoints(iSample))+'s was: '+string(error_dist)+'m';
    title(titleString);
    
    legend('Dir Arrays', 'Dir Laser', 'Actual Position', 'Calculated Position', 'Array 1', 'Array 2', 'Array 3', 'Position Laser');
   %% plotting the vectors/datapoints
   view(20,20);
end
    

close all;

%% SUMMARY
% This is a script for plotting simulation data from the main model. 
% REMEMBER TO RUN THE "set_workspace_parameters.m" script first. 

% Vector with timepoints you want to plot, if the timepoint does not exist,
% the script takes the nearest one. (timepoint is in seconds)
timepoints = [5 15 25 35 45 55];
n_timepoints = size(timepoints, 2);

% Booleans for plotting a certain aspect
PLOT_ROOM = 1;
PLOT_ARRAY_DIR = 1;
PLOT_INTERSECTIONS = 1;
PLOT_FILTER = 1;
PLOT_FILTER_DIR = 1;
PLOT_SERIAL_DIR = 1;

%% 0: LOADING DATA
az1_data = load('Simulation_Data\plot_data\1_azimuth.mat');
az2_data = load('Simulation_Data\plot_data\2_azimuth.mat');
az3_data = load('Simulation_Data\plot_data\3_azimuth.mat');
az1 = az1_data.ans;
az2 = az2_data.ans;
az3 = az3_data.ans;
clear az1_data az2_data az3_data;

el1_data = load('Simulation_Data\plot_data\1_elevation.mat');
el2_data = load('Simulation_Data\plot_data\2_elevation.mat');
el3_data = load('Simulation_Data\plot_data\3_elevation.mat');
el1 = el1_data.ans;
el2 = el2_data.ans;
el3 = el3_data.ans;
clear el1_data el2_data el3_data;

xBeam_data = load('Simulation_Data\plot_data\x_beam.mat');
yBeam_data = load('Simulation_Data\plot_data\y_beam.mat');
zBeam_data = load('Simulation_Data\plot_data\z_beam.mat');
xBeam = xBeam_data.ans;
yBeam = yBeam_data.ans;
zBeam = zBeam_data.ans;
clear xBeam_data yBeam_data zBeam_data;

xFilter_data = load('Simulation_Data\plot_data\x_filter.mat');
yFilter_data = load('Simulation_Data\plot_data\y_filter.mat');
zFilter_data = load('Simulation_Data\plot_data\z_filter.mat');
xFilter = xFilter_data.ans;
yFilter = yFilter_data.ans;
zFilter = zFilter_data.ans;
clear xFilter_data yFilter_data zFilter_data;

azFilter_data = load('Simulation_Data\plot_data\degrees_servo_1.mat');
elFilter_data = load('Simulation_Data\plot_data\degrees_servo_2.mat');
azFilter = azFilter_data.ans;
elFilter = elFilter_data.ans;
clear azFilter_data elFilter_data;

azSerial_data = load('Simulation_Data\plot_data\serial_servo_1.mat');
elSerial_data = load('Simulation_Data\plot_data\serial_servo_2.mat');
azSerial = azSerial_data.ans;
elSerial = elSerial_data.ans;
clear azSerial_data elSerial_data;

%% 1: PLOTTING THE ROOM
if PLOT_ROOM
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
    plot3(pos.sound_locations(:,1), pos.sound_locations(:,2), ...
        pos.sound_locations(:,3), 'Color', [0 0 1]);

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

    scatter3(xBeam.data, yBeam.data, zBeam.data,'MarkerEdgeColor', 'm', 'Marker','.');
    scatter3(xFilter.data, yFilter.data, zFilter.data, 'MarkerEdgeColor', 'g', 'marker', '*');

    legend('Path Mosquito', 'Array 1', 'Array 2', 'Array 3', 'Camera', 'Laser', 'Position After Beamforming', 'Position After Filter');
    title('Room Plot');
    
    view(20,20);
end

%% 2: plotting timepoints
sound_location_step_size = (BF.duration / (pos.n_sound_locations-1));

for iSample = 1:n_timepoints
    %% get nearest location value of the mosquito
    timepoint = timepoints(iSample);
    index_location = round(timepoint / sound_location_step_size);
    
    %% plotting the room
    figure('Position', [50 50 900 600]);
    legendStrings = {};
    annString = "";
    hold on; 
    grid on; 
    xlabel('x'); 
    ylabel('y'); 
    zlabel('z'); 
    axis equal;
    xlim([0 pos.room_size(1)]);
    ylim([0 pos.room_size(2)]);
    zlim([0 pos.room_size(3)]);
    view(20,20);
    
    % plotting microphone arrays
    for node_i = 1:size(pos.arrays,1)
        array = NodePosToArrayPos(pos.arrays(node_i,:), BF.array_type);
        scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [1 0 0]);
    end
    legendStrings{end+1} = "Position Array 1";
    legendStrings{end+1} = "Position Array 2";
    legendStrings{end+1} = "Position Array 3";
    
    % plot laser
    scatter3(pos.laser(1), pos.laser(2), pos.laser(3), 'MarkerFaceColor', [1 0 1]);
    legendStrings{end+1} = "Position Laser";
    
    % plot current point
    scatter3(pos.sound_locations(index_location, 1), pos.sound_locations(index_location, 2), pos.sound_locations(index_location, 3), 'MarkerFaceColor', [1 1 0]);
    legendStrings{end+1} = "Actual Point";
    
    
    %% calculating vectors
    if PLOT_ARRAY_DIR
        [timepoint_BF, az1_dir] = getNearestPoint(az1, timepoint);
        [~, az2_dir] = getNearestPoint(az2, timepoint);
        [~, az3_dir] = getNearestPoint(az3, timepoint);
        
        [~, el1_dir] = getNearestPoint(el1, timepoint);
        [~, el2_dir] = getNearestPoint(el2, timepoint);
        [~, el3_dir] = getNearestPoint(el3, timepoint);
        
        directions = [az1_dir el1_dir; az2_dir el2_dir; az3_dir el3_dir];
        vectors = AnglesToVectorsSize(pos.arrays, directions, 100);
        
        quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6), 5, 'LineStyle', '--', 'Color', [1 0 1]);
        legendStrings{end+1} = "Array BF Directions";
        annString = annString + " Time Measurements BF & Filtering: " + string(timepoint_BF) + "s";
    end
    
    if PLOT_INTERSECTIONS
        [~, xBeam_pos] = getNearestPoint(xBeam, timepoint);
        [~, yBeam_pos] = getNearestPoint(yBeam, timepoint);
        [~, zBeam_pos] = getNearestPoint(zBeam, timepoint);
        
        scatter3(xBeam_pos, yBeam_pos, zBeam_pos,'MarkerEdgeColor', 'm', 'Marker', 'x');
        legendStrings{end+1} = "Intersection Before Filter";
    end
    
    if PLOT_FILTER
        [~, xFilter_pos] = getNearestPoint(xFilter, timepoint);
        [~, yFilter_pos] = getNearestPoint(yFilter, timepoint);
        [~, zFilter_pos] = getNearestPoint(zFilter, timepoint);
        
        scatter3(xFilter_pos, yFilter_pos, zFilter_pos,'MarkerEdgeColor', 'g', 'Marker', '*');
        legendStrings{end+1} = "Intersection After Filter";
    end
    
    
    if PLOT_FILTER_DIR
        [~, azFilter_dir] = getNearestPoint(azFilter, timepoint);
        [~, elFilter_dir] = getNearestPoint(elFilter, timepoint);
        
        vector_laser = AnglesToLaserVector(pos.laser, azFilter_dir, elFilter_dir);
        quiver3(vector_laser(1), vector_laser(2), vector_laser(3), vector_laser(4), vector_laser(5), vector_laser(6), ...
            5, 'LineStyle', '--','Color', [0 1 0]);
        legendStrings{end+1} = "Direction after Filter";
    end
        
    if PLOT_SERIAL_DIR
        [timepoint_serial, azSerial_dir] = getNearestPoint(azSerial, timepoint);
        [~, elSerial_dir] = getNearestPoint(elSerial, timepoint);
        
        vector_laser = AnglesToLaserVector(pos.laser, azSerial_dir, elSerial_dir);
        quiver3(vector_laser(1), vector_laser(2), vector_laser(3), vector_laser(4), vector_laser(5), vector_laser(6), ...
            5, 'LineStyle', '--','Color', [0 0 1]);
        legendStrings{end+1} = "Direction after Serial";
        annString = annString + " -- Time Measurements After Serial: " + string(timepoint_serial) + "s";
    end
    
    legend(legendStrings);
    annotation('textbox', [0, 0.05, 1, 0], 'string', annString)
    
    titleString = 'Situation at '+string(timepoint)+'s';
    title(titleString);
    
   %% plotting the vectors/datapoints
   
   
   
end
    

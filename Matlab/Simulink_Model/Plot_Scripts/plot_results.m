close all;
clc

fprintf("PLOTTING & CALCULATING STATISTICS \n");
fprintf(" 1) Loading Data \n");
%% SUMMARY
% This is a script for plotting simulation data from the main model. 
% REMEMBER TO RUN THE "set_workspace_parameters.m" script first. 

% steps to run this script:
% 1) run the "set_workspace_parameters.m" script
% 2) run the simulation (sub simulations) you want to analyze
% 3) copy the simulation results to the folder /Simulation_Data/plot_data/
% 4) run this script

% Vector with timepoints you want to plot, if the timepoint does not exist,
% the script takes the nearest one. (timepoint is in seconds)
timepoints = [5 15 25 35 45 55];
n_timepoints = size(timepoints, 2);

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

azServo_data = load('Simulation_Data\plot_data\az_servo.mat');
elServo_data = load('Simulation_Data\plot_data\el_servo.mat');
azServo = azServo_data.ans;
elServo = elServo_data.ans;
clear azServo_dat elServo_data;

%% 1: PLOTTING THE ROOM
fprintf(" 2) Plotting Room \n");

figure;
hold on; 
grid on; 
xlabel('x [m]'); 
ylabel('y [m]'); 
zlabel('z [m]'); 
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

%% 2: plotting timepoints
sound_location_step_size = (BF.duration / (pos.n_sound_locations-1));
fprintf(" 3) Plotting Situations \n");
for iSample = 1:n_timepoints
    %% get nearest location value of the mosquito
    timepoint = timepoints(iSample);
    index_location = round(timepoint / sound_location_step_size);
    loc_mos = [pos.sound_locations(index_location, 1), pos.sound_locations(index_location, 2), pos.sound_locations(index_location, 3)];
    
    norm_co_mos = loc_mos - pos.laser(1:3); % coordinates of mosquito relative to laser position
    dist_laser_mos = norm(norm_co_mos);
    [az_mos, el_mos, dist_mos] = cart2sph(norm_co_mos(1), norm_co_mos(2), norm_co_mos(3));
    az_mos_deg = rad2deg(az_mos);
    el_mos_deg = rad2deg(el_mos)*(-1) - 270;
    
    
    %% plotting the room
    figure('Position', [50 50 900 600]);
    legendStrings = {};
    annString = "";
    hold on; 
    grid on; 
    xlabel('x [m]'); 
    ylabel('y [m]'); 
    zlabel('z [m]'); 
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
    
    % plot ideal shooting direction
    vector_laser = AnglesToLaserVector(pos.laser, az_mos_deg, el_mos_deg);
    quiver3(vector_laser(1), vector_laser(2), vector_laser(3), vector_laser(4), vector_laser(5), vector_laser(6), ...
            5, 'LineStyle', '-','Color', 'y');
    legendStrings{end+1} = "Ideal Laser Direction";
        
    %% plotting beamforming directions
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
    
    %% plotting beamforming intersections
    [~, xBeam_pos] = getNearestPoint(xBeam, timepoint);
    [~, yBeam_pos] = getNearestPoint(yBeam, timepoint);
    [~, zBeam_pos] = getNearestPoint(zBeam, timepoint);

    scatter3(xBeam_pos, yBeam_pos, zBeam_pos,'MarkerEdgeColor', 'm', 'Marker', 'x');
    legendStrings{end+1} = "Intersection Before Filter";
    
    %% plotting intersection after filter
    [~, xFilter_pos] = getNearestPoint(xFilter, timepoint);
    [~, yFilter_pos] = getNearestPoint(yFilter, timepoint);
    [~, zFilter_pos] = getNearestPoint(zFilter, timepoint);

    scatter3(xFilter_pos, yFilter_pos, zFilter_pos,'MarkerEdgeColor', 'g', 'Marker', '*');
    legendStrings{end+1} = "Intersection After Filter";
    
    %% plotting direction after filter
    [~, azFilter_dir] = getNearestPoint(azFilter, timepoint);
    [~, elFilter_dir] = getNearestPoint(elFilter, timepoint);

    vector_filter = AnglesToLaserVector(pos.laser, azFilter_dir, elFilter_dir);
    quiver3(vector_filter(1), vector_filter(2), vector_filter(3), vector_filter(4), vector_filter(5), vector_filter(6), ...
        5, 'LineStyle', '--','Color', [0 1 0]);
    legendStrings{end+1} = "Direction after Filter";
        
    %% plotting serial direction 
    [timepoint_serial, azSerial_dir] = getNearestPoint(azSerial, timepoint);
    [~, elSerial_dir] = getNearestPoint(elSerial, timepoint);

    vector_serial = AnglesToLaserVector(pos.laser, azSerial_dir, elSerial_dir);
    quiver3(vector_serial(1), vector_serial(2), vector_serial(3), vector_serial(4), vector_serial(5), vector_serial(6), ...
        5, 'LineStyle', '--','Color', [0 0 1]);
    legendStrings{end+1} = "Direction after Serial";
    annString = annString + " -- Time Measurements After Serial: " + string(timepoint_serial) + "s";
    
    %% plotting servo direction
    [timepoint_servo, azServo_dir] = getNearestPoint(azServo, timepoint);
    [~, elServo_dir] = getNearestPoint(elServo, timepoint);
    vector_servo = AnglesToLaserVector(pos.laser, azServo_dir, elServo_dir);
    quiver3(vector_servo(1), vector_servo(2), vector_servo(3), vector_servo(4), vector_servo(5), vector_servo(6), ...
        5, 'LineStyle', '-','Color', [1 0 0]);
    legendStrings{end+1} = "Direction Laser";
    annString = annString + " -- Time Measurements Laser: " + string(timepoint_servo) + "s";
    
    %% calculating errors
    error_BF = norm([xBeam_pos, yBeam_pos, zBeam_pos] - loc_mos);
    error_filter = norm([xFilter_pos, yFilter_pos, zFilter_pos] - loc_mos);
    
    % calculating angle between to vectors
    a = vector_laser(4:6);
    b = vector_serial(4:6);
    angle = atan2(norm(cross(a,b)), dot(a,b));
    % calculating error
    error_serial = tan(angle)*dist_laser_mos;
    
    b = vector_servo(4:6);
    angle = atan2(norm(cross(a,b)), dot(a,b));
    error_servo = tan(angle)*dist_laser_mos;

    str = " ---- ERROR METRICS: -- Error BF: " + string(error_BF) + "m -- Error Filter: " + string(error_filter) + "m -- Error Serial: " + string(error_serial) + "m -- Error Laser: " + string(error_servo) + "m";
    annString = annString + str;
    
    legend(legendStrings);
    annotation('textbox', [0, 0.05, 1, 0], 'string', annString)
    
    titleString = 'Situation at '+string(timepoint)+'s';
    title(titleString);
end

%% 3 CALCULATION ERROR STATISTICS
fprintf(" 4) Calculating error \n");
errors_BF = zeros(pos.n_sound_locations, 1);
errors_filter = zeros(pos.n_sound_locations, 1);
errors_serial = zeros(pos.n_sound_locations, 1);
errors_laser = zeros(pos.n_sound_locations, 1);

for iLoc = 1:pos.n_sound_locations
    fprintf("  - step "+string(iLoc)+" from "+string(pos.n_sound_locations)+" \n");
    timepoint = iLoc*sound_location_step_size - sound_location_step_size;
    loc_mos = [pos.sound_locations(iLoc, 1), pos.sound_locations(iLoc, 2), pos.sound_locations(iLoc, 3)];
    
    %% BF error
    [~, xBeam_pos] = getNearestPoint(xBeam, timepoint);
    [~, yBeam_pos] = getNearestPoint(yBeam, timepoint);
    [~, zBeam_pos] = getNearestPoint(zBeam, timepoint);
    errors_BF(iLoc) = norm([xBeam_pos, yBeam_pos, zBeam_pos] - loc_mos);
    
    %% Filter Error
    [~, xFilter_pos] = getNearestPoint(xFilter, timepoint);
    [~, yFilter_pos] = getNearestPoint(yFilter, timepoint);
    [~, zFilter_pos] = getNearestPoint(zFilter, timepoint);
    errors_filter(iLoc) = norm([xFilter_pos, yFilter_pos, zFilter_pos] - loc_mos);
    
    %% Serial Error
    [timepoint_serial, azSerial_dir] = getNearestPoint(azSerial, timepoint);
    [~, elSerial_dir] = getNearestPoint(elSerial, timepoint);
    
    norm_co_mos = loc_mos - pos.laser(1:3); % coordinates of mosquito relative to laser position
    dist_laser_mos = norm(norm_co_mos);
    [az_mos, el_mos, dist_mos] = cart2sph(norm_co_mos(1), norm_co_mos(2), norm_co_mos(3));
    az_mos_deg = rad2deg(az_mos);
    el_mos_deg = rad2deg(el_mos)*(-1) - 270;
    
    vector_laser = AnglesToLaserVector(pos.laser, az_mos_deg, el_mos_deg);
    vector_serial = AnglesToLaserVector(pos.laser, azSerial_dir, elSerial_dir);
    
    % calculating angle between to vectors
    a = vector_laser(4:6);
    b = vector_serial(4:6);
    angle = atan2(norm(cross(a,b)), dot(a,b));
    % calculating error
    errors_serial(iLoc) = tan(angle)*dist_laser_mos;
    
    %% Laser Error
    if timepoint > 10
        [timepoint_laser, azServo_dir] = getNearestPoint(azServo, timepoint);
        [~, elServo_dir] = getNearestPoint(elServo, timepoint);
        
        vector_servo = AnglesToLaserVector(pos.laser, azServo_dir, elServo_dir);
        b = vector_servo(4:6);
        angle = atan2(norm(cross(a,b)), dot(a,b));
        % calculating error
        errors_laser(iLoc) = tan(angle)*dist_laser_mos;
    end
end

errors_laser = errors_laser(1000:end); % removing the part where the servo's were not working

median_error_BF = median(errors_BF);
median_error_filter = median(errors_filter);
median_error_serial = median(errors_serial);
median_error_laser = median(errors_laser);

mean_error_BF = mean(errors_BF);
mean_error_filter = mean(errors_filter);
mean_error_serial = mean(errors_serial);
mean_error_laser = median(errors_laser);

std_error_BF = std(errors_BF);
std_error_filter = std(errors_filter);
std_error_serial = std(errors_serial);
std_error_laser = std(errors_laser);

fprintf("STATISTICS: \n");
fprintf("--------------- \n");
fprintf("Error Beamforming: \n");
fprintf(" - Mean Error:         "+string(mean_error_BF)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_BF)+"m\n");
fprintf(" - Median Error:       "+string(median_error_BF)+"m\n");
fprintf("Error After Filter: \n");
fprintf(" - Mean Error:         "+string(mean_error_filter)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_filter)+"m\n");
fprintf(" - Median Error:       "+string(median_error_filter)+"m\n");
fprintf("Error After Serial Communication: \n");
fprintf(" - Mean Error:         "+string(mean_error_serial)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_serial)+"m\n");
fprintf(" - Median Error:       "+string(median_error_serial)+"m\n");
fprintf("Error Laser: \n");
fprintf(" - Mean Error:         "+string(mean_error_laser)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_laser)+"m\n");
fprintf(" - Median Error:       "+string(median_error_laser)+"m\n");

    

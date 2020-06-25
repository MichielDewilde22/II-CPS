close all

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

figure('units','pixels','position',[0 0 1920 1080])
axis tight manual 
grid on; 
xlabel('x [m]'); 
ylabel('y [m]'); 
zlabel('z [m]'); 
axis equal;
xlim([0 pos.room_size(1)]);
ylim([0 pos.room_size(2)]);
zlim([0 pos.room_size(3)]);
title("Room View");
view(20,20);


ax = gca;
ax.GridAlpha = 0.5;

set(gca, 'nextplot', 'replacechildren');
set(gcf,'color',[0.5 0.5 0.5]);
v = VideoWriter('test.avi');
v.Quality = 95;
open(v);

frame_rate = 30;
duration = 60; % seconds
frame_duration = 1/frame_rate;

frames = 0:frame_duration:duration;
n_frames = length(frames);

view_begin = 5;
view_end = 100;
view_delta = (view_end-view_begin)/n_frames;
views = view_begin:view_delta:view_end;

mos_step_size = (BF.duration / (pos.n_sound_locations-1));
time_mos = 0:mos_step_size:BF.duration;

hold on

% plotting microphone arrays
for node_i = 1:size(pos.arrays,1)
    array = NodePosToArrayPos(pos.arrays(node_i,:), BF.array_type);
    scatter3(array(1,:), array(2,:), array(3,:), 7, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 0 1]);
end

% plot laser
scatter3(pos.laser(1), pos.laser(2), pos.laser(3), 100, ...
    'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [0 0 0]);

for iFrame = 1:n_frames
    timepoint = frames(iFrame);
    view_value = views(iFrame);
    view(view_value, 20);
    
    %%  plotting mosquito
    [~, mos_indx] = min(abs(time_mos - timepoint));
    mos_start_indx = max(1, mos_indx-(frame_rate*2));
    previous_mos_pos = plot3(pos.sound_locations(mos_start_indx:mos_indx,1), ...
        pos.sound_locations(mos_start_indx:mos_indx,2), pos.sound_locations(mos_start_indx:mos_indx,3), ...
        'Color','b');
    current_mos_pos = scatter3(pos.sound_locations(mos_indx,1), pos.sound_locations(mos_indx,2), pos.sound_locations(mos_indx,3), 'filled', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','r');
    
    %%  plotting beamforming directions
    [~, az1_dir] = getNearestPoint(az1, timepoint);
    [~, az2_dir] = getNearestPoint(az2, timepoint);
    [~, az3_dir] = getNearestPoint(az3, timepoint);

    [~, el1_dir] = getNearestPoint(el1, timepoint);
    [~, el2_dir] = getNearestPoint(el2, timepoint);
    [~, el3_dir] = getNearestPoint(el3, timepoint);
    
    directions = [az1_dir el1_dir; az2_dir el2_dir; az3_dir el3_dir];
    vectors = AnglesToVectorsSize(pos.arrays, directions, 100);

    bf_dirs = quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6), 5, 'LineStyle', '--', 'Color', [1 0 1]);
    
    %% plotting BF intersections
    [~, xBeam_pos] = getNearestPoint(xBeam, timepoint);
    [~, yBeam_pos] = getNearestPoint(yBeam, timepoint);
    [~, zBeam_pos] = getNearestPoint(zBeam, timepoint);

    bf_inter = scatter3(xBeam_pos, yBeam_pos, zBeam_pos, 100, 'MarkerEdgeColor', 'm', 'Marker', 'x');
    
    
    %% plotting filtered data
    [~, filter_indx] = min(abs(xFilter.time - timepoint));
    min_filter_indx = max(1, filter_indx-5);
    filterp = scatter3(xFilter.data(filter_indx), yFilter.data(filter_indx), zFilter.data(filter_indx), 100, 'MarkerEdgeColor', 'g', 'Marker', '*');
    pr_filterp = plot3(xFilter.data(min_filter_indx:filter_indx), yFilter.data(min_filter_indx:filter_indx), ...
        zFilter.data(min_filter_indx:filter_indx), 'Color','g', 'LineStyle', ':', 'LineWidth', 2);
    
    %% plotting laser
    [~, azServo_dir] = getNearestPoint(azServo, timepoint);
    [~, elServo_dir] = getNearestPoint(elServo, timepoint);
    vector_servo = AnglesToLaserVector(pos.laser, azServo_dir, elServo_dir);
    laser_dir = quiver3(vector_servo(1), vector_servo(2), vector_servo(3), vector_servo(4), vector_servo(5), vector_servo(6), ...
        5, 'LineStyle', '-','Color', [1 0 0], 'LineWidth', 2);
    
    legend("Mic Array 1", "Mic Array 2", "Mic Array 3", "Position Laser", "Current Position Mosquito", " -- ", ...
        "Beamforming Directions", " -- ", "Filtered Location", " -- ", "Laser");
    
    frame = getframe(gcf);
    writeVideo(v,frame);
    
    % deleting plot objects
    delete(current_mos_pos);
    delete(previous_mos_pos);
    delete(bf_dirs);
    delete(bf_inter);
    delete(filterp);
    delete(pr_filterp);
    delete(laser_dir);
end

close(v);
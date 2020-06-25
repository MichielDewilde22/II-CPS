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

figure('units','pixels','position',[0 0 1920 850])
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
duration = 10; % seconds
frame_duration = 1/frame_rate;

frames = 0:frame_duration:duration;
n_frames = length(frames);

view_begin = 30;
view_end = 120;
view_delta = (view_end-view_begin)/n_frames;
views = view_begin:view_delta:view_end;

mos_step_size = (BF.duration / (pos.n_sound_locations-1));
time_mos = 0:mos_step_size:BF.duration;

hold on

% plotting microphone arrays
for node_i = 1:size(pos.arrays,1)
    array = pos.arrays(node_i,1:3);
    scatter3(array(1), array(2), array(3), 100, 'MarkerFaceColor', [1 0.7 0], 'MarkerEdgeColor', [1 0 0]);
end

% plot laser
scatter3(pos.laser(1), pos.laser(2), pos.laser(3), 100, ...
    'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [0 0 0]);

timepoint = 35; % seconds

%%  plotting mosquito
[~, mos_indx] = min(abs(time_mos - timepoint));
current_mos_pos = scatter3(pos.sound_locations(mos_indx,1), pos.sound_locations(mos_indx,2), pos.sound_locations(mos_indx,3), 100, 'filled', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','r');
    

%%  plotting beamforming directions
[~, az1_dir] = getNearestPoint(az1, timepoint);
[~, az2_dir] = getNearestPoint(az2, timepoint);
[~, az3_dir] = getNearestPoint(az3, timepoint);

[~, el1_dir] = getNearestPoint(el1, timepoint);
[~, el2_dir] = getNearestPoint(el2, timepoint);
[~, el3_dir] = getNearestPoint(el3, timepoint);

directions = [az1_dir el1_dir; az2_dir el2_dir; az3_dir el3_dir];
vectors = AnglesToVectorsSize(pos.arrays, directions, 100);

bf_dirs = quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6), 5, 'LineStyle', '--', 'Color', [1 0.7 0], 'LineWidth',2);
    
%% plotting BF intersections
[~, xBeam_pos] = getNearestPoint(xBeam, timepoint);
[~, yBeam_pos] = getNearestPoint(yBeam, timepoint);
[~, zBeam_pos] = getNearestPoint(zBeam, timepoint);

bf_inter = scatter3(xBeam_pos, yBeam_pos, zBeam_pos, 100, 100, 'filled', 'MarkerEdgeColor', [1 0.7 0], 'MarkerFaceColor',[1 0 1]);

for iFrame = 1:n_frames
    timepoint = frames(iFrame);
    view_value = views(iFrame);
    view(view_value, 20);
    
    legend("Mic Array 1", "Mic Array 2", "Mic Array 3", "Position Laser", "Current Position Mosquito", "Beamforming Directions", "Nearest Intersection");
    
    frame = getframe(gcf);
    writeVideo(v,frame);
end

close(v);
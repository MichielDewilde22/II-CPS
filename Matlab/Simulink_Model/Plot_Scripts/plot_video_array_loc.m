close all

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

view_begin = 5;
view_end = 100;
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

for iFrame = 1:n_frames
    timepoint = frames(iFrame);
    view_value = views(iFrame);
    view(view_value, 20);
    
   legend("Mic Array 1", "Mic Array 2", "Mic Array 3", "Position Laser");
    
    frame = getframe(gcf);
    writeVideo(v,frame);
end

close(v);
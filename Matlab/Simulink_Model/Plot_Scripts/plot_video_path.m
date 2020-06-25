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
duration = 30; % seconds
frame_duration = 1/frame_rate;

frames = 0:frame_duration:duration;
n_frames = length(frames);

view_begin = 5;
view_end = 200;
view_delta = (view_end-view_begin)/n_frames;
views = view_begin:view_delta:view_end;

mos_step_size = (BF.duration / (pos.n_sound_locations-1));
time_mos = 0:mos_step_size:BF.duration;

hold on

for iFrame = 1:n_frames
    timepoint = frames(iFrame);
    view_value = views(iFrame);
    view(view_value, 20);
    
    %%  plotting mosquito
    [~, mos_indx] = min(abs(time_mos - timepoint));
    mos_start_indx = max(1, mos_indx-(frame_rate*4));
    previous_mos_pos = plot3(pos.sound_locations(mos_start_indx:mos_indx,1), ...
        pos.sound_locations(mos_start_indx:mos_indx,2), pos.sound_locations(mos_start_indx:mos_indx,3), ...
        'Color','b');
    current_mos_pos = scatter3(pos.sound_locations(mos_indx,1), pos.sound_locations(mos_indx,2), pos.sound_locations(mos_indx,3), 50, 'filled', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','r');
    
    frame = getframe(gcf);
    writeVideo(v,frame);
    
    % deleting plot objects
    delete(current_mos_pos);
    delete(previous_mos_pos);
end

close(v);
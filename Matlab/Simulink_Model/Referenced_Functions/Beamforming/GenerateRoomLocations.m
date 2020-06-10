function sound_locations = GenerateRoomLocations(room_dimensions, point_spacing, plot)
%GENERATEROOMLOCATIONS Create locations evenly distributed in the room.

% we create a gap between the wall and the locations equal 1/10 of the
% total dimension

xlimit_min = room_dimensions(1)/10;
ylimit_min = room_dimensions(2)/10;
zlimit_min = room_dimensions(3)/10;

xlimit_max = room_dimensions(1)-xlimit_min;
ylimit_max = room_dimensions(2)-ylimit_min;
zlimit_max = room_dimensions(3)-zlimit_min;

x_locations = linspace(xlimit_min, xlimit_max, round((xlimit_max-xlimit_min)/point_spacing));
y_locations = linspace(ylimit_min, ylimit_max, round((ylimit_max-ylimit_min)/point_spacing));
z_locations = linspace(zlimit_min, zlimit_max, round((zlimit_max-zlimit_min)/point_spacing));

n_x = size(x_locations, 2);
n_y = size(y_locations, 2);
n_z = size(z_locations, 2);

n_locations = n_x * n_y * n_z;
sound_locations = zeros(n_locations, 3);

i_location = 1;
for i_x = 1:n_x
    for i_y = 1:n_y
        for i_z = 1:n_z
            sound_locations(i_location,:) = [x_locations(i_x), y_locations(i_y), z_locations(i_z)];
            i_location = i_location + 1;
        end
    end
end

if plot
    figure;
    hold on; 
    grid on; 
    xlabel('x'); 
    ylabel('y'); 
    zlabel('z'); 
    axis equal;
    xlim([0 room_dimensions(1)]);
    ylim([0 room_dimensions(2)]);
    zlim([0 room_dimensions(3)]);
    scatter3(sound_locations(:,1), sound_locations(:,2), sound_locations(:,3), 'MarkerFaceColor', [0 0 1], 'Marker','.');
    view(20,20);
    legend('Locations');
end

end


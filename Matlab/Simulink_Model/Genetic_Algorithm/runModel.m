function mean_error = runModel(x, audioPS, fs, n_steering_angles, sound_locations, room_dimensions, array_type, plot_room)
% fprintf("1: Started Model Simulation \n");
% Position of the mic arrays is expressed as 6-DOF data. The nodes are 
% positioned in a triangle on the floor. (angles are in degrees)
% Important notice: the arrays only detect in a forward derection.
% Therefore we turn them -90 degrees so that they lay flat on the floor. 
% position_array_1 = [1.5 1.5 0 0 -90 0];
% position_array_2 = [1.5 3.5 0 0 -90 0];
% position_array_3 = [3.5 2.5 0 0 -90 0];
% position_nodes = [position_array_1; position_array_2; position_array_3];
position_nodes = [x(1),0,x(2),0,180,-90; %stay on wall for y=0
                    0,x(3),x(4),0,0,0; %stay on wall where x=0, standard rotation is in YZ plane
                    x(5),x(6),0,0,-90,0]; %stay on on the floor, z=0



%% 2) BEAMFORMING PARAMETERS
mic_coordinates_zxy = NodePosToArrayPos([0 0 0 0 0 0], array_type).';
% Centering the microphone positions. We use the function "rdc.m" which was
% originally intended to remove "DC" of signals. But it works... We use the
% centered microphone array position to generate the steering matrix. 
mic_coordinates(:,1) = rdc(mic_coordinates_zxy(:,2));  
mic_coordinates(:,2) = rdc(mic_coordinates_zxy(:,3));
mic_coordinates(:,3) = rdc(mic_coordinates_zxy(:,1));

decimation_factor = 10;
% Creating matrix of angles to use in the beamforming algorithm
points = eq_point_set(2,(n_steering_angles*2)+2);
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
angles = rad2deg(angles); % angles used for beamforming
size(angles)

% creating frequency bins for steering matrix & beamforming algorithm
n_fft_bins = 101;
freq_min = 20000;
freq_max = 22000;
freqs_fft = linspace(0, fs/decimation_factor, n_fft_bins);
used_freqs = ((freqs_fft >= freq_min)&(freqs_fft <= freq_max));
first_bin = find(used_freqs, 1, 'first');
last_bin = find(used_freqs, 1, 'last');

batch_size = 500;

% creating steering matrix
steering_matrix_freqs = freqs_fft(first_bin:last_bin);
steering_matrix = GenerateSteeringMatrix(mic_coordinates, angles, ...
    steering_matrix_freqs);

%% 3) GENERATING MICROPHONE DATA

% - amplituteOffset    : Amplitute offset in volts
amplitudeOffset = 0;
% - noisePM            : Plus or minus offset of noise amplitude
noisePM = 0;
% - timeVar            : Normal distributed offset in capture start
timeVar = [0 0 0]; % create offset for each node

data = GenerateMicData_V4(audioPS, fs, position_nodes, ...
    sound_locations, amplitudeOffset, noisePM, timeVar, ...
    array_type, decimation_factor, 0);


%% 4) BEAMFORMING CALCULATIONS
n_samples = size(data,1);
n_batch = ceil(n_samples/batch_size);
intersections = zeros(n_batch, 3);
locations = zeros(n_batch, 3);
n_sound_locations = size(sound_locations, 1);
locations_per_batch = n_sound_locations/n_batch;

data_array_1 = data(:,:,1);
data_array_2 = data(:,:,2);
data_array_3 = data(:,:,3);

for i_batch = 1:n_batch
%     fprintf(progress_string);
    current_data_1 = GetBatch(batch_size,i_batch,data_array_1);
    current_data_2 = GetBatch(batch_size,i_batch,data_array_2);
    current_data_3 = GetBatch(batch_size,i_batch,data_array_3);

    power1 = BeamformData(current_data_1, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    power2 = BeamformData(current_data_2, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    power3 = BeamformData(current_data_3, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    
    [~, max_index] = max(power1);
    dir1_d = [angles(1,max_index) angles(2,max_index)];
    [~, max_index] = max(power2);
    dir2_d = [angles(1,max_index) angles(2,max_index)];
    [~, max_index] = max(power3);
    dir3_d = [angles(1,max_index) angles(2,max_index)];
    
    directions = [dir1_d; dir2_d; dir3_d];
    
    vectors = AnglesToVectors(position_nodes, directions);
    [x,y,z] = VectorsToIntersection(vectors);
    intersections(i_batch,:) = [x,y,z];
    loc_index = ceil(i_batch*locations_per_batch);
    locations(i_batch,:) = [sound_locations(loc_index,1), sound_locations(loc_index,2), sound_locations(loc_index,3)];
end

%% 5) calculating average error
error_beams = zeros(n_batch, 1);
for i_batch = 1:n_batch
    error_beams(i_batch) = norm(locations(i_batch,:) - intersections(i_batch,:));
end
mean_error = mean(error_beams);


%% 6) PLOTTING ROOM
if plot_room
    fprintf("6: Plotting Room");
    
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
    
    % plotting path mosquito
    scatter3(sound_locations(:,1), sound_locations(:,2), sound_locations(:,3), 'MarkerFaceColor', [0 0 1], 'Marker','.');
    
    % plotting microphone arrays
    for node_i = 1:size(position_nodes,1)
        array = NodePosToArrayPos(position_nodes(node_i,:), array_type);
        scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [1 0 0]);
    end
    
    % plotting calculated points of mosquito
    scatter3(intersections(:,1), intersections(:,2),intersections(:,3), 'MarkerFaceColor', [0 1 0], 'Marker','.');
    
    legend('Path Mosquito', 'Array 1', 'Array 2', 'Array 3','Calculated Points');
    view(20,20);
end

end

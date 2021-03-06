close all;
clear;
clc;

%% SUMMARY
% This is a script to load the workspace parameters for the main_model.
% (first run this script before you run the model). Before you run the
% model, you need to have the model data stored in the folder "Model_Data".
% To generate the microphone data, put the boolean below on 1. Make sure
% you set your folder to the "Simulink_Model" folder and add to whole
% folder & subfolders to the path. 

% check if you are in the right working directory
dirs = split(string(pwd), "\");
current_folder_name = dirs(end);
if ~strcmp(current_folder_name, "Simulink_Model")
    fprintf("Set your working directory to 'Simulink_Model' to " + ...
        "run the script correctly!\nScript was aborted...\n");
    return
end
% Adding folders to path
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));

GENERATE_MIC_DATA = 0; % 0 if it is already genenerated.
PLOT_ROOM = 1; % plot the room with arrays and sound locations.

%% 1) ROOM DIMENSIONS
% For the room dimensions we assume cartesian coordinates in the following
% form: [X Y Z]. X = length, Y = width, Z = height. The units are meters. 
% ORIGIN/REFERENCE POINT: [0 0 0]
% SIZE: We assume a box shaped room with size equal to the dimensions. This
% means that the origin is located in the corner of the room. 
room_dimensions = [5 5 2.5]; 

% Position of the mic arrays is expressed as 6-DOF data. The nodes are 
% positioned in a triangle on the floor. (angles are in degrees)
% Important notice: the arrays only detect in a forward derection.
% Therefore we turn them -90 degrees so that they lay flat on the floor. 

% old positions
% position_array_1 = [1.5 1.5 0 0 -90 0];
% position_array_2 = [1.5 3.5 0 0 -90 0];
% position_array_3 = [3.5 2.5 0 0 -90 0];
% position_nodes = [position_array_1; position_array_2; position_array_3];

% genatic algorithm positions
GAcoord = [1.94301535766637
1.48902501987710
2.89671110827014
0.916151102191052
3.92750935197575
2.47471735300402];

position_nodes = [GAcoord(1),0,GAcoord(2),0,180,-90; %stay on wall for y=0
                    0,GAcoord(3),GAcoord(4),0,0,0; %stay on wall where x=0, standard rotation is in YZ plane
                    GAcoord(5),GAcoord(6),0,0,-90,0]; %stay on on the floor, z=0

%% 2) BEAMFORMING PARAMETERS
% Positions of the microphones of one array.
array_type = 7; % used array type, 7 = circle array of 8 mics
mic_coordinates_zxy = NodePosToArrayPos([0 0 0 0 0 0], array_type).';
% Centering the microphone positions. We use the function "rdc.m" which was
% originally intended to remove "DC" of signals. But it works... We use the
% centered microphone array position to generate the steering matrix. 
mic_coordinates(:,1) = rdc(mic_coordinates_zxy(:,2));  
mic_coordinates(:,2) = rdc(mic_coordinates_zxy(:,3));
mic_coordinates(:,3) = rdc(mic_coordinates_zxy(:,1));

clear mic_coordinates_zxy;

% Loading audio properties
% audio.filename = 'sound_signal_short_20-22kHz.wav';
audio.filename = 'sound_signal_20-22kHz_high_fs.wav';

% Beamforming constants
v_sound = 343; % speed of sound in m/s

% Creating matrix of angles to use in the beamforming algorithm
points = eq_point_set(2,8001);
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
angles = rad2deg(angles); % angles used for beamforming

% For loading a randomly mosquito path
% path_data = load('Model_Data\Mosquito_path\mosquitoopath_X_Y_Z_5_5_2.5.mat'); % 0
% path_data = load('Model_Data\Mosquito_path\1_xyz_1,1,1_random_10,12,15.mat'); % 1
% path_data = load('Model_Data\Mosquito_path\2_xyz_1,1,2_random_14,31,11.mat'); % 2
path_data = load('Model_Data\Mosquito_path\3_xyz_1,2,1_random_7,5,3.mat'); % 3
% path_data = load('Model_Data\Mosquito_path\4_xyz_2,1,1_random_4,8,9.mat'); % 4
% path_data = load('Model_Data\Mosquito_path\5_xyz_2,3,1_random_81,123,156.mat'); % 5
% path_data = load('Model_Data\Mosquito_path\6_xyz_5,5,2.5_random_142,95,36.mat'); % 6

n_locations = size(path_data.data{1}.Values.Data,1);
sound_location = zeros(n_locations, 3);
sound_location(:,1) = path_data.data{1}.Values.Data;
sound_location(:,2) = path_data.data{2}.Values.Data;
sound_location(:,3) = path_data.data{3}.Values.Data;

% % For locations spread evenly in the room
% sound_location = GenerateRoomLocations(room_dimensions, 0.7, 0);
% n_locations = size(sound_location, 1);

% creating frequency bins for steering matrix & beamforming algorithm
n_fft_bins = 101;
freq_min = 20000;
freq_max = 22000;
freqs_fft = linspace(0, 50000, n_fft_bins);
used_freqs = ((freqs_fft >= freq_min)&(freqs_fft <= freq_max));
first_bin = find(used_freqs, 1, 'first');
last_bin = find(used_freqs, 1, 'last');

batch_size = 2500;

% creating steering matrix
steering_matrix_freqs = freqs_fft(first_bin:last_bin);
steering_matrix = GenerateSteeringMatrix(mic_coordinates, angles, ...
    steering_matrix_freqs);

%% 3) GENERATING MICROPHONE DATA
% We only need to generate the data if it is not already stored in the
% folder "Model_Data > Microphone_Data > data_array_X". 
if GENERATE_MIC_DATA
    % Check if the right folder exists (and make it if not so)
    if ~exist('Model_Data/Microphone_Data', 'dir')
       mkdir Model_Data Microphone_Data;
       addpath('Model_Data/Microphone_Data');
    end
    
    [base_sound, fs] = audioread(audio.filename);
    
    % - amplituteOffset    : Amplitute offset in volts
    amplitudeOffset = 0;
    % - noisePM            : Plus or minus offset of noise amplitude
    noisePM = 0;
    % - timeVar            : Normal distributed offset in capture start
    timeVar = [0 0 0]; % create offset for each node
    
    
    array_data = GenerateMicData_V4(base_sound, fs, position_nodes, ...
        sound_location, amplitudeOffset, noisePM, timeVar, ...
        array_type, 10, 1);
end

%% 4) LOADING MICROPHONE DATA

data_large_1 = audioread('Model_Data/Microphone_Data/data_array_1/capture.wav');
data_large_2 = audioread('Model_Data/Microphone_Data/data_array_2/capture.wav');
data_large_3 = audioread('Model_Data/Microphone_Data/data_array_3/capture.wav');

print_counter = 1;


info = audioinfo('Model_Data/Microphone_Data/data_array_1/capture.wav');
audio.samp_rate = info.SampleRate; % normally 50kHz
audio.n_samples = info.TotalSamples; 
audio.duration = audio.n_samples/audio.samp_rate;
audio.path = info.Filename;

n_batch = ceil(audio.n_samples/batch_size);
intersections = zeros(n_batch, 3);
locations = zeros(n_batch, 3);
locations_per_batch = n_locations/n_batch;

% plotting stuff
[ azMatES, elMatES ] = meshgrid( -90:1:90, -90:1:90 );
[ txLAEAP, tyLAEAP ] = laeap( -90:1:90, -90:1:90 );
[txVertical, tyVertical] = laeap(-90:30:90, -90:5:90);
[txHorizontal, tyHorizontal] = laeap(-90:5:90, -90:30:90);
print_batches = [200 1200 3000 4500]; % put in batch number you want to plot in detail

for i_batch = 1:n_batch
    current_data_1 = GetBatch(batch_size,i_batch,data_large_1);
    current_data_2 = GetBatch(batch_size,i_batch,data_large_2);
    current_data_3 = GetBatch(batch_size,i_batch,data_large_3);

    power1 = BeamformData(current_data_1, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    power2 = BeamformData(current_data_2, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    power3 = BeamformData(current_data_3, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    
    [max_val_p1, max_index] = max(power1);
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
    locations(i_batch,:) = [sound_location(loc_index,1), sound_location(loc_index,2), sound_location(loc_index,3)];
    
    if sum(print_batches==print_counter)>0
        fprintf("Angles of batch: "+i_batch+"\n");
        timepoint = (i_batch/n_batch)*audio.duration;
        figure;
        hold on; 
        grid on; 
        xlabel('x [m]'); 
        ylabel('y [m]'); 
        zlabel('z [m]'); 
        axis equal;
        xlim([0 room_dimensions(1)]);
        ylim([0 room_dimensions(2)]);
        zlim([0 room_dimensions(3)]);
        % all nodes
        scatter3(position_nodes(:,1), position_nodes(:,2),position_nodes(:,3), 'MarkerFaceColor', [1 0 0]);
        scatter3(position_nodes(1,1), position_nodes(1,2),position_nodes(1,3), 150, 'MarkerEdgeColor', [1 0 1]);
        % direction of nodes
        quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6),5);
        % line pointed by nodes
        scatter3(x, y, z, 'MarkerFaceColor', [0 1 0]);
        % current point
        scatter3(sound_location(loc_index,1), sound_location(loc_index,2), sound_location(loc_index,3), 'MarkerFaceColor', [0 0 1]);
        view(20,20);
        current_difference = norm(locations(i_batch,:) - intersections(i_batch,:));
        error_string = "Direction Beamforming Arrays at "+string(timepoint)+"s";
        title(error_string);
        legend('Position Nodes', 'First Node', 'Directions', 'calculated point', 'actual point');
        hold off;
        
        %% plot steering array 1
        power1_db = 10*log10(power1(:)./max_val_p1);
        
        %subplot(1,2,2);
        figure;
        interpolatorES = scatteredInterpolant(squeeze(angles(1,:))', squeeze(angles(2,:))', power1_db(:));
        cla;
        hp = pcolor( txLAEAP, tyLAEAP, interpolatorES( azMatES, elMatES ));
        set( hp, 'linestyle', 'none' )
        set(hp, 'CDataMode', 'manual')
        axis equal
        axis tight
        ylabel("Energy in dB (relative to maximum value)");
        xlabel("Degrees");
        hold on;
        plot(txVertical, tyVertical, '-k');
        plot(txHorizontal', tyHorizontal', '-k');
        hold off;
        axis off
        
        title_string = "Energy Angles array 1 at "+string(timepoint)+"s (Positioned at Y=0)";
        title( title_string )
        colormap default
        colorbar;
        drawnow;
        
%         %% plot steering array 2        
%         interpolatorES = scatteredInterpolant(squeeze(angles(1,:))', squeeze(angles(2,:))', power2(:));
%         figure;
%         cla;
%         hp = pcolor( txLAEAP, tyLAEAP, interpolatorES( azMatES, elMatES ));
%         set( hp, 'linestyle', 'none' )
%         set(hp, 'CDataMode', 'manual')
%         axis equal
%         axis tight
%         hold on;
%         plot(txVertical, tyVertical, '-k');
%         plot(txHorizontal', tyHorizontal', '-k');
%         hold off;
%         axis off
%         title_string = "Batch "+ string(i_batch)+", Energy Angles array 2 (X=0)";
%         title( title_string )
%         colormap default
%         colorbar;
%         drawnow;
%
%         %% plot steering array 3 
%         interpolatorES = scatteredInterpolant(squeeze(angles(1,:))', squeeze(angles(2,:))', power3(:));
%         figure;
%         hp = pcolor( txLAEAP, tyLAEAP, interpolatorES( azMatES, elMatES ));
%         set( hp, 'linestyle', 'none' )
%         set(hp, 'CDataMode', 'manual')
%         axis equal
%         axis tight
%         hold on;
%         plot(txVertical, tyVertical, '-k');
%         plot(txHorizontal', tyHorizontal', '-k');
%         hold off;
%         axis off
%         title_string = "Batch "+ string(i_batch)+", Energy Angles array 3 (Z=0)";
%         title( title_string )
%         colormap default
%         colorbar;
%         drawnow;
        
    end
    print_counter = print_counter + 1;
end


%% 7) PLOTTING ROOM
if PLOT_ROOM
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
    scatter3(sound_location(:,1), sound_location(:,2), sound_location(:,3), 'MarkerFaceColor', [0 0 1], 'Marker','.');
    
    % plotting microphone arrays
    for node_i = 1:size(position_nodes,1)
        array = NodePosToArrayPos(position_nodes(node_i,:), array_type);
        scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [1 0 0]);
    end
    
    % plotting calculated points of mosquito
    scatter3(intersections(:,1), intersections(:,2),intersections(:,3), 'MarkerFaceColor', [0 1 0], 'Marker','.');
    
    % plot camera
    % plot laser
    legend('Path Mosquito', 'Array 1', 'Array 2', 'Array 3');
    view(20,20);
end

%% 8) calculating average error
error_beams = zeros(n_batch, 1);
for i_batch = 1:n_batch
    error_beams(i_batch) = norm(locations(i_batch,:) - intersections(i_batch,:));
end

median_error = median(error_beams);
mean_error = mean(error_beams);
std_error = std(error_beams);

fprintf('The error mean was: '+string(mean_error)+' meters.\n');
fprintf('The error standard deviation was: '+string(std_error)+' meters.\n');
fprintf('The error median was: '+string(median_error)+' meters.\n');

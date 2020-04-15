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
position_array_1 = [1.5 1.5 0 0 -90 0];
position_array_2 = [1.5 3.5 0 0 -90 0];
position_array_3 = [3.5 2.5 0 0 -90 0];
position_nodes = [position_array_1; position_array_2; position_array_3];

%% 2) BEAMFORMING PARAMETERS
% Positions of the microphones of one array.
load('mic_pos_sonar_stm32_dense.mat'); % dimensions are in millimeter
mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ]; % in meter
array_type = 5; % used array type, 5 = dense array

% Centering the microphone positions. We use the function "rdc.m" which was
% originally intended to remove "DC" of signals. But it works... We use the
% centered microphone array position to generate the steering matrix. 
mic_coordinates(:,1) = rdc(mic_coordinates(:,1));  
mic_coordinates(:,2) = rdc(mic_coordinates(:,2));
mic_coordinates(:,3) = rdc(mic_coordinates(:,3));

% Loading audio properties
audio.filename = 'sound_signal_20-22kHz.wav';
info = audioinfo(audio.filename);
audio.samp_rate = info.SampleRate; % normally 50kHz
audio.n_samples = info.TotalSamples; 
audio.duration = audio.n_samples/audio.samp_rate;
audio.path = info.Filename;

% Beamforming constants
v_sound = 343; % speed of sound in m/s

% Creating matrix of angles to use in the beamforming algorithm
points = eq_point_set(2,500);
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
angles = rad2deg(angles); % angles used for beamforming

% location of the sound
path_data = load('Model_Data\mosquitoopath_X_Y_Z_5_5_2.5.mat');
path_x = path_data.data{1}.Values.Data;
path_y = path_data.data{2}.Values.Data;
path_z = path_data.data{3}.Values.Data;

n_locations = size(path_x,1);
sound_location = zeros(n_locations, 3);
sound_location(:,1) = path_x;
sound_location(:,2) = path_y;
sound_location(:,3) = path_z;

% creating frequency bins for steering matrix & beamforming algorithm
n_fft_bins = 101;
freq_min = 20000;
freq_max = 22000;
freqs_fft = linspace(0, audio.samp_rate, n_fft_bins);
used_freqs = ((freqs_fft >= freq_min)&(freqs_fft <= freq_max));
first_bin = find(used_freqs, 1, 'first');
last_bin = find(used_freqs, 1, 'last');

batch_size = 500;

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
    
    
    GenerateMicData_V3(base_sound, fs, position_nodes, ...
        sound_location, amplitudeOffset, noisePM, timeVar, ...
        array_type);
end
%% 4) LOADING MICROPHONE DATA

data_large_1 = audioread('Model_Data/Microphone_Data/data_array_1/capture.wav');
data_large_2 = audioread('Model_Data/Microphone_Data/data_array_2/capture.wav');
data_large_3 = audioread('Model_Data/Microphone_Data/data_array_3/capture.wav');
print_counter = 501;

n_batch = ceil(audio.n_samples/batch_size);
intersections = zeros(n_batch, 3);
locations = zeros(n_batch, 3);
locations_per_batch = n_locations/n_batch;

for i_batch = 1:n_batch
    current_data_1 = GetBatch(batch_size,i_batch,data_large_1);
    current_data_2 = GetBatch(batch_size,i_batch,data_large_2);
    current_data_3 = GetBatch(batch_size,i_batch,data_large_3);

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
    locations(i_batch,:) = [sound_location(loc_index,1), sound_location(loc_index,2), sound_location(loc_index,3)];
    
    if print_counter == 1000
        print_counter = 0;
        fprintf("Angles of batch: "+i_batch+"\n");
        
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
        % all nodes
        scatter3(position_nodes(:,1), position_nodes(:,2),position_nodes(:,3), 'MarkerFaceColor', [1 0 0]);
        % direction of nodes
        quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6));
        % line pointed by nodes
        scatter3(x, y, z, 'MarkerFaceColor', [0 1 0]);
        % current point
        scatter3(sound_location(loc_index,1), sound_location(loc_index,2), sound_location(loc_index,3), 'MarkerFaceColor', [0 0 1]);
        view(20,20);
        current_difference = norm(locations(i_batch,:) - intersections(i_batch,:));
        error_string = "Difference = "+string(current_difference)+" meter.";
        title(error_string);
        legend('Position Nodes', 'Directions', 'calculated point', 'actual point');
    end
    print_counter = print_counter + 1;
end


%% 5) SERVOS & LASERS

%% 6) HUMAN DETECTION SYSTEM

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
mean_error = median(error_beams);
fprintf('The error median was: '+string(mean_error)+' meters.\n');

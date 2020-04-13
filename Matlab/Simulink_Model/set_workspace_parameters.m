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
% positioned in a triangle on the floor.
% position_array_1 = [1 1 0 0 -90 0];
% position_array_2 = [1 4 0 0 -90 0];
% position_array_3 = [4 1 0 0 -90 0];

position_array_1 = [0 1 0 0 -90 0];
position_array_2 = [0 2.5 0 0 -90 0];
position_array_3 = [0 4 0 0 -90 0];
position_nodes = [position_array_1; position_array_2; position_array_3];

%% 2) BEAMFORMING PARAMETERS
% Positions of the microphones of one array.
load('mic_pos_sonar_stm32_dense.mat'); % dimensions are in millimeter
mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ]; % in meter
% used array type, 5 = dense array
array_type = 5;

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
n_locations = 100;
sound_location = zeros(n_locations, 3);
sound_location(:,1) = ones(1,n_locations).*2;
sound_location(:,2) = linspace(0,5,n_locations);
sound_location(:,3) = ones(1,n_locations).*1;

% creating frequency bins for steering matrix & beamforming algorithm
n_fft_bins = 101;
freq_min = 20000;
freq_max = 22000;
freqs_fft = linspace(0, audio.samp_rate, n_fft_bins);
used_freqs = ((freqs_fft >= freq_min)&(freqs_fft <= freq_max));
first_bin = find(used_freqs, 1, 'first');
last_bin = find(used_freqs, 1, 'last');

% creating steering matrix
steering_matrix_freqs = freqs_fft(first_bin:last_bin);
steering_matrix = GenerateSteeringMatrix(mic_coordinates, angles, ...
    steering_matrix_freqs);

% calculating the number of samples for one beamforming step
audio.samples_per_batch = 500;

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
    
    
    % - pulseFreqVar       : Normal distributed deviation of start and 
    % end frequency in Hz
    pulseFreqVar = 1;
    % - amplituteOffset    : Amplitute offset in volts
    amplitudeOffset = 0;
    % - noisePM            : Plus or minus offset of noise amplitude
    noisePM = 0;
    % - timeVar            : Normal distributed offset in capture start
    timeVar = [0 0 0]; % create offset for each node
    
    
    GenerateMicData_V2(base_sound, fs, position_nodes, ...
        sound_location, amplitudeOffset, noisePM, timeVar, ...
        array_type, audio.samples_per_batch);
end

%% 4) LOADING MICROPHONE DATA
data_cell = load('Model_Data/Microphone_Data/data_array_1/capture.mat');
data_large_1 = data_cell.storeData;

data_cell = load('Model_Data/Microphone_Data/data_array_2/capture.mat');
data_large_2 = data_cell.storeData;

data_cell = load('Model_Data/Microphone_Data/data_array_3/capture.mat');
data_large_3 = data_cell.storeData;

print_counter = 501;


n_loops = size(data_large_1,1);
intersections = zeros(n_loops, 3);
locations = zeros(n_loops, 3);
locations_per_loop = n_locations/n_loops;

for index = 1:n_loops
    current_data_1 = squeeze(data_large_1(index,:,:)).';
    current_data_2 = squeeze(data_large_2(index,:,:)).';
    current_data_3 = squeeze(data_large_3(index,:,:)).';

    power1 = BeamformData(current_data_1, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    power2 = BeamformData(current_data_2, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    power3 = BeamformData(current_data_3, steering_matrix, n_fft_bins, first_bin, last_bin, angles);
    
    [~, max_index] = max(power1);
    dir1_d = [angles(1,max_index) angles(2,max_index)];
    [~, max_index] = max(power2);
    dir2_d = [angles(1,max_index) angles(2,max_index)];
    [~, max_index] = max(power3);
    dir3_d = [angles(1,max_index) angles(2,max_index)];
   
    
    
    dir1 = deg2rad(dir1_d);
    dir2 = deg2rad(dir2_d);
    dir3 = deg2rad(dir3_d);
    directions = [dir1; dir2; dir3];
    
    vectors = AnglesToVectors(position_nodes, directions);
    [x,y,z] = VectorsToIntersection(vectors);
    intersections(index,:) = [x,y,z];
    loc_index = ceil(index*locations_per_loop);
    locations(index,:) = [sound_location(loc_index,1), sound_location(loc_index,2), sound_location(loc_index,3)];
    
    if print_counter == 1000
        print_counter = 0;
        fprintf("Angles of batch: "+index+"\n");
        
        figure;
        hold on; 
        grid on; 
        xlabel('x'); 
        ylabel('y'); 
        zlabel('z'); 
        axis equal;
        xlim([0 room_dimensions(1)+2]);
        ylim([0 room_dimensions(2)+2]);
        zlim([0 room_dimensions(3)+2]);
        % all nodes
        scatter3(position_nodes(:,1), position_nodes(:,2),position_nodes(:,3), 'MarkerFaceColor', [1 0 0]);
        % direction of nodes
        quiver3(vectors(:,1), vectors(:,2), vectors(:,3), vectors(:,4), vectors(:,5), vectors(:,6));
        % line pointed by nodes
        scatter3(x, y, z, 'MarkerFaceColor', [0 1 0]);
        % current point
        scatter3(sound_location(loc_index,1), sound_location(loc_index,2), sound_location(loc_index,3), 'MarkerFaceColor', [0 0 1]);
        view(20,20);
        current_difference = norm(locations(index,:) - intersections(index,:));
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
    xlim([0 room_dimensions(1)+2]);
    ylim([0 room_dimensions(2)+2]);
    zlim([0 room_dimensions(3)+2]);
    
    % plotting path mosquito
    scatter3(sound_location(:,1), sound_location(:,2), sound_location(:,3), 'MarkerFaceColor', [0 0 1]);
    
    % plotting microphone arrays
    for node_i = 1:size(position_nodes,1)
        array = NodePosToArrayPos(position_nodes(node_i,:), array_type);
        scatter3(array(1,:), array(2,:), array(3,:), 'MarkerFaceColor', [0 0 1]);
    end
    
    % plotting calculated points of mosquito
    scatter3(intersections(:,1), intersections(:,2),intersections(:,3), 'MarkerFaceColor', [0 1 0]);
    
    % plot camera
    % plot laser
    legend('Sound Locations', 'Array Positions', 'Points');
    view(20,20);
end

%% 8) calculating average error
error_beams = zeros(n_loops, 1);
for index = 1:n_loops
    error_beams(index) = norm(locations(index,:) - intersections(index,:));
end
mean_error = mean(error_beams);
fprintf('The mean error was: '+string(mean_error)+' meters.\n');

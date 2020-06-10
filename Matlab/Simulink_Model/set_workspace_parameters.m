close all;
clear;
clc;

%% SUMMARY
% This is a script to load the workspace parameters for the main_model.
% (first run this script before you run the model). Before you run the
% model, you need to have the model data stored in the folder "Model_Data".
% To generate the microphone data, put the boolean below on 1. Make sure
% you set your folder to the "Simulink_Model" folder. 

% check if you are in the right working directory
dirs = split(string(pwd), "\");
current_folder_name = dirs(end);
if ~strcmp(current_folder_name, "Simulink_Model")
    fprintf("Set your working directory to 'Simulink_Model' to " + ...
        "run the script correctly!\nScript was aborted...\n");
    return
end

% printing progress
fprintf("Setting workspace variables...\n");

% Adding folders to path
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));

GENERATE_MIC_DATA = 1; % 0 if it is already genenerated.
PLOT_ROOM = 1; % plot the room with arrays and sound locations.

% clearing worskpace
clear dirs folder current_folder_name;

%% 1) ROOM SIZE & POSITIONS
% printing progress
fprintf("Loading room/position data...\n");

% For the room dimensions we assume cartesian coordinates in the following
% form: [X Y Z]. X = length, Y = width, Z = height. The units are meters. 
% ORIGIN/REFERENCE POINT: [0 0 0]
% SIZE: We assume a box shaped room with size equal to the dimensions. This
% means that the origin is located in the corner of the room. 
pos.room_size = [5 5 2.5]; 

% Position of the mic arrays is expressed as 6-DOF data. The nodes are 
% positioned in a triangle on the floor. (BF.angles are in degrees)
% Important notice: the arrays only detect in a forward derection.
% Therefore we turn them -90 degrees so that they lay flat on the floor. 

% % old positions
% pos.array_1 = [1.5 1.5 0 0 -90 0];
% pos.array_2 = [1.5 3.5 0 0 -90 0];
% pos.array_3 = [3.5 2.5 0 0 -90 0];
% pos.arrays = [pos.array_1; pos.array_2; pos.array_3];

% new positions (GA optimized)
GAcoord = [1.94301535766637 1.48902501987710 2.89671110827014 0.916151102191052 3.92750935197575 2.47471735300402];
pos.arrays = [GAcoord(1),0,GAcoord(2),0,180,-90;  %stay on wall for y=0
              0,GAcoord(3),GAcoord(4),0,0,0;      %stay on wall where x=0, standard rotation is in YZ plane
              GAcoord(5),GAcoord(6),0,0,-90,0];   %stay on on the floor, z=0

pos.camera = [0.1 0.1 0.1 0 0 0];

pos.laser = [0.1 0.1 0.1 0 0 0];

% location of the sound
% For loading a randomly mosquito path
% path_data = load('Model_Data\Mosquito_path\mosquitoopath_X_Y_Z_5_5_2.5.mat'); % 0
% path_data = load('Model_Data\Mosquito_path\1_xyz_1,1,1_random_10,12,15.mat'); % 1
% path_data = load('Model_Data\Mosquito_path\2_xyz_1,1,2_random_14,31,11.mat'); % 2
path_data = load('Model_Data\Mosquito_path\3_xyz_1,2,1_random_7,5,3.mat'); % 3
% path_data = load('Model_Data\Mosquito_path\4_xyz_2,1,1_random_4,8,9.mat'); % 4
% path_data = load('Model_Data\Mosquito_path\5_xyz_2,3,1_random_81,123,156.mat'); % 5
% path_data = load('Model_Data\Mosquito_path\6_xyz_5,5,2.5_random_142,95,36.mat'); % 6

pos.n_sound_locations = size(path_data.data{1}.Values.Data,1);
pos.sound_locations = zeros(pos.n_sound_locations, 3);
pos.sound_locations(:,1) = path_data.data{1}.Values.Data;
pos.sound_locations(:,2) = path_data.data{2}.Values.Data;
pos.sound_locations(:,3) = path_data.data{3}.Values.Data;

% % For locations spread evenly in the room
% pos.sound_locations = GenerateRoomLocations(room_dimensions, 0.7, 0);
% pos.n_sound_locations = size(sound_location, 1);

% clearing workspace
clear path_data GAcoord;

%% 2) BEAMFORMING PARAMETERS
% printing progress
fprintf("Loading beamforming parameters...\n");

% Positions of the microphones of one array.
BF.array_type = 7; % used array type, 7 = circular array 8 mics
mic_coordinates_zxy = NodePosToArrayPos([0 0 0 0 0 0], BF.array_type).';

% Centering the microphone pos. We use the function "rdc.m" which was
% originally intended to remove "DC" of signals. But it works... We use the
% centered microphone array position to generate the steering matrix. 
BF.mic_coordinates(:,1) = rdc(mic_coordinates_zxy(:,2));  
BF.mic_coordinates(:,2) = rdc(mic_coordinates_zxy(:,3));
BF.mic_coordinates(:,3) = rdc(mic_coordinates_zxy(:,1));

BF.array_size = size(BF.mic_coordinates, 1);

% Loading audio properties
BF.audio_filename = 'sound_signal_20-22kHz_high_fs.wav';
% BF.audio_filename = 'sound_signal_short_20-22kHz.wav';
audio_info = audioinfo(BF.audio_filename);
BF.samp_rate = audio_info.SampleRate; % normally 50kHz
BF.n_samples = audio_info.TotalSamples; 
BF.duration = BF.n_samples/BF.samp_rate;
BF.path = audio_info.Filename;

% Creating matrix of BF.angles to use in the beamforming algorithm
points = eq_point_set(2,8001);
[azimuths,elevations,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuths>-pi/2 & azimuths<pi/2);
BF.angles = [azimuths(indicesHalfShere); elevations(indicesHalfShere)];
BF.angles = rad2deg(BF.angles); % BF.angles used for beamforming

% creating frequency bins for steering matrix & beamforming algorithm
BF.n_fft_bins = 101;
BF.freq_min = 20000;
BF.freq_max = 22000;
BF.freqs_fft = linspace(0, BF.samp_rate, BF.n_fft_bins);
BF.used_freqs = ((BF.freqs_fft >= BF.freq_min)&(BF.freqs_fft <= BF.freq_max));
BF.first_bin = find(BF.used_freqs, 1, 'first');
BF.last_bin = find(BF.used_freqs, 1, 'last');

BF.batch_size = 500;

% creating steering matrix
BF.steering_matrix_freqs = BF.freqs_fft(BF.first_bin:BF.last_bin);
BF.steering_matrix = GenerateSteeringMatrix(BF.mic_coordinates, BF.angles, ...
    BF.steering_matrix_freqs);

% clearing worskpace
clear points audio_info azimuths elevations indicesHalfShere ...
    mic_pos_final_pos mic_coordinates_zxy;

BF.model_step = BF.batch_size*(1/BF.samp_rate);

%% 3) GENERATING MICROPHONE DATA

% We only need to generate the data if it is not already stored in the
% folder "Model_Data > Microphone_Data > data_array_X". 
if GENERATE_MIC_DATA
    % printing progress
    fprintf("Generating Microphone Data for beamforming ...\n");
    
    % Check if the right folder exists (and make it if not so)
    if ~exist('Model_Data/Microphone_Data', 'dir')
       mkdir Model_Data Microphone_Data;
       addpath('Model_Data/Microphone_Data');
    end
    
    [base_sound, fs] = audioread(BF.audio_filename);
    
    % - amplituteOffset    : Amplitute offset in volts
    amplitudeOffset = 0;
    % - noisePM            : Plus or minus offset of noise amplitude
    noisePM = 0;
    % - timeVar            : Normal distributed offset in capture start
    timeVar = [0 0 0]; % create offset for each node
    
    
    GenerateMicData_V4(base_sound, fs, pos.arrays, ...
        pos.sound_locations, amplitudeOffset, noisePM, timeVar, ...
        BF.array_type, 10, 1);
    
    % clearing workspace
    clear base_sound fs amplitudeOffset noisePM timeVar;
end
%% 4) LOADING MICROPHONE DATA
% printing progress
fprintf("Loading beamforming data...\n");
data_array_1 = audioread('Model_Data/Microphone_Data/data_array_1/capture.wav');
data_array_2 = audioread('Model_Data/Microphone_Data/data_array_2/capture.wav');
data_array_3 = audioread('Model_Data/Microphone_Data/data_array_3/capture.wav');

%% 5) SERVOS & LASERS
MCU_freq = 1000000;
MCU_timerPrescaler = 16;
MCU_timerDesiredFreq = 50;

Servo_PWM_0_degree = 4.5;
Servo_PWM_180_degree = 10.5;

PF_delay = 0.01;
%% 6) HUMAN DETECTION SYSTEM
% printing progress
fprintf("Loading Human Detection paramaters...\n");
HDS.FOV = 1.0856; % Camera field of view
HDS.camera_orientation = [1 0 0 deg2rad(20)];
HDS.camera_position = [3.5355 0.1 3.3941];
HDS.h_res = 640;
HDS.v_res = 480;

%% 7) PLOTTING ROOM
% printing progress
fprintf("Plotting room ...\n");
if PLOT_ROOM
    figure;
    hold on; 
    grid on; 
    xlabel('x'); 
    ylabel('y'); 
    zlabel('z'); 
    axis equal;
    xlim([0 pos.room_size(1)]);
    ylim([0 pos.room_size(2)]);
    zlim([0 pos.room_size(3)]);
    
    % plotting path mosquito
    scatter3(pos.sound_locations(:,1), pos.sound_locations(:,2), ...
        pos.sound_locations(:,3), 'MarkerFaceColor', [0 0 1], 'Marker','.');
    
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
    
    legend('Path Mosquito', 'Array 1', 'Array 2', 'Array 3', 'Camera', 'Laser');
    view(20,20);
end

% clearing workspace
clear node_i array;

% printing progress
fprintf("Workspace variables set! You can run the model now. \n");

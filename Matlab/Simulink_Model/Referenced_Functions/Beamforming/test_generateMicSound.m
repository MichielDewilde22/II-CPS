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

% Position of the mic arrays is expressed as 6-DOF data. The nodes are 
% positioned in a triangle on the floor.
position_array_1 = [0 1 0 0 0 0];
position_array_2 = [0 2.5 0 0 0 0];
position_array_3 = [0 4 0 0 0 0];
position_nodes = [position_array_1; position_array_2; position_array_3];

% Positions of the microphones of one array.
load('mic_pos_sonar_stm32_dense.mat'); % dimensions are in millimeter
mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ]; % in meter

% Centering the microphone positions. We use the function "rdc.m" which was
% originally intended to remove "DC" of signals. But it works...
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

% location of the sound
n_locations = 100;
sound_location = zeros(n_locations, 3);
sound_location(:,1) = ones(1,n_locations).*2;
sound_location(:,2) = linspace(0,5,n_locations);
sound_location(:,3) = ones(1,n_locations).*1;

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
% type: Dense = 5
array_type = 5;

GenerateMicData_V3(base_sound, fs, position_nodes, ...
        sound_location, amplitudeOffset, noisePM, timeVar, ...
        array_type);
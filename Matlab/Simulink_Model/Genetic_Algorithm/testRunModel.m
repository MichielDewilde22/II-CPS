close all;
clear;
clc;

% TO MAKE IT WORK: add folder "Simulink_Model" and subfolder to path.

room_dimensions = [5 5 2.5]; 

% x(1) = 0;
% x(2) =2.5;
% x(3) =0;
% x(4)=0;
% x(5) = 0;
% x(6)=0;
% x(7)=1.5;
% x(8)=5;
% x(9)=1;
% x(10)=0;
% x(11)=-90;
% x(12)=0;
% x(13)=5;
% x(14)=2.5;
% x(15)=1;
% x(16)=0;%define in radians
% x(17)=90;
% x(18)=0;

position_array_1 = [1.5 1.5 0 0 -90 0];
position_array_2 = [1.5 3.5 0 0 -90 0];
position_array_3 = [3.5 2.5 0 0 -90 0];
position_nodes = [position_array_1; position_array_2; position_array_3];

% location of the sound
% path_data = load('Model_Data\mosquitoopath_X_Y_Z_5_5_2.5.mat');
% 
% n_locations = size(path_data.data{1}.Values.Data,1);
% sound_locations = zeros(n_locations, 3);
% sound_locations(:,1) = path_data.data{1}.Values.Data;
% sound_locations(:,2) = path_data.data{2}.Values.Data;
% sound_locations(:,3) = path_data.data{3}.Values.Data;

% [X,Y,Z] = bresenham_line3d([0,0,0], [5,5,2.5],1);
% 
% n_locations = size(X',1);
% sound_locations = zeros(n_locations, 3);
% sound_locations(:,1) = X';
% sound_locations(:,2) = Y';
% sound_locations(:,3) = Z';

n_locations = 20;
sound_locations = zeros(n_locations, 3);
sound_locations(:,1) = linspace(0, room_dimensions(1), n_locations);
sound_locations(:,2) = linspace(0, room_dimensions(2), n_locations);
sound_locations(:,3) = linspace(0, room_dimensions(3), n_locations);


array_type = 7; % used array type, 7 = circle array of 8 mics

% Loading audio properties
filename = 'sound_signal_short_20-22kHz.wav';
[audioPS, fs] = audioread(filename);

mean_error = runModel(position_nodes, audioPS, fs, 4000, sound_locations, room_dimensions, 7, 0);
fprintf('The error median was: '+string(mean_error)+' meters.\n');

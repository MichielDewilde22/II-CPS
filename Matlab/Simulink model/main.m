close all;
clear;
clc;

%% set parameters
sampleRate = 450000;
speed_sound = 343;

points = eq_point_set(2,500); % 3 x 500 double points (cartesian coords)
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
angles = rad2deg(angles); % angles used for beamforming

load('SavedEScape1.mat');
load( 'Library/mic_pos_sonar_stm32_dense.mat' );
mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ];

mic_coordinates(:,1) = rdc(mic_coordinates(:,1));
mic_coordinates(:,2) = rdc(mic_coordinates(:,2));
mic_coordinates(:,3) = rdc(mic_coordinates(:,3));

wideFrequencies = linspace(20000,100000,81); 

steeringMatrix = appSteeringMatrix('Wide', 'Frequency domain', ...
    sampleRate, mic_coordinates, angles, wideFrequencies);

data_array_1 = EScapes;
n_data_sets = size(EScapes,1);

simulation_time = 20;

fprintf('done');
%% run model
% run main_model.slx

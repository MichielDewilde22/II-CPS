close all;
clc

fprintf("PLOTTING & CALCULATING STATISTICS \n");
fprintf(" 1) Loading Data \n");
%% SUMMARY
% This is a script for plotting simulation data from the main model. 
% REMEMBER TO RUN THE "set_workspace_parameters.m" script first. 

% steps to run this script:
% 1) run the "set_workspace_parameters.m" script
% 2) run the simulation (sub simulations) you want to analyze
% 3) copy the simulation results to the folder /Simulation_Data/plot_data/
% 4) run this script

azFilter_data = load('Simulation_Data\plot_data\degrees_servo_1.mat');
elFilter_data = load('Simulation_Data\plot_data\degrees_servo_2.mat');
azFilter = azFilter_data.ans;
elFilter = elFilter_data.ans;
clear azFilter_data elFilter_data;

azSerial_data = load('Simulation_Data\plot_data\serial_servo_1.mat');
elSerial_data = load('Simulation_Data\plot_data\serial_servo_2.mat');
azSerial = azSerial_data.ans;
elSerial = elSerial_data.ans;
clear azSerial_data elSerial_data;

azServo_data = load('Simulation_Data\plot_data\az_servo.mat');
elServo_data = load('Simulation_Data\plot_data\el_servo.mat');
azServo = azServo_data.ans;
elServo = elServo_data.ans;
clear azServo_dat elServo_data;


sound_location_step_size = (BF.duration / (pos.n_sound_locations-1));
time_sound = 0:sound_location_step_size:BF.duration;

pos_laser = ones(pos.n_sound_locations, 3)*0.1;
norm_pos_mos = [pos.sound_locations(:,1), pos.sound_locations(:,2), pos.sound_locations(:,3)] - pos_laser;

[az_mos, el_mos, dist_mos] = cart2sph(norm_pos_mos(:,1), norm_pos_mos(:,2), norm_pos_mos(:,3));
az_mos_deg = rad2deg(az_mos);
el_mos_deg = rad2deg(el_mos)*(-1) + 90;

figure;
hold on;
grid on;
xlim([0 60]);
ylim([0 120]);
ylabel('Angles [degrees]');
xlabel('Time [seconds]');
title('Azimuth Comparison');

scatter(azFilter.time, azFilter.data, 'Marker','.');
plot(azSerial.time, azSerial.data);
plot(azServo.time, azServo.data);
plot(time_sound', az_mos_deg);
legend("Angles After Filter", "Angles After Serial Comm.", "Angles of Laser", "Actual Angle Mosquito");

figure;
hold on;
grid on;
xlim([0 60]);
ylim([0 120]);
ylabel('Angles [degrees]');
xlabel('Time [seconds]');
title('Elevation Comparison');

scatter(elFilter.time, elFilter.data, 'Marker','.');
plot(elSerial.time, elSerial.data);
plot(elServo.time, elServo.data);
plot(time_sound', el_mos_deg);
legend("Angles After Filter", "Angles After Serial Comm.", "Angles of Laser", "Actual Angle Mosquito");

fprintf("STATISTICS: \n");
fprintf("--------------- \n");
fprintf("Error Beamforming: \n");
fprintf(" - Mean Error:         "+string(mean_error_BF)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_BF)+"m\n");
fprintf(" - Median Error:       "+string(median_error_BF)+"m\n");
fprintf("Error After Filter: \n");
fprintf(" - Mean Error:         "+string(mean_error_filter)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_filter)+"m\n");
fprintf(" - Median Error:       "+string(median_error_filter)+"m\n");
fprintf("Error After Serial Communication: \n");
fprintf(" - Mean Error:         "+string(mean_error_serial)+"m\n");
fprintf(" - Standard Deviation: "+string(std_error_serial)+"m\n");
fprintf(" - Median Error:       "+string(median_error_serial)+"m\n");


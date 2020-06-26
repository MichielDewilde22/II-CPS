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

figure;
hold on;
grid on;
xlim([0 60]);
ylim([0 120]);
ylabel('Angles [degrees]');
xlabel('Time [seconds]');
title('Azimuth Comparison');

plot(azSerial.time, azSerial.data);
plot(azServo.time, azServo.data);
legend("Angles After Serial Comm.", "Angles of Laser");

figure;
hold on;
grid on;
xlim([0 60]);
ylim([0 120]);
ylabel('Angles [degrees]');
xlabel('Time [seconds]');
title('Elevation Comparison');

plot(elSerial.time, elSerial.data);
plot(elServo.time, elServo.data);
legend("Angles After Serial Comm.", "Angles of Laser");



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

xBeam_data = load('Simulation_Data\plot_data\x_beam.mat');
yBeam_data = load('Simulation_Data\plot_data\y_beam.mat');
zBeam_data = load('Simulation_Data\plot_data\z_beam.mat');
xBeam = xBeam_data.ans;
yBeam = yBeam_data.ans;
zBeam = zBeam_data.ans;
clear xBeam_data yBeam_data zBeam_data;

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

% converting mosquito position to azimuth/elevation angle 
sound_location_step_size = (BF.duration / (pos.n_sound_locations-1));
time_sound = 0:sound_location_step_size:BF.duration;

pos_laser = ones(pos.n_sound_locations, 3)*0.1;
norm_pos_mos = [pos.sound_locations(:,1), pos.sound_locations(:,2), pos.sound_locations(:,3)] - pos_laser;

[az_mos, el_mos, dist_mos] = cart2sph(norm_pos_mos(:,1), norm_pos_mos(:,2), norm_pos_mos(:,3));
az_mos_deg = rad2deg(az_mos);
el_mos_deg = rad2deg(el_mos)*(-1) + 90;

% converting beamforming position to azimuth/elevation angle
pos_laser = ones(length(xBeam.time), 3)*0.1;
norm_pos_beam = [xBeam.data, yBeam.data, zBeam.data] - pos_laser;
[az_beam, el_beam, dist_beam] = cart2sph(norm_pos_beam(:,1), norm_pos_beam(:,2), norm_pos_beam(:,3));
az_beam_deg = rad2deg(az_beam);
el_beam_deg = rad2deg(el_beam)*(-1) + 90;

figure;
hold on;
grid on;
xlim([0 60]);
ylim([0 120]);
ylabel('Angles [degrees]');
xlabel('Time [seconds]');
title('Azimuth Comparison');

scatter(xBeam.time, az_beam_deg, 'Marker', '.');
scatter(azFilter.time, azFilter.data, 'Marker','.');
plot(azSerial.time, azSerial.data);
plot(azServo.time, azServo.data);
plot(time_sound', az_mos_deg);
legend("Angles after Beamforming", "Angles After Filter", "Angles After Serial Comm.", "Angles of Laser", "Actual Angle Mosquito");

figure;
hold on;
grid on;
xlim([0 60]);
ylim([0 120]);
ylabel('Angles [degrees]');
xlabel('Time [seconds]');
title('Elevation Comparison');

scatter(xBeam.time, el_beam_deg, 'Marker', '.');
scatter(elFilter.time, elFilter.data, 'Marker','.');
plot(elSerial.time, elSerial.data);
plot(elServo.time, elServo.data);
plot(time_sound', el_mos_deg);
legend("Angles after Beamforming", "Angles After Filter", "Angles After Serial Comm.", "Angles of Laser", "Actual Angle Mosquito");

error_timepoints = 0:0.1:BF.duration;

errors_az_beam = zeros(length(error_timepoints), 1);
errors_el_beam = errors_az_beam;
errors_az_filter = errors_az_beam;
errors_el_filter = errors_az_beam;
errors_az_serial = errors_az_beam;
errors_el_serial = errors_az_beam;
errors_az_laser = errors_az_beam;
errors_el_laser = errors_az_beam;

% calculation of beamforming error
for indx = 1:length(error_timepoints)
    str = "progress: "+string(indx)+" of "+string(length(error_timepoints))+"\n";
    fprintf(str);
    
    timepoint = error_timepoints(indx);
    [~, mos_az_dir] = getNearestPointArray(time_sound, az_mos_deg, timepoint);
    [~, mos_el_dir] = getNearestPointArray(time_sound, el_mos_deg, timepoint);
    
    [~, beam_az_dir] = getNearestPointArray(xBeam.time, az_beam_deg, timepoint);
    [~, beam_el_dir] = getNearestPointArray(xBeam.time, el_beam_deg, timepoint);
    
    [~, filter_az_dir] = getNearestPoint(azFilter, timepoint);
    [~, filter_el_dir] = getNearestPoint(elFilter, timepoint);
    
    [~, serial_az_dir] = getNearestPoint(azSerial, timepoint);
    [~, serial_el_dir] = getNearestPoint(elSerial, timepoint);
    
    [~, laser_az_dir] = getNearestPoint(azServo, timepoint);
    [~, laser_el_dir] = getNearestPoint(elServo, timepoint);
    
    errors_az_beam(indx) = abs(mos_az_dir - beam_az_dir);
    errors_el_beam(indx) = abs(mos_el_dir - beam_el_dir);
    
    errors_az_filter(indx) = abs(mos_az_dir - filter_az_dir);
    errors_el_filter(indx) = abs(mos_el_dir - filter_el_dir);
    
    errors_az_serial(indx) = abs(mos_az_dir - serial_az_dir);
    errors_el_serial(indx) = abs(mos_el_dir - serial_el_dir);
    
    errors_az_laser(indx) = abs(mos_az_dir - laser_az_dir);
    errors_el_laser(indx) = abs(mos_el_dir - laser_el_dir);
end

errors_az_laser = errors_az_laser(4:end);
errors_el_laser = errors_el_laser(4:end);

mean_az_beam = mean(errors_az_beam);
std_az_beam = std(errors_az_beam);

mean_el_beam = mean(errors_el_beam);
std_el_beam = std(errors_el_beam);

mean_az_filter = mean(errors_az_filter);
std_az_filter = std(errors_az_filter);

mean_el_filter = mean(errors_el_filter);
std_el_filter = std(errors_el_filter);

mean_az_serial = mean(errors_az_serial);
std_az_serial = std(errors_az_serial);

mean_el_serial = mean(errors_el_serial);
std_el_serial = std(errors_el_serial);

mean_az_laser = mean(errors_az_laser);
std_az_laser = std(errors_az_laser);

mean_el_laser = mean(errors_el_laser);
std_el_laser = std(errors_el_laser);

fprintf("STATISTICS: \n");
fprintf("--------------- \n");
fprintf("Error Beamforming: \n");
fprintf(" - Azimuth: \n");
fprintf(" -- Mean Error:         "+string(mean_az_beam)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_az_beam)+" degrees \n");
fprintf(" - Elevation: \n");
fprintf(" -- Mean Error:         "+string(mean_el_beam)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_el_beam)+" degrees \n");
fprintf("Error Filter: \n");
fprintf(" - Azimuth: \n");
fprintf(" -- Mean Error:         "+string(mean_az_filter)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_az_filter)+" degrees \n");
fprintf(" - Elevation: \n");
fprintf(" -- Mean Error:         "+string(mean_el_filter)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_el_filter)+" degrees \n");
fprintf("Error Serial: \n");
fprintf(" - Azimuth: \n");
fprintf(" -- Mean Error:         "+string(mean_az_serial)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_az_serial)+" degrees \n");
fprintf(" - Elevation: \n");
fprintf(" -- Mean Error:         "+string(mean_el_serial)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_el_serial)+" degrees \n");
fprintf("Error Laser: \n");
fprintf(" - Azimuth: \n");
fprintf(" -- Mean Error:         "+string(mean_az_laser)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_az_laser)+" degrees \n");
fprintf(" - Elevation: \n");
fprintf(" -- Mean Error:         "+string(mean_el_laser)+" degrees \n");
fprintf(" -- Standard Deviation: "+string(std_el_laser)+" degrees \n");


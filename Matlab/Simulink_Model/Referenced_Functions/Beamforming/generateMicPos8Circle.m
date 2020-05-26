% THIS IS A SCRIPT FOR GENERATING A CIRCULAR MICROPHONE ARRAY
clear all;
close all;
% Half-wavelength: (343/23kHz)/2 =  0,0074568217m
%Distance between mics should be less than half-wavelength
highest_f = 23000;
v = 343;
n_mic = 8;

% circumference = ( (v/highest_f) / 2 ) * n_mic * 0.95;
circumference = 0.05;

% creating array of angles between 0 and 2*pi
angles = linspace(0, 2*pi, n_mic+1);
angles = angles(1:end-1);

% creating points
X = (circumference/2)*cos(angles);
Y = (circumference/2)*sin(angles);

mic_pos_centered = [zeros(1,n_mic);X;Y];
mic_pos_cornered = [zeros(1,n_mic);X+(circumference/2);Y+(circumference/2)];
figure;
scatter(mic_pos_centered(2,:), mic_pos_centered(3,:));
hold on;
scatter(mic_pos_cornered(2,:), mic_pos_cornered(3,:));
hold off;
legend('centered','cornered');

save('mic_pos_centered');
save('mic_pos_cornered');

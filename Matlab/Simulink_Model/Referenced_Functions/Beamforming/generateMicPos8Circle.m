% THIS IS A SCRIPT FOR GENERATING A CIRCULAR MICROPHONE ARRAY
clear all;
close all;
%Half-wavelength: (343/21kHz)/2 =  0,0082m
%Distance between mics should be less than half-wavelength
mic_dist = 0.05;
n_mic = 8;

% creating array of angles between 0 and 2*pi
angles = linspace(0, 2*pi, n_mic+1);
angles = angles(1:end-1);

% creating points
X = (mic_dist/2)*cos(angles);
Y = (mic_dist/2)*sin(angles);

mic_pos_centered = [zeros(1,n_mic);X;Y];
mic_pos_cornered = [zeros(1,n_mic);X+(mic_dist/2);Y+(mic_dist/2)];
figure;
scatter(mic_pos_centered(2,:), mic_pos_centered(3,:));
hold on;
scatter(mic_pos_cornered(2,:), mic_pos_cornered(3,:));
hold off;
legend('centered','cornered');

save('mic_pos_centered');
save('mic_pos_cornered');

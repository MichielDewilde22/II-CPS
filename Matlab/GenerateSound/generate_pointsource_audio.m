%% SCRIPT FOR GENERATING SIGNAL CHANNEL SOUND FOR MOSQUITO
% Afterwards, this 'pointsource' signal will be used to generated multiple
% channels that are received by the microphone array.
close all;
clear;
% SUMMARY:
% We generate a white noise signal which we pass through a bandpass filter
% to create a narrowband signal. 


%% 1) setting paramaters
length_seconds = 60; % length of audio signal
fs = 500000; % sample frequency
freq_low = 20000;
freq_high = 22000;

%% 2) generating white noise signal
n_samples = length_seconds * fs;
data = zeros(n_samples, 1);

% adding white noise
data = awgn(data, 20);

% 
% %% 3) send signal through bandpass filter
data_filtered = bandpass(data,[freq_low freq_high], fs);

% plotting spectrum
f = linspace(0, fs, length(data_filtered));
fft_data = fft(data);
fft_data_filtered = fft(data_filtered);
figure;
plot_spectrum(f, fft_data_filtered, 'filtered data', 'Hz');
figure;
plot_spectrum(f, fft_data, 'data', 'Hz');

%% 4) write to audio file
% audiowrite('test_audio.wav', data, fs);
audiowrite('sound_signal_20-22kHz.wav', data_filtered, fs);

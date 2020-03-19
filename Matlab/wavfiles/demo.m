%% Generate a bat like wav recording

if false
  % - length               : Capture length in seconds
  length = 10;
  % - Fs                   : Sampling frequency in Hertz
  fs = 44100;
  % - nodes                : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
  nodes = [0, 0, 0, 0, 0, 0];
  % - soundLocation        : Matrix of sound locations (Mx3) [X, Y, Z]
  soundLocation = [1, 0, 0; 1, 0, 0.1];
  % - pulseFreqVar         : Normal distributed deviation of start and end frequency in Hz
  pulseFreqVar = 1;
  % - pulseAmplituteOffset : Pulse amplitute offset in volts
  pulseAmplituteOffset = 0;
  % - noisePM              : Plus or minus offset of noise amplitude
  noisePM = 0;
  % - pulseTimeVar         : Variation in pulse timing in seconds
  pulseTimeVar = 0;
  % - radPattern           : Scattered interpolant of the radiation pattern
  radPattern = 0;
  % - timeVar              : Normal distributed offset in capture start
  timeVar = 0.1;

  type = 0;

  generateWavFile_BatStyle(length, fs, nodes, soundLocation, pulseFreqVar, pulseAmplituteOffset, noisePM, pulseTimeVar, radPattern, timeVar, type);
end

%% Generate a drone style wav recording
[baseSound, fs] =   audioread('InputData/parrot_1.wav');
baseSound = baseSound(:,2);
%Fs = ceil(fs/10.2041);     % Resample at 44100 kHz
%baseSound = resample(baseSound(:,2), Fs, fs);

% - nodes                : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
nodes = [0, 0, 0, 0, 0, 0];
% - soundLocation        : Matrix of sound locations (Mx3) [X, Y, Z]

% azimuth sweep from 90 (left) to -90 (right) at elevation 0
nSounds = 100;
x = sin(linspace(0, pi, nSounds));
y = cos(linspace(0, pi, nSounds));
z = zeros(nSounds, 1);
soundLocation = [x', y', z];
%soundLocation = [1, 0, 0; 1, 0, 0.1];

% - pulseFreqVar         : Normal distributed deviation of start and end frequency in Hz
pulseFreqVar = 1;
% - amplituteOffset      : Amplitute offset in volts
amplituteOffset = 0;
% - noisePM              : Plus or minus offset of noise amplitude
noisePM = 0;
% - radPattern           : Scattered interpolant of the radiation pattern
radPattern = 0;
% - timeVar              : Normal distributed offset in capture start
timeVar = 0.1;

type = 1;

generateWavFile_DroneStyle(baseSound, fs, nodes, soundLocation, amplituteOffset, noisePM, radPattern, timeVar, type);



%% Archive 
% Center
%soundLocation = [1, 0, 0];

% azimuth sweep from 90 (left) to -90 (right) at elevation 0
%nSounds = 9;
%x = sin(linspace(0, pi, nSounds));
%y = cos(linspace(0, pi, nSounds));
%z = zeros(1, nSounds);
%soundLocation = [x, y, z];

% elevation sweep from 90 (down) to -90 (up) at azimuth 0
%nSounds = 9;
%x = sin(linspace(0, pi, nSounds));
%y = zeros(nSounds, 1);
%z = cos(linspace(0, pi, nSounds));
%soundLocation = [x', y, z'];

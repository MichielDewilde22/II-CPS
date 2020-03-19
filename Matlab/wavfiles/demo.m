


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

generateWavFile(length, fs, nodes, soundLocation, pulseFreqVar, pulseAmplituteOffset, noisePM, pulseTimeVar, radPattern, timeVar, type);
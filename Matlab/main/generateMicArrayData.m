function arrayData = generateMicArrayData(nodes, soundLocation, usedArray, samplerate)
%% Generate a drone style wav recording
[baseSound, fs] =   audioread('InputData/parrot_1.wav');
baseSound = baseSound(:,2);
%Fs = ceil(fs/10.2041);     % Resample at 44100 kHz
%baseSound = resample(baseSound(:,2), Fs, fs);

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

switch char(usedArray)
    case 'Dense'
        type = 5;
    case 'Sparse'
        type = 6;
end  

tempData = generateWavFile_DroneStyle(baseSound, fs, nodes, soundLocation, amplituteOffset, noisePM, radPattern, timeVar, type);
secDim = size(tempData,1)/samplerate;
arrayData = zeros(samplerate, secDim, size(nodes,1));
for i = 1: size(nodes,1)
    arrayData(:,:,i) = reshape(tempData(:,i), samplerate, secDim);
end
end

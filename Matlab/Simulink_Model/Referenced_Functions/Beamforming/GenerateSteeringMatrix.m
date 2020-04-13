function [A] = GenerateSteeringMatrix(mic_coordinates, angles, frequencies)
%GENERATESTEERINGMATRIX Generates a steering matrix for beamforming.

numMics = size(mic_coordinates, 1); % number of microphones
numFreqBins = size(frequencies,2); % number of frequency bins
numAngles = size(angles,2); % number of angle pairs
A = zeros(numMics,numFreqBins,numAngles);
for freqIt = 1: numFreqBins % For all frequency bins
    lambda = 343 / frequencies(freqIt); % wavelength
    for angleIt = 1: numAngles % For all angles
        thisTheta = angles(1,angleIt); % azimuth
        thisPhi = angles(2,angleIt); % elevation
        for micIt = 1: numMics % For all angles
            PhiX = sind(thisTheta)*cosd(thisPhi)*mic_coordinates(micIt,1); % formulas
            PhiY = sind(thisPhi) * mic_coordinates(micIt,2);
            % Setting a phase shift for each 
            % microphone/angle/frequency value. 
            A(micIt,freqIt,angleIt) = exp(-2*pi*1i* ((PhiX + PhiY) / lambda));
        end
    end
end          
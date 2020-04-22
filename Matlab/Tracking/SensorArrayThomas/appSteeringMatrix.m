function [A] = appSteeringMatrix(band, domain, sampleRate, coord, ...
    angles, wideFrequencies)
%APPSTEERINGMATRIX Generates a steering matrix for beamforming.
%   It sets a phase shift value for each voxel. There are 3 dimensions: 1)
% number of frequency bins, 2) number of angles, 3) number of microphones
% in the array. These are the input values:
% - band: String 'Wide' => wideband, ...
% - domain: String 'Frequency domain' => frequency domain, 'Time domain' =>
% time domain
% - sampleRate => sampleRate of microphones
% - coord => matrix of coordinates of the microphones
% - angles => matrix of angles
% - wideFrequencies => vector of wideband frequency values 
pause(0.1) % no idea why? maybe remove it?
numMics = size(coord, 1); % number of microphones
numFreqBins = size(wideFrequencies,2); % number of frequency bins
numAngles = size(angles,2); % number of angle pairs
switch char(band)
    case 'Wide'
        switch char(domain)
            case 'Frequency domain'
                A = zeros(numMics,numFreqBins,numAngles);
                for freqIt = 1: numFreqBins % For all frequency bins
                    lambda = 343 / wideFrequencies(freqIt); % wavelength
                    for angleIt = 1: numAngles % For all angles
                        thisTheta = angles(1,angleIt); % azimuth
                        thisPhi = angles(2,angleIt); % elevation
                        for micIt = 1: numMics % For all angles
                            PhiX = sind(thisTheta)*cosd(thisPhi)*coord(micIt,1); % formulas
                            PhiY = sind(thisPhi) * coord(micIt,2);
                            % Setting a phase shift for each 
                            % microphone/angle/frequency value. 
                            A(micIt,freqIt,angleIt) = exp(-2*pi*1i* ((PhiX + PhiY) / lambda));
                        end
                    end
                end                   
        end
            case 'Time domain'
                [A, ~, ~ ] = azel_2_delayints( -angles(1,:), -angles(2,:), coord, sampleRate );
            otherwise
                fprintf('Something is wrong, no known beamDomain selected \n');
end
end
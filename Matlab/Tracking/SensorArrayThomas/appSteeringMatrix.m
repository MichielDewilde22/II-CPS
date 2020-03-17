function [A] = appSteeringMatrix(band, domain, sampleRate, coord, angles, wideFrequencies)
pause(0.1)
numMics = size(coord, 1);
switch char(band)
    case 'Wide'
        switch char(domain)
            case 'Frequency domain'
                A = zeros(numMics,81,251);
                for freqIt = 1: size(wideFrequencies,2) %check all frequencies
                    lambda = 343 / wideFrequencies(freqIt); %speed of sound divided by frequency
                    for angleIt = 1: 251
                        thisTheta = angles(1,angleIt);
                        thisPhi = angles(2,angleIt);
                        for micIt = 1: numMics
                            PhiX = sind(thisTheta)*cosd(thisPhi)*coord(micIt,1); %formulas
                            PhiY = sind(thisPhi) * coord(micIt,2);
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
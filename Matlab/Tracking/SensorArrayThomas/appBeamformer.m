function [POWER] = appBeamformer(domain, band, data, A, angles, ...
    algorithm, sensor, spatialSmoothing)
%APPBEAMFORMER This function returns the power for each angle.
%   The functions implements a beamforming algortithm that returns a power 
%   for each given angle in the steering matrix. The input values are:
%   - domain: String 'Time domain' or 'Frequency domain'
%   - band: String 'Wide' of 'Narrow' for wide/narrow-band beamforming
%   - data = recording of size (16384 samples, X microphones {often 32})
%   - steering matrix of size (Frequencies, microphones, angles)
%   - angles: matrix of angles
%   - algorithm: String 'Delay and Sum' or 'MUSIC' beamforming algorithm
%   - sensor = Sparse Array (eRTIS), Dense Array (weirdRTIS), Ultradense
%       Array (muRTIS)
%   - spatialSmoothing: enable/disable spatialSmoothing
    switch char(band)
        case 'Wide'
            switch char(domain) 
                case 'Time domain'
                    E_scape = mex_fast_SpatioTemp_MF_v2( data, A );
                    POWER = E_scape( 1 : 10 : length( data ) ,  : );
                    POWER = sum(abs(POWER));
                    return
                case 'Frequency domain'
                    % do nothing
            end
        case 'Narrow'
            %This can be interesting as well          
    end
    
    switch char(algorithm)
        case 'Delay and Sum'
            % DAS beamforming (FFT is applied in DAS algorithm)
            POWER = delayAndSum(A, data); 
        case 'MUSIC'            
            if spatialSmoothing
                % FBSS MUSIC
                POWER = musicAlgorithmFBSS(A, dataFFT, angles, sensor);
            else
                % Regular MUSIC
                POWER = musicAlgorithm(A, dataFFT, angles);
            end
    end
end
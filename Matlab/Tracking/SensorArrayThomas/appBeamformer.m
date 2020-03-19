%application BEAMFORMER
%   Beamform a given signal in time or frequency domain, wide or narrowband
%   domain = Time domain or Frequency domain
%   band = Wide or Narrow (only applicable to freq domain off course)
%   data = recording of size (16384 samples, X microphones {typically 32})
%   A = steering matrix of size (Frequencies, microphones, angles)
%   angles = all angles, size (2, number of angles)
%   algorithm = used algorithm: DAS or MUSIC
%   sensor = Sparse Array (eRTIS), Dense Array (weirdRTIS), Ultradense
%       Array (muRTIS)
%   spatialsmoothing = is SS applied (true/ false)
function [POWER] = appBeamformer(domain, band, data, A, angles, algorithm, sensor, spatialSmoothing)

    switch char(band)
        case 'Wide'
            switch char(domain) 
                case 'Time domain'
                    E_scape = mex_fast_SpatioTemp_MF_v2( data, A );
                    POWER = E_scape( 1 : 10 : length( data ) ,  : );
                    POWER = sum(abs(POWER));
                    return
                case 'Frequency domain'
                    %Hint: you should do something here
            end
            
        case 'Narrow'
            %This can be interesting as well          
    end
    
    switch char(algorithm)
        case 'Delay and Sum'
            POWER = delayAndSum(A, data, angles); %FFT on data is applied in DaS script
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
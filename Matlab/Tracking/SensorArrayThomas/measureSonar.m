function [DAS] = measureSonar(COMSonar)
%%Script to use the eRTIS as a wideband acoustic camera
%%Different implementations of the beamorming algorithms are used
%%TIME domain: uses matlab beamformer to calculate the delays and spectrum
%%FREQ domain: manual implemented beamforming algorithm that calculates the
%%spectrum for a fixed step of frequencies and adds the result.
%%TODO: Narrowband acoustic camera for dense sensor

    
    %Load libraries and objects
    addpath( genpath( 'library' ) );
    
    %% Cases
       
    TIMEDASMATLAB = 1;
    TIMEDASMEX = 2;
    FREQDASMANUAL = 4;
    SPARSE = 1;
    DENSE = 2;
    ULTRADENSE = 3;
    
    newArch = 0; %faster data gathering: for ultradense only (set automatically)
    
    
    currentCase = TIMEDASMEX;
    micCase = DENSE;
   
%% Setup

    if nargin == 0
        COMSonar = 'COM12';
    end
    
    numDataSamples = 327680;
    sampleRate = 450e3;
    v = 343;
    L = 16384; %size of dataMics
    f = sampleRate*(0:L-1)/L;
    
    frequencyIndices = find(f < 120e3);
    frequencyIndices = frequencyIndices(1:15:end);
    
    switch micCase
        case SPARSE
            load( 'Library/mic_pos_sonar_stm32.mat' );
            mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ];
        case DENSE
            load( 'Library/mic_pos_sonar_stm32_dense.mat' );
            mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ];
        case ULTRADENSE
            load( 'Library/mic_pos_sonar_stm32_ultraDense.mat' );
            mic_coordinates = [ mic_pos_final_pos/1000 zeros( 30,1 ) ];
            newArch = 1;
    end
    
%% Setup CAM
    vidobj = videoinput('winvideo', 2);
    triggerconfig(vidobj, 'manual');
    start(vidobj);
   
%% Open Serial port
    serSONARPortNum = COMSonar;
    serSONAR = serial( serSONARPortNum );
    serSONAR.BaudRate = 115200;
    set(serSONAR, 'InputBufferSize', round(numDataSamples * 5) );
    serSONAR.Timeout = 5;

    flushinput( serSONAR );
    flushoutput( serSONAR );

    if ( strcmp((get(serSONAR, 'Status')), 'closed' ) )
        fopen( serSONAR );
        fprintf( 'Serial port %s has been opened\n', serSONARPortNum);
    end

%% Point distribution;
    points = eq_point_set(2,500);
    [azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
    indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
    angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
    angles = rad2deg(angles);
    
%% Setup DAS;
        
    if currentCase == TIMEDASMATLAB
        mic_coordinates = [mic_coordinates(:,3) -mic_coordinates(:,1) mic_coordinates(:,2)];
        array = phased.ConformalArray('ElementPosition', mic_coordinates', 'Element', phased.OmnidirectionalMicrophoneElement('BackBaffled', true));
        beamformers = {};
        for iAngles = 1:size(angles, 2)
            beamformers{iAngles} = phased.TimeDelayBeamformer('SensorArray',array,...
                'SampleRate',sampleRate,'PropagationSpeed',v,...
                'Direction', -1*angles(:,iAngles));
        end
    end
    
    if currentCase == TIMEDASMEX
       
    [ delay_matrix, ~, ~ ] = azel_2_delayints( -angles(1,:), -angles(2,:), mic_coordinates, sampleRate ); 
    end
    
    if currentCase == FREQDASMANUAL
        numMics = size(mic_coordinates, 1);
        A = zeros(size(frequencyIndices, 2), numMics, length(angles(1,:)));
        for iFreq = 1:size(frequencyIndices, 2)
            frequency = f(frequencyIndices(iFreq));
            lambda = 343/frequency;
            for iAngles = 1:length(angles(1,:))
                curTheta = -angles(1,iAngles); % MINus ?
                curPhi = -angles(2,iAngles); % MINus ?
                for iMic = 0:numMics-1
                    psiX = sind(curTheta)*cosd(curPhi)*(mic_coordinates(iMic+1,1));
                    psiY = sind(curPhi)*mic_coordinates(iMic+1,2);
                    A(iFreq, numMics-iMic,iAngles) = exp(-1j*2*pi*( psiX + psiY ) / lambda);
                end
            end
        end
        tempDAS = zeros(size(frequencyIndices, 2), size(angles, 2));
    end
        
    %% Some data for nice hemisphere plot
    b = 90;
    [ azMatES, elMatES ] = meshgrid( -b:2*b/640:b, -b:2*b/480:b );
    azMatES = azMatES(1:end-1, 1:end-1);
    elMatES = elMatES(1:end-1, 1:end-1);
    clear b 
    
%% initialize figure and pcolor
    figure;
    img = getsnapshot(vidobj);    %get image from camera;
    h = imshow(img);
    hold on;
    hp = pcolor(zeros(size(azMatES, 1 ), size(azMatES, 2 )));
    set( hp, 'linestyle', 'none' )
    set( hp, 'CDataMode', 'manual' )
    axis equal
    axis tight
    cb = colorbar;
    ylabel(cb,'Amplitude [dB]')
%     hold off;

%% main loop
    
    DAS = zeros(1, size(angles, 2));
    for measure = 1 : 20
        [dataMics] = read_HS_Sonar(serSONAR, numDataSamples, newArch);
        img = getsnapshot(vidobj);    %get image from camera;
        
        switch currentCase
            case TIMEDASMATLAB
                parfor(iAngles = 1:size(angles, 2), feature('numcores')*3)
%                 for iAngles = 1:size(angles, 2)
                    beamformer = beamformers{iAngles};
                    DAS(iAngles) = sum(abs(beamformer(dataMics)));
                end
                
            case TIMEDASMEX
                E_scape = mex_fast_SpatioTemp_MF_v2( dataMics, delay_matrix );
                DAS = E_scape( 1 : 10 : length( dataMics ) ,  : );    
                DAS = sum(abs(DAS));
                
            case FREQDASMANUAL                 
                dataFFT = fft(dataMics);
                dataFFT = dataFFT(frequencyIndices, :);
                parfor (iFreq = 1:size(frequencyIndices, 2), feature('numcores')*3)
                    currentFFT = squeeze(dataFFT(iFreq, :));
                    currentA = squeeze(A(iFreq, :,:));
%                     R = currentFFT'*currentFFT;
%                     tempData = currentA'*R*currentA;
                    tempDAS(iFreq, :) = abs( currentA'*currentFFT.');
                end
                
%                 for iAngles = 1:size(angles, 2)
%                     currentAngleSlice = tempDAS(:, iAngles);
%                     currentAngleSlice(find(currentAngleSlice < max(currentAngleSlice)*0.7 )) = 0;
%                     tempDAS(:, iAngles) = currentAngleSlice;
%                 end
%                 for iFreqs = 1:size(tempDAS, 1)
%                     currentFreqSlice = tempDAS(iFreqs, :);
%                     currentFreqSliceDB = mag2db(currentFreqSlice);
%                     tempIndices = find(currentFreqSliceDB < max(currentFreqSliceDB));
%                     currentFreqSlice(tempIndices) = 0;
%                     tempDAS(iFreqs, :) = currentFreqSlice;
%                 end
                                
                
                %Try alias reductio
                DAS = sum(tempDAS);
%                 DAS(find(DAS < max(DAS)*0.85)) = 0;
%                 DAS(find(DAS < max(DAS)*0.7)) = 0;
                
            otherwise
                %Do Nothing
        end
       
        set(h, 'CData', img);
        hemispherePlot(angles(1,:), angles(2,:), DAS, azMatES, elMatES, hp)
        drawnow;
    end
    hold off
    
        %% Close Serial Port
    if ( strcmp((get(serSONAR, 'Status')), 'open' ) )
        fclose( serSONAR );
        clear serSONAR;
        fprintf( 'Serial port %s has been closed\n', serSONARPortNum);
    end
    
    % Close video objects
    delete(vidobj);
    
%     %Manual close after debug:
%     objects = imaqfind
%     delete(objects)

end
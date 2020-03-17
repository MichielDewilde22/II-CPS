%% ------------------------------------------------------------------------
%Parameters of the app

COMnumber = 9;

% app.array = 'Sparse Array';
 app.array = 'Dense Array';
% app.array = 'Ultradense Array';

 %app.beamDomain = 'Time domain';
app.beamDomain = 'Frequency domain';

app.beamBand = 'Wide'; %20 100 khz, je weet f niet
% app.beamBand = 'Narrow';

% app.algorithm = 'MUSIC';
app.algorithm = 'Delay and Sum';

app.spatialSmoothing = true;
% app.spatialSmoothing = false; 

%live = true;
live = false; %sample data will only work for array of 32 mics
savedData = 'savedData\SavedEScape1.mat';
% -------------------------------------------------------------------------

%% Initialize
fprintf('Initializing \n')
instrreset();
addpath( genpath( 'library' ) );

%Load data if necessary
if ~live
    load(savedData);
end

%Parameters
app.numDataSamples = 327680;
app.sampleRate = 450e3;
app.v = 343;
app.L = 16384; %size of dataMics

%Initialize beamforming angles uniformly over sphere
points = eq_point_set(2,500);
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
app.angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
app.angles = rad2deg(app.angles);

%% Connect to COM port
if live
    fprintf('Opening COM port\n')
    app.COMSonar = ['COM' num2str(COMnumber)];

    app.serSONARPortNum = app.COMSonar;
    app.serSONAR = serial( app.serSONARPortNum );
    app.serSONAR.BaudRate = 115200;
    set(app.serSONAR, 'InputBufferSize', round(app.numDataSamples * 5) );
    app.serSONAR.Timeout = 5;

    flushinput( app.serSONAR );
    flushoutput( app.serSONAR );

    if ( strcmp((get(app.serSONAR, 'Status')), 'closed' ) )
        fopen( app.serSONAR );
    end
end

%% Load microphone coordinates

switch char(app.array)
    case 'Sparse Array'
        load( 'Library/mic_pos_sonar_stm32.mat' );
        app.mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ];
        app.newArch = 0;
    case 'Dense Array'
        load( 'Library/mic_pos_sonar_stm32_dense.mat' );
        app.mic_coordinates = [ mic_pos_final_pos/1000 zeros( 32,1 ) ];
        app.newArch = 0;
    case 'Ultradense Array'
        load( 'Library/mic_pos_sonar_stm32_ultraDense.mat' );
        app.mic_coordinates = [ mic_pos_final_pos/1000 zeros( 30,1 ) ];
        app.newArch = 1;
end
app.mic_coordinates(:,1) = rdc(app.mic_coordinates(:,1));
app.mic_coordinates(:,2) = rdc(app.mic_coordinates(:,2));
app.mic_coordinates(:,3) = rdc(app.mic_coordinates(:,3));

%% Some data to nicely plot beamformed data
[ azMatES, elMatES ] = meshgrid( -90:1:90, -90:1:90 );
[ txLAEAP, tyLAEAP ] = laeap( -90:1:90, -90:1:90 );
[txVertical, tyVertical] = laeap(-90:30:90, -90:5:90);
[txHorizontal, tyHorizontal] = laeap(-90:5:90, -90:30:90);

%% ------------------------------------------------------------------------
% generate the steering matrix, hint you may add stuff here 
fprintf('Generating Steering Matrix\n')
wideFrequencies = linspace(20000,100000,81);
app.steeringMatrix = appSteeringMatrix(app.beamBand, app.beamDomain, app.sampleRate, app.mic_coordinates, app.angles,wideFrequencies);
% -------------------------------------------------------------------------

%% first run to generate the plot 
if live
    data = appReadSonar(app.serSONAR, app.numDataSamples, app.newArch);
else
    data = squeeze(EScapes(1,:,:)).'; 
end



%% Beamform the first data
spectrum = appBeamformer(app.beamDomain, app.beamBand, data, app.steeringMatrix, app.angles, app.algorithm, app.array, app.spatialSmoothing);
interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', squeeze(app.angles(2,:))', spectrum(:) );


%% Plot the first data 
figure(111);
cla;
hp = pcolor( txLAEAP, tyLAEAP, interpolatorES( azMatES, elMatES ));
set( hp, 'linestyle', 'none' )
set(hp, 'CDataMode', 'manual')
axis equal
axis tight
hold on;
plot(txVertical, tyVertical, '-k');
plot(txHorizontal', tyHorizontal', '-k');
hold off;
axis off
title( 'Energyscape' )
colormap default
colorbar;
drawnow;

fprintf('Running like butter\n')

%% Main loop - DO NOT TOUCH
if live
    while ishandle(111)
        %read data from sensor
        data = appReadSonar(app.serSONAR, app.numDataSamples, app.newArch);
        %calculate AoA
        spectrum = beamform(data,app);
        %interpolate data for plot
        interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', squeeze(app.angles(2,:))', spectrum(:) );

        % Plot the escape data
        if( strcmp(char(app.algorithm), 'MUSIC') && strcmp(char(app.beamDomain), 'Frequency domain') )
             set(hp, 'CData', flip(flip(interpolatorES( azMatES, elMatES ),1),2));
        else
            set(hp, 'CData', interpolatorES( azMatES, elMatES ))
        end
        colorbar
        drawnow;
    end
else
   for (idx = 1: size(EScapes, 1))
      if ~ishandle(111)
          break;
      end
      %load data from loaded parameter
      data = squeeze(EScapes(idx,:,:)).'; 
      %calculate AoA
      spectrum = beamform(data, app);
      %interpolate data for plot
      interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', squeeze(app.angles(2,:))', spectrum(:) );
      
      % Plot the escape data
       if( strcmp(char(app.algorithm), 'MUSIC') && strcmp(char(app.beamDomain), 'Frequency domain') )
          set(hp, 'CData', flip(flip(interpolatorES( azMatES, elMatES ),1),2));
      else
          set(hp, 'CData', interpolatorES( azMatES, elMatES ))
      end
      colorbar
      drawnow;
   end
end

%% Close COM
if live
    fclose( app.serSONAR );
    clear app.serSONAR;
end
fprintf('Night night\n');

function spectrum = beamform(data, app) 
    spectrum = appBeamformer(app.beamDomain, app.beamBand, data, app.steeringMatrix, app.angles, app.algorithm, app.array, app.spatialSmoothing);
end
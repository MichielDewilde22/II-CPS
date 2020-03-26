%% ------------------------------------------------------------------------
%Parameters of the app
%%OM NAUWKEURIG TE TIMEN MATLAB PROFILER

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
load(savedData);

%Parameters
app.numDataSamples = 327680;
app.sampleRate = 450e3;
app.v = 343;
app.L = 22500; %size of dataMics

%Initialize beamforming angles uniformly over sphere
points = eq_point_set(2,500);
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
app.angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
app.angles = rad2deg(app.angles);

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

%% ------------------------------------------------------------------------
% generate the steering matrix, hint you may add stuff here 
fprintf('Generating Steering Matrix\n')
wideFrequencies = linspace(20000,100000,81);
app.steeringMatrix = appSteeringMatrix(app.beamBand, app.beamDomain, app.sampleRate, app.mic_coordinates, app.angles,wideFrequencies);
% -------------------------------------------------------------------------

%% first run to generate the plot 
data = squeeze(EScapes(1,:,:)).'; 

%% Beamform the first data
spectrum = appBeamformer(app.beamDomain, app.beamBand, data, app.steeringMatrix, app.angles, app.algorithm, app.array, app.spatialSmoothing);
interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', squeeze(app.angles(2,:))', spectrum(:) );
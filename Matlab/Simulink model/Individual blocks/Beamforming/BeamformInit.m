%% SUMMARY
% This initialize script, initializes the data used for the beamforming. It
% does the following things:
% 1) Set beamforming parameters (locations of arrays, used algorithm, ...) 
% 2) Generating the angles used in the steering matrix
% 3) Loading the microphone data
% 4) Loading microphone array position data
% 5) Generating Steering Matrix 
% 6) Initializing beamforming algorithm on first data set.

fprintf('INITIALIZING BEAMFORMING DATA \n')
%% 1) SETTING BEAMFORMING PARAMATERS
fprintf('1) Setting parameters \n');

% type of array
app.array = 'Dense Array';
% app.array = 'Sparse Array';
% app.array = 'Ultradense Array';

% domain of the beamforming
app.beamDomain = 'Frequency domain';
% app.beamDomain = 'Time domain';

% wide vs. narrowband beamforming
app.beamBand = 'Wide'; %20 100 khz, je weet f niet
% app.beamBand = 'Narrow';

% beamforming algorithm
app.algorithm = 'Delay and Sum';
% app.algorithm = 'MUSIC';

% spatial smoothing
app.spatialSmoothing = true;
% app.spatialSmoothing = false; 

% running with live microphone arrays
% live = true;
live = false; % sample data will only work for array of 32 mics

% number of data samples
app.numDataSamples = 327680;

% sample rate
app.sampleRate = 450e3;

% speed of sound
app.v = 343;

% recorded dataset size of 1 microphone
app.L = 22500; 

% specify which data set to use


%% 2) GENERATING BEAMFORMING ANGLES
% This code generates 2 x 251 angles (azimuth & elevation) between -90 and
% 90 degrees to use as beamforming angles. 
fprintf('2) Generating beamforming angles \n')

points = eq_point_set(2,500); % 3 x 500 double points (cartesian coords)
[azimuth,elevation,~] = cart2sph(points(1,:),points(2,:),points(3,:));
indicesHalfShere = find(azimuth>-pi/2 & azimuth<pi/2);
app.angles = [azimuth(indicesHalfShere); elevation(indicesHalfShere)];
app.angles = rad2deg(app.angles); % angles used for beamforming

%% 3) LOADING MICROPHONE DATA
fprintf('3) Loading Data \n')

% loading microphone data


%% 4) LOADING MICROPHONE ARRAY POSITION DATA
fprintf('4) Loading microphone array position data \n')
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
% removing dc/mean value from coordinates
app.mic_coordinates(:,1) = rdc(app.mic_coordinates(:,1));
app.mic_coordinates(:,2) = rdc(app.mic_coordinates(:,2));
app.mic_coordinates(:,3) = rdc(app.mic_coordinates(:,3));

%% 5) GENERATING STEERING MATRIX 
% This part generates the steering matrix. This is a matrix consisting of
% 3 dimensions:
% - the number of microphones
% - the number of frequency bins
% - the number of angles
% for each dimension a phase shift is set. 
fprintf('5) Generating Steering Matrix \n')

% generating frequency bins between 20kHz and 100kHz with spacing 1kHz
wideFrequencies = linspace(20000,100000,81); 

% generating steering matrix
app.steeringMatrix = appSteeringMatrix(app.beamBand, app.beamDomain, ...
    app.sampleRate, app.mic_coordinates, app.angles,wideFrequencies);

%% 6) INITIALIZING BEAMFORMING ALGORITHM ON FIRST DATA SET
fprintf('6) Initializing beamforming algorithm on first data set.\n')
data = squeeze(EScapes(1,:,:)).'; % getting first set of recorded data

% calculate power value for each angle
powerAngles = appBeamformer(app.beamDomain, app.beamBand, data, ...
    app.steeringMatrix, app.angles, app.algorithm, app.array, ...
    app.spatialSmoothing);

% linear interpolation between al these points
interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))' ...
    , squeeze(app.angles(2,:))', powerAngles(:) );

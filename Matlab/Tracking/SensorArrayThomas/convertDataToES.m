% Load the data from somewhere (disk/serial port)
load('C:\Users\verel\Downloads\cps\Sonar_Toolbox\micData.mat');
addpath( genpath( 'library' ) );


settings = setupSensor();
azVec = settings.azVec; 
elVec = settings.elVec;
azVecAzel = settings.azVecAzel;
elVecAzel = settings.elVecAzel;
bAirleaks = settings.bAirleaks;
aAirleaks = settings.aAirleaks;
bLPF = settings.b_lp;
aLPF = settings.a_lp;

% Setup of the grid for the energyScape
[ azMatES, elMatES ] = meshgrid( -90:1:90, -90:1:90 );
[ txLAEAP, tyLAEAP ] = laeap( -90:1:90, -90:1:90 );
[txVertical, tyVertical] = laeap(-90:30:90, -90:5:90);
[txHorizontal, tyHorizontal] = laeap(-90:5:90, -90:30:90);

nMeasurements = numel(micData);

EScapes = zeros(nMeasurements, 32, 16384);
% Loop over the data
for idx = 1:nMeasurements
    
    % Select the current microphone measurement
    curMicData = cell2mat(micData(idx));
    % Filter the data
    dataFiltered = filter( bAirleaks, aAirleaks, rdc( curMicData' ), [], 2 );
    % DAS beamforming
    EScapes(idx, :, :) = dataFiltered;

    fprintf('%d / %d \n', idx, nMeasurements);
end

save 'SavedEScape1.mat'  EScapes
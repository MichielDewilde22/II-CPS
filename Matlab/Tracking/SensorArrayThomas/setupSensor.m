function settings = setupSensor()
load( 'mic_pos_sonar_stm32' );

mic_coordinates = rdc([mic_pos_final_pos zeros(32, 1)]'/1000)';


FsADC = 450000;
stdNoise = 0.5;

n_eq_pts = 1500; % changed from 4000
points = eq_point_set( 2, n_eq_pts );

idxs_frontal_hemi =  points(1,:) > 0;
points_hemi = points( :, idxs_frontal_hemi );

[ azVec, elVec, rhoVec ] = cart2sph( points_hemi(1,:), points_hemi(2,:), points_hemi(3,:) );
azVecAzel = rad2deg( azVec );
elVecAzel = rad2deg( elVec );

[ delayMatrix, dirCoordinates] = azel_2_delayints( azVecAzel, elVecAzel, mic_coordinates, FsADC );

[ bAirleaks, aAirleaks ] = butter( 6,  [20e3 100e3]/(FsADC/2) );
[ bLPF, aLPF ] = butter( 2, 1000/(FsADC/2) );

settings.delay_matrix = delayMatrix;
settings.base_sig = [ 0 1 0 0 0 ] ;
settings.a_lp = aLPF;
settings.b_lp = bLPF;
settings.azVec = azVec;
settings.elVec = elVec;
settings.rhoVec = rhoVec;
settings.azVecAzel = azVecAzel;
settings.elVecAzel = elVecAzel;
settings.bAirleaks = bAirleaks;
settings.aAirleaks = aAirleaks;
settings.dirCoordinates = dirCoordinates;
end
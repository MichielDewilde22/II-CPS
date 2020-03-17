function [ delay_matrix, dir_coordinates, error_matrix ] = azel_2_delayints( az_vec, el_vec, mic_coordinates, Fs_ADC )
%AZEL_2_DELAYINTS Summary of this function goes here
%   Detailed explanation goes here
    
    az_vec_d = deg2rad( az_vec );
    el_vec_d = deg2rad( el_vec );
    
    n_angles = length( az_vec );
    n_mics =  size( mic_coordinates, 1 );
    [ x_pos, y_pos, z_pos ] = sph2cart( az_vec_d, el_vec_d, 100*ones( 1, n_angles ) );
    
    dir_coordinates = [ y_pos ; z_pos ; x_pos ]';
    mic_coordinates_ok = mic_coordinates;

    delay_matrix = zeros( n_angles, n_mics );
    error_matrix = zeros( n_angles, n_mics );
    for angle_cnt = 1 : n_angles
       
        cur_dir_coord = dir_coordinates( angle_cnt, : );
        dist_vec = sqrt( sum( ( mic_coordinates_ok - repmat( cur_dir_coord, n_mics, 1 ) ).^2, 2 ) );
        dist_diff_vec = dist_vec - dist_vec( 1 );
        time_delay_vec = round( dist_diff_vec / 343 * Fs_ADC );
        
        error_vec = time_delay_vec - ( dist_diff_vec / 343 * Fs_ADC );
        error_matrix( angle_cnt, : ) = error_vec / Fs_ADC;
        
        time_delay_vec = time_delay_vec - min( time_delay_vec );
        delay_matrix( angle_cnt, : ) = time_delay_vec;
        

    end
    
    %delay_matrix  = delay_matrix - min( min( delay_matrix ) );
    

end


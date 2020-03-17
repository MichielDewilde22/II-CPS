function [ E_scape ] = fast_SpatioTemp_MF_v2( data, settings, gpu )
% FAST_SPATIOTEMP_MF Summary of this function goes here
%   Detailed explanation goes here
%     settings;   
    n_sps = size( data, 2 );
    n_chans = size( data, 1 );
    n_sps_base = length( settings.base_sig );
    
%     if( isfield( settings, 'base_FFT' ) == 0 )
        
        % Find nearest power of two for MF calculations
        npot = 2^ceil( log2( size( data, 2 ) ) );
        % Calculate the matched filters in one FFT operation:
        data_FFT = fft( [ data zeros( n_chans, npot - n_sps ) ], [], 2 );
        base_FFT = repmat( fft( [ settings.base_sig zeros( 1, npot - n_sps_base ) ] ), n_chans, 1 );

    %     size( conj( base_FFT ) )
    %     size( data_FFT )
    %     % Normal cross correlation:
        sig_corr_FDOM = data_FFT .* conj( base_FFT );
%     end
%     % Phase Generalised cross correlation:
%     sig_corr_FDOM = ( data_FFT .* conj( base_FFT ) ) ./ ( abs( data_FFT ) .* abs ( base_FFT ) );

%     % SCOT Generalised cross correlation:
%     sig_corr_FDOM = ( data_FFT .* conj( base_FFT ) ) ./ ( sqrt( data_FFT .* conj( data_FFT ) .* base_FFT .* conj( base_FFT ) ) );

%     % Roth Generalised cross correlation:
%     sig_corr_FDOM = ( data_FFT .* conj( base_FFT ) ) ./ ( sqrt( data_FFT .* conj( data_FFT ) .* base_FFT .* conj( base_FFT ) ) );


    data_MF = ifft( sig_corr_FDOM , [], 2 );
    

    data_MF = data_MF( :, 1 : n_sps );
    
    if gpu
        E_scape = gather(mex_fast_SpatioTemp_MF_CUDA( single(data_MF'), int32(settings.delay_matrix))); 
    else
        E_scape = mex_fast_SpatioTemp_MF_v2( data_MF', settings.delay_matrix );
    end
    % Make the E_scape same size as data_MF, because it is a little
    % dependant on the max delay...
%     E_scape = E_scape( 1 : length( data_MF ), : );
%     E_scape = E_scape( 1 : 5500, : );
    
    E_scape = filter( settings.b_lp, settings.a_lp, abs( E_scape ) );
    
    
   
end


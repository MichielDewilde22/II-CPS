function plot_spectrum(frequencies, response, text, freq_units )
% Plots a (complex) frequency/phase response in choses frequency units
% ARGUMENTS: 
%   frequencies - frequency vector
%   response - response vector
%   text - title to add to the picture
%   freq_units - frequency units string

    % frequency response
    subplot( 2, 1, 1 );
    plot( frequencies, abs(response), '.' );
    xlabel( 'frequency ['+string(freq_units)+']' );
    ylabel( "|response| [-]" );
    title( text );
    grid on;

    % phase response
    subplot( 2, 1, 2 );
    plot( frequencies, angle(response), '.' );
    xlabel( 'frequency ['+string(freq_units)+']' );
    ylabel( "arg(response) [rad]" );
    grid on;

end



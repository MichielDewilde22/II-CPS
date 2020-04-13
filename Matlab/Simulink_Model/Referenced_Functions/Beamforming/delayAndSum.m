function [POWER_func] = delayAndSum(A, dataFFT)
    POWER_func = zeros(251,1);
    n = 450; % number of FFT bins
    dataFFT = fft(dataFFT,n); %450 bins of 1000Hz
    dataFFT = dataFFT(21:101,:); %20KHz to 100KHz (21 because at it 1 => 0Hz, it 2=> 1000Hz, ..., it 21 => 20000hz)
    %f = Fs*(0:(n/2))/n;
    for freqIt = 1: 81
        % Steering matrix for current frequency bin
        currentA = (squeeze(A(:,freqIt,:))'); 
        
        % Data for current frequency bin
        currentData = (dataFFT(freqIt,:).');
        % Calculating the power for each angle and sum the power to the
        % previous power calculations. We use matrix multiplication to
        % implement the delay and sum beamforming.
        POWER_func = POWER_func +  abs(currentA * currentData); 
    end
end
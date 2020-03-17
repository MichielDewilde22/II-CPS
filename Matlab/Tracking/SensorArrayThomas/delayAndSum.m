function [POWER_func] = delayAndSum(A, dataFFT, angles)
    %Fs = 450000; sampling rate (fixed)
    POWER_func = zeros(251,1);
    n = 450;
    dataFFT = fft(dataFFT,n); %450 bins of 1000Hz
    dataFFT = dataFFT(21:101,:); %20KHz to 100KHz (21 because at it 1 => 0Hz, it 2=> 1000Hz, ..., it 21 => 20000hz)
    %f = Fs*(0:(n/2))/n;
    for freqIt = 1: 81
        currentA = (squeeze(A(:,freqIt,:))'); % A and FFTdata for each frequency
        currentData = (dataFFT(freqIt,:).');
        POWER_func = POWER_func +  abs(currentA * currentData); %matrix multiplication will basically do what delay and sum does
    end                                                         %sum up all power functions => will peak for correct delay
end
function power_angles = BeamformData(data, steering_matrix, n_fft_bins, ...
    first_bin, last_bin, angles)
%BEAMFORMDATA Returns the direction of the sound using beamforming.
% Delay & Sum beamforming (FFT is applied in DAS algorithm).

% vector of power per angle
power_angles = zeros(size(steering_matrix,3),1);

% fft of data
dataFFT = fft(data, n_fft_bins); 
% taking only the bins containing the right frequencies
dataFFT = dataFFT(first_bin:last_bin, :);

n_freq = last_bin - first_bin + 1;

% calculating the received power per angle
for freqIt = 1 : n_freq
    % Steering matrix for current frequency bin
    currentA = (squeeze(steering_matrix(:,freqIt,:))'); 

    % Data for current frequency bin
    currentData = (dataFFT(freqIt,:).');

    % Calculating the power for each angle and sum the power to the
    % previous power calculations. We use matrix multiplication to
    % implement the delay and sum beamforming.
    power_angles = power_angles +  abs(currentA * currentData); 
end



end

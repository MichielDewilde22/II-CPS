function [POWER_func] = musicAlgorithmFBSS(A, dataFFT, angles, sensor)
    switch char(sensor)
        case 'Sparse Array'
            POWER_func = musicAlgorithm(A, dataFFT, angles, fSelected);
            return;
        case 'Dense Array'
            [subarrays, subarraySize, numberOfSubArrays] = subarrayIndices(5, 6, 3, 3);
        case 'Ultradense Array' 
            [subarrays, subarraySize, numberOfSubArrays] = subarrayIndices(6, 5, 3, 3);
    end
    % It's the same as MUSIC, but different.
    
end
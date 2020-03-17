%SUBARRAY INDICES
%   Find all possible subarrays for given URA
%   returns matrix of size MxN with M = size of one subarray and N = total
%   number of subarrays
function [subarrays, subarraySize, nbOfSubarrays] = subarrayIndices(nMicY, nMicZ, nSubarrayY, nSubarrayZ)
    
    subarraySize = nSubarrayY * nSubarrayZ;
    nbOfSubarrays = (nMicZ - nSubarrayZ + 1) * (nMicY - nSubarrayY + 1);
    
    subarrays = zeros(subarraySize, nbOfSubarrays);
    subarrayStart = 1;
    
    for cntSubarray = 1:nbOfSubarrays
       currentSubarray = zeros(subarraySize, 1);
       if mod(subarrayStart,nMicZ) + nSubarrayZ - 1> nMicZ
          subarrayStart = subarrayStart + nSubarrayZ - 1; 
       end
       for cntY = 1:nSubarrayY
          startIndex = 1 + (cntY-1)*nSubarrayZ;
          currentRowStart =  subarrayStart + (cntY - 1)*(nMicZ);
          currentSubarray(startIndex : startIndex + nSubarrayZ - 1) = currentRowStart : currentRowStart + nSubarrayZ - 1; 
       end
       
       subarrays(:, cntSubarray) = currentSubarray;
       subarrayStart = subarrayStart + 1;
    end
end
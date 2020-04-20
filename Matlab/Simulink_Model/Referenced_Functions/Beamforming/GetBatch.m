function batch = GetBatch(batch_size,i_batch,data)
%GETBATCH Returns batch of samples of a lot more samples. 
%   INPUT:
%    - batch_size: number of samples you need to get of the data
%    - i_batch: batch number you want (if you exceed the data, you will get
%    zeros)
%    - data: your big data chunk (which is not overcompensating anything)
%   OUTPUT:
%    - batch: that sweet batch of data you requested. 
n_samples = size(data,1);

indx1 = (i_batch-1)*batch_size + 1;
indx2 = i_batch*batch_size;

batch = zeros(batch_size,size(data,2));
if indx1 > n_samples % return all zeros
    return
elseif indx2 > n_samples % zeropad the signal
    non_zero_data = data(indx1:n_samples,:);
    non_zero_size = size(non_zero_data,1);
    batch(1:non_zero_size,:) = non_zero_data;
    return
else
    batch = data(indx1:indx2,:);
end


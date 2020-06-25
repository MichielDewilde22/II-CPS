function [timepoint, datapoint] = getNearestPointArray(time_array, data_array, time)
%GETNEARESTPOINT Returns the nearest time- and data point of a timeseries
%struct. 

% find closes index
[timepoint, index] = min(abs(time_array(:) - time));
datapoint = data_array(index);
end


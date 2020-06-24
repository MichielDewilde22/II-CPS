function [timepoint, datapoint] = getNearestPoint(timeseries, time)
%GETNEARESTPOINT Returns the nearest time- and data point of a timeseries
%struct. 

% find closes index
[~, index] = min(abs(timeseries.time(:) - time));
datapoint = timeseries.data(index);
timepoint = timeseries.time(index);

end


function [output] = testFun(input)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[X, Y, Z]=ind2sub([10,10,3],input)
output = sqrt((X-1)^2 + (Y-1)^2 + (Z-1)^2);
end


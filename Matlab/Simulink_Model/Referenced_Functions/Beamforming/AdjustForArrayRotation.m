function [azimuth, elevation] = AdjustForArrayRotation(azimuth, ...
    elevation, node_position)
%ADJUSTFORARRAYROTATION Adjusts angles to array rotation. 
%   The angles and rotation parameters are expressed as degrees.

[R, ~] = AxelRotS0(node_position(4), node_position(5), node_position(6));

p_2 = [1 0 0];
p_rot = (p_2*R)';
[az, el, ~] = cart2sph(p_rot(1), p_rot(2), p_rot(3));
az = rad2deg(az);


outputArg1 = inputArg1;
outputArg2 = inputArg2;
end


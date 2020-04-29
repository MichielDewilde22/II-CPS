function vector = AnglesToLaserVector(laserpos, azimuth, elevation)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
azimuth = deg2rad(azimuth);
elevation = deg2rad(elevation)*(-1) +(pi/2);

% calculating x,y,z components relative to array
laser_length = 7;
rx_array = cos(elevation)*cos(azimuth)*laser_length;
ry_array = cos(elevation)*sin(azimuth)*laser_length;
rz_array = sin(elevation)*laser_length;

[R, ~] = AxelRotS0(laserpos(4),laserpos(5),laserpos(6));
p_zero = [rx_array ry_array rz_array]; % direction of components before rotation
rotated_array = (p_zero*R); % directions after rotation

vector = [laserpos(1), laserpos(2), laserpos(3), rotated_array(1), rotated_array(2), rotated_array(3)];
    
end


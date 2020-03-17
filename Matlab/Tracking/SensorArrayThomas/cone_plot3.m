function [X2,Y2,Z2] = cone_plot3(r,h,phi,theta,offset)
    m = h/r;
    [R,A] = meshgrid(linspace(0,r,50),linspace(0,2*pi,50));
    X = R.*cos(A);
    Y = R.*sin(A);
    Z = m*R;
    % Cone around the z-axis, point at the origin
    X1 = X*cos(phi) - Z*sin(phi);
    Y1 = Y;
    Z1 = X*sin(phi) + Z*cos(phi);
    % Previous cone, rotated by angle phi about the y-axis
    X2 = X1*cos(theta) + offset(1);
    Y2 = X1*sin(theta) + offset(2);
    Z2 = Z1 + offset(3);
    % Second cone rotated by angle theta about the z-axis
end
close all;
clear;
clc;

% Position of the mic arrays is expressed as 6-DOF data. The nodes are 
% positioned in a triangle on the floor. (angles are in degrees)
% Important notice: the arrays only detect in a forward derection.
% Therefore we turn them -90 degrees so that they lay flat on the floor. 
position_array_1 = [1.5 1.5 0 0 -90 0];
position_array_2 = [1.5 3.5 0 0 -90 0];
position_array_3 = [3.5 2.5 0 0 -90 0];




x(1) = 0;
x(2) =2.5;
x(3) =0;
x(4)=0;
x(5) = 0;
x(6)=0;
x(7)=1.5;
x(8)=5;
x(9)=1;
x(10)=0;
x(11)=-90;
x(12)=0;
x(13)=5;
x(14)=2.5;
x(15)=1;
x(16)=0;%define in radians
x(17)=90;
x(18)=0;

% lala=runModel(x);
% fprintf('The error median was: '+string(lala)+' meters.\n');

rng default

lb = zeros(1,18);
ub = [5 5 2.5 2*pi 2*pi 2*pi 5 5 2.5 2*pi 2*pi 2*pi 5 5 2.5 2*pi 2*pi 2*pi];

x = ga(@runModel, 18,[],[],[],[],lb ,ub);


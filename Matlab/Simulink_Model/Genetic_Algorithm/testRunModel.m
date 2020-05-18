close all;
clear;
clc;
%enter 'parpool' command to enable parallel computing
parpool;

% TO MAKE IT WORK: add folder "Simulink_Model" and subfolder to path.

room_dimensions = [5 5 2.5]; 

n_locations = 100;
sound_locations = zeros(n_locations, 3);
% sound_locations(:,1) = linspace(0, room_dimensions(1), n_locations);
% sound_locations(:,2) = linspace(0, room_dimensions(2), n_locations);
% sound_locations(:,3) = linspace(0, room_dimensions(3), n_locations);

i = 1;
for xcoord = 0.5: 4.5
   for ycoord = 0.5: 4.5
      for zcoord = 0.5: 1.5
          sound_locations(i,:) = [xcoord, ycoord, zcoord];
          i = i+1;
      end
      for zcoord = 1 : 2
          sound_locations(i,:) = [xcoord, ycoord, zcoord];
          i = i+1;
      end
   end
end

% scatter3(sound_locations(:,1),sound_locations(:,2),sound_locations(:,3));
                
array_type = 7; % used array type, 7 = circle array of 8 mics

% Loading audio properties
filename = 'sound_signal_short_20-22kHz.wav';
[audioPS, fs] = audioread(filename);

% runModel(position_nodes, audioPS, fs, 4000, sound_locations, room_dimensions, 7, 1)

rng default %for reproducability
lb = zeros(1,6);
ub = [5 2.5 5 2.5 5 2.5];
%     X  Y |Y  Z | X  Z

options = optimoptions('ga','UseParallel', true, 'UseVectorized', false, 'plotfcns',{@gaplotbestf, @gaplotstopping},...
    'MaxGenerations',150,'MaxStallGenerations', 30);
[x,Fval,exitFlag,Output] = ga(@(x) runModel(x, audioPS, fs, 4000, sound_locations, room_dimensions, 7, 0), 6,[],[],[],[],lb ,ub, [], options);
save(x);
%shut parallel computing down
delete(gcp);

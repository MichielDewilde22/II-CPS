%Arbitrairy values at this moment, will later be replaced by input from
%qualisys
%[Xloc, YLoc, ZLoc] in cms
SA1Loc = [100 0 0]
SA2Loc = [0 100 0]
SA3Loc = [100 150 0]
SALocs = [SA1Loc ; SA2Loc ; SA3Loc]
%[Roll, Pitch, Yaw] in radians
%For the moment we will assume the SA's will not have a Roll
SA1Rot = [0 pi/6 -pi/2]
SA2Rot = [0 pi/4 -pi/3]
SA3Rot = [0 -pi/3 pi/2]
SARots = [SA1Rot ; SA2Rot; SA3Rot]

%Arbitrairy values as well, replaced by input from beamforming mcus
%[Azimuth, Elevation] in radians.
SA1Angle = [pi/2 pi/4]
SA2Angle = [pi/6 pi/3]
SA3Angle = [pi/4 pi/4]
SAAngles = [SA1Angle; SA2Angle; SA3Angle]

%Correct the angles you get from the SA's with the orientation they have
SAAngles = [SAAngles(:,1)+SARots(:,2) SAAngles(:,2)+SARots(:,3)]
    
t = linspace(0,100)

V= [(cos(SAAngles(:,2)).*cos(SAAngles(:,1))) (cos(SAAngles(:,2)).*sin(SAAngles(:,1))) sin(SAAngles(:,2))]
V3d = [cat(3, V(1,1),V(1,2),V(1,3));
       cat(3, V(2,1),V(2,2),V(2,3));
       cat(3, V(3,1),V(3,2),V(3,3))]
V3D = bsxfun(@times,V3d,t)
V3D = permute(V3D,[1,3,2]);
V3D = bsxfun(@plus,V3D,SALocs)



%%DRAW PLOT
line(squeeze(V3D(1,1,:)),squeeze(V3D(1,2,:)),squeeze(V3D(1,3,:)))
line(squeeze(V3D(2,1,:)),squeeze(V3D(2,2,:)),squeeze(V3D(2,3,:)))
line(squeeze(V3D(3,1,:)),squeeze(V3D(3,2,:)),squeeze(V3D(3,3,:)))
    


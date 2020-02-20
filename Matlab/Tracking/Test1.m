%Arbitrairy values at this moment, will later be replaced by input from
%qualisys
%[Xloc, YLoc, ZLoc, Xrot, YRot, ZRot] in cms and degrees
SA1Loc = [100 0 0]
SA2Loc = [0 100 0]
SA3Loc = [100 100 0]
SALocs = [SA1Loc ; SA2Loc ; SA3Loc]

%Arbitrairy values as well, replaced by input from beamforming mcus
%[Azimuth, Elevation] in degrees. 90 degrees is straight away from the SA
SA1Angle = [90 0]
SA2Angle = [90 0]
SA3Angle = [90 0]

SAAngles = [cos(deg2rad(SA1Angle(1))) 

quiver3(SALocs(:,1),SALocs(:,2),SALocs(:,3),SAAngles(:,1),SAAngles(:,2),SAAngles(:,3))
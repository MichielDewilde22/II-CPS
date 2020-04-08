function Dir = BeamformStep(data,app)
   %calculate AoA
   powerAngles = appBeamformer(app.beamDomain, app.beamBand, data, ...
       app.steeringMatrix, app.angles, app.algorithm, app.array, ...
       app.spatialSmoothing);
   %interpolate data for plot
   interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', ...
       squeeze(app.angles(2,:))', powerAngles(:) );
   [V, I] = max(interpolatorES.Values);
   Dir = interpolatorES.Points(118,:);
end
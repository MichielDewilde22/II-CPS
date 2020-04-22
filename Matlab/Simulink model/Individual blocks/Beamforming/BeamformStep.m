function Dir = BeamformStep(data,app)
   %calculate AoA
   spectrum = appBeamformer(app.beamDomain, app.beamBand, data, app.steeringMatrix, app.angles, app.algorithm, app.array, app.spatialSmoothing);
   %interpolate data for plot
   interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', squeeze(app.angles(2,:))', spectrum(:) );
   [V, I] = max(interpolatorES.Values);
   Dir = interpolatorES.Points(I,:);
end


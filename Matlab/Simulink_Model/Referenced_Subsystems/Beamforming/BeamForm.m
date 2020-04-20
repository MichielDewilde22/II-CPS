function Dir = BeamForm(data, angles, steeringMatrix)
%BeamForm Beamform execution block
   powerAngles = appBeamformer('Frequency domain', 'Wide', data, ...
       steeringMatrix, angles, 'Delay and Sum', 'Dense Array', 1);
   %interpolate data for plot
   interpolatorES = scatteredInterpolant( squeeze(app.angles(1,:))', ...
       squeeze(app.angles(2,:))', powerAngles(:) );
   [V, I] = max(interpolatorES.Values);
   Dir = interpolatorES.Points(118,:);
end


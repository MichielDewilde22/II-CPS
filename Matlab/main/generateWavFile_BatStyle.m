function y = generateWavFile_BatStyle(length, fs, nodes, soundLocation, pulseFreqVar, pulseAmplituteOffset, noisePM, pulseTimeVar, radPattern, timeVar, type)
  % Create 6 wav channels per node
  % Data is a wav file of 5 microphone captures and the sync channel
  % Create the big y variable here
  %
  % Inputs
  % - length               : Capture length in seconds
  % - Fs                   : Sampling frequency in Hertz
  % - nodes                : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
  % - soundLocation        : Matrix of sound locations (Mx3) [X, Y, Z]
  % - 
  % - pulseFreqVar         : Normal distributed deviation of start and end frequency in Hz
  % - pulseAmplituteOffset : Pulse amplitute offset in volts
  % - noisePM              : Plus or minus offset of noise amplitude
  % - pulseTimeVar         : Variation in pulse timing in seconds
  % - radPattern           : Scattered interpolant of the radiation pattern
  % - timeVar              : Normal distributed offset in capture start
  %
  % Output
  % - y Big matrix (3 dimensions)
  %    d1: Samples
  %    d2: Channels
  %    d3: Nodes

  C = 343; % Speed of sound

  %% Generate

  n_channel = 6;                                               % Number of channels
  
  y = zeros(length*fs, n_channel, size(nodes, 1));             % Create empty 3D y matrix dim(samples, channels, nodes)

  if size(soundLocation,2) == 3
    fprintf('Warning: This is the old style of sound source without direction, the radiation pattern will not be applied\n');
    doRadPattern = false;
  elseif size(soundLocation,2) == 6
    doRadPattern = true;
  else
    warning('Invalid format for sound source location, should be [X, 6]');
    return;
  end

  % Equally distribute n sounds in capture (not too close to endpoints)
  pulse_offsets = linspace(1, length * fs, size(soundLocation,1)+2);
  pulse_offsets = pulse_offsets(2:end-1);

  %aa = nan(9,5);

  timeVar = timeVar*betarnd(5,5,1,size(nodes, 1));             % beta random of time var (between 0 and timeVar), one value per node, equal accross all sounds
  for i_sound = 1:size(soundLocation, 1)                       % For all sounds
    for i_node = 1:size(nodes, 1)                              % For every node (3rd dimension)
      nodeX = nodeToX([nodes(i_node, :), 1]);
      %nodeVm = mean(nodeX,2);
      y_i = zeros(length*fs, n_channel);                       % 2D y matrix (samples, channels) as it would be captured on the device
      for i_mic=1:n_channel-1                                  % For every channel
        distSoundMic = norm(soundLocation(i_sound,1:3) - nodeX(:,i_mic)',2); % Distance from sound to this microphone
        distDiff = round(fs * (-distSoundMic)/C);              % Num samples from vm to this mic

        %aa(i_sound, i_mic) = distDiff;

        f_start  = 60e3;                                       % Pulse start frequency in Hertz
        f_start = round(normrnd(f_start,pulseFreqVar,1,1));    % Add variation
        f_end    = 20e3;                                       % Pulse end frequency in Hertz
        f_end = round(normrnd(f_end,pulseFreqVar,1,1));        % Add variation

        pulseLength = 0.003;                                   % Pulse length in seconds
        dur      = pulseLength*1000;                           % Pulse length in ms
        ampl     = 1;                                          % Pulse amplitute in volts
        winpct   = 10;                                         %
        pulse = rdc(fm_sweep(f_start, f_end, fs, dur, ampl, winpct)); % Create fm sweep pulse
        pulse = pulse(1:end-1)';                               % Remove last sample
        

        % Create capture
        % Initialize as vector of ones
        % Multiply by ampl offset
        % Add random noise between +- noisePM
        capture = pulseAmplituteOffset * ones(length*fs,1) + (rand(length*fs,1)*2*noisePM)-noisePM; 

        % Add pulse to capture
        % By adding, the ampl noise is kept
        % Shift the pulse based on pulse time var
        % The mean is also shifted according to the distance difference (mic and vm)
        %meanvar = (length*Fs)/2;
        meanvar = 0;
        meanvar = meanvar - distDiff;
        var = fs*pulseTimeVar;
        shift = round(normrnd(meanvar,var,1,1) + pulse_offsets(i_sound));

        %pulseSamples = (pulseLength * fs)-1;
        pulseSamples = size(pulse,1) -1;

        %capture(shift:shift+pulseSamples) = capture(meanvar:meanvar+pulseSamples) + pulse;
        capture(shift:shift+pulseSamples) = capture(shift:shift+pulseSamples) + pulse;

        if doRadPattern
          % a is the angle of departure of the sound relative to the microphone
          % 
          [a, b, ~] = cart2sph(nodeX(1,i_mic)-soundLocation(i_sound,1), nodeX(2,i_mic)-soundLocation(i_sound,2), nodeX(3,i_mic)-soundLocation(i_sound,3));
          a = rad2deg([a b]);
          az = wrapTo180(-a(1) + soundLocation(i_sound,6)); % Add yaw
          el = wrapTo180(a(2) + soundLocation(i_sound,5)); % Add pitch
          %fprintf('[%d,\t%d\t->\t%f\n', int16(az), int16(el), radPattern(az,el));

          %capture = capture * radPattern(az,el);


          % DEBUG
          %{
          fprintf('[%d, %d] -> %d\n', int16(az), int16(el), radPattern(az,el));
          figure;
          hold on;
          scatter3(0,0,0, 'green')
          scatter3(nodeX(1,i_mic), nodeX(2,i_mic), nodeX(3,i_mic), 'blue')
          scatter3(soundLocation(i_sound,1), soundLocation(i_sound,2), soundLocation(i_sound,3), 'yellow')
          %axis equal
          view(-100,45)
          grid on
          scatter3(nodeX(1,i_mic)-soundLocation(i_sound,1), nodeX(2,i_mic)-soundLocation(i_sound,2), nodeX(3,i_mic)-soundLocation(i_sound,3), 'red')
          xlabel('x');
          ylabel('y');
          zlabel('z');
          xlim([min([0, nodeX(1,i_mic), soundLocation(i_sound,1), nodeX(1,i_mic)-soundLocation(i_sound,1)])-1, max([0, nodeX(1,i_mic), soundLocation(i_sound,1), nodeX(1,i_mic)-soundLocation(i_sound,1)])+1])
          ylim([min([0, nodeX(2,i_mic), soundLocation(i_sound,2), nodeX(2,i_mic)-soundLocation(i_sound,2)])-1, max([0, nodeX(2,i_mic), soundLocation(i_sound,2), nodeX(2,i_mic)-soundLocation(i_sound,2)])+1])
          zlim([min([0, nodeX(3,i_mic), soundLocation(i_sound,3), nodeX(3,i_mic)-soundLocation(i_sound,3)])-1, max([0, nodeX(3,i_mic), soundLocation(i_sound,3), nodeX(3,i_mic)-soundLocation(i_sound,3)])+1])
          %}
        end
        y_i(:,i_mic) = capture;
      end
      addSamples = pulseAmplituteOffset * ones(floor(timeVar(i_node)*fs),1) + (rand(floor(timeVar(i_node)*fs),1)*2*noisePM)-noisePM;
      y_i = [y_i(size(addSamples,1)+1:end,:); repmat(addSamples, [1, n_channel])]; % Cut off some samples at beginning of capture and add random noise to the rest
      %y(:,:,i_nodes, i_sound) = y_i;




      y(:,:,i_node) = y(:,:,i_node) + y_i;

    end
  end
  
  % Add sync channel
  % The sync value toggles 1 and 0 for a random duration between s1 and s2 samples
  s1 = 100;
  s2 = 6000;
  sync = zeros(2*length*fs,1);
  syncVal = 0;
  rand_ctr = 0;
  for i_sample=1:2*length*fs*size(soundLocation, 1)            % For all samples (twice because of time var offsets)
    if rand_ctr == 0                                           % If random counter reached zero 
      rand_ctr = floor(s1+s2*rand(1,1));                       % New random counter
      syncVal = ~syncVal;                                      % Toggle value
    else                                                       % Random counter has not yet reached zero
      rand_ctr = rand_ctr - 1;                                 % Decrement counter
    end                                                        % 
    sync(i_sample) = syncVal;                                  % Write syncval
  end
  sync = 3.6*sync-1.8;
  for i_node = 1:size(nodes, 1)
    %i_tmp = i_tmp+1
    i_sync = sync(((i_sound-1) * (length*fs)) + 1 + floor(timeVar(i_node)*fs) : (i_sound) * (length*fs) + floor(timeVar(i_node)*fs));
    y(:,6,i_node) = i_sync;
  end

  if size(y,4) ~= 1
    error('4D y matrix is deprecated');
  end

  %% Save to file 
  dirName = sprintf('Data_%s', datestr(now,'mm-dd-yyyy HH-MM'));

  mkdir(dirName)
  
  for i_node = 1:size(nodes,1)
    nodeDir = [dirName '/Node_' sprintf('%d', i_node)];
    mkdir(nodeDir);
    wavData = y(:,:,i_node);
    wavData = wavData ./ (1.1*max(max(wavData)));
    audiowrite([nodeDir '/capture.wav'], wavData, fs);
  end
  save([dirName '/node_6d'], 'nodes');
  save([dirName '/sound_gt'], 'soundLocation');

  %figure;hold on; grid on; xlabel('x'); ylabel('y'); zlabel('z'); axis equal
  %mscatter3(soundLocation)
  %mscatter3(soundLocation(1,:))
  %mscatter3(100*nodeX)

end
function y = GenerateMicData_V2(baseSound, fs, position_nodes, ...
    sound_location, amplituteOffset, noisePM, timeVar, type, samples_per_batch)
% Create 6 wav channels per node
% Data is a wav file of 5 microphone captures and the sync channel
% Create the big y variable here
%
% Inputs
% - length               : Capture length in seconds
% - Fs                   : Sampling frequency in Hertz
% - position_nodes       : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
% - sound_location       : Matrix of sound locations (Mx3) [X, Y, Z]
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
n_channels = size(nodeToX([0 0 0 0 0 0 type]), 2)+1;         % Number of channels
length = size(baseSound, 1);                                 % sound length in samples
y = zeros(length, n_channels, size(position_nodes, 1));      % Create empty 3D y matrix dim(samples, channels, position_nodes)

% Indexes for adding each part of the sound to the capture
soundIdxs = round(linspace(1, size(baseSound, 1), size(sound_location, 1)+1));
% We pad the end of the vector with zeros to emulate no sound is
% produced.
frame_size = size(baseSound,1)/size(sound_location,1);
base_sound_zp = [baseSound; zeros(frame_size,1)];

% printing progress
tic;
n_iterations = size(position_nodes, 1)*(n_channels-1)*size(sound_location, 1);
current_it = 0;
print_factor = floor(n_iterations/100);
print_it = 0;
total_progress_small = ceil(n_iterations/print_factor);

% For all sound locations
for i_loc = 1:size(sound_location, 1)
    
    begin_sound_index = soundIdxs(i_loc);
    end_sound_index = soundIdxs(i_loc+1);
    frame_size = end_sound_index - begin_sound_index + 1;
    
    % For every node (3rd dimension)
    for i_node = 1:size(position_nodes, 1)
        
        nodeX = nodeToX([position_nodes(i_node, :), type]);
        
        y_i = zeros(length, n_channels);% 2D y matrix (samples, channels) as it would be captured on the device
        
        % For every channel
        for i_mic=1:n_channels-1 
            % calculating distance from sound to microphone (in meters &
            % samples)
            dist_diff = norm(sound_location(i_loc,1:3) - nodeX(:,i_mic)',2);
            sample_diff = round(fs * (dist_diff)/C);              
            
            begin_index = begin_sound_index + sample_diff;
            end_index = end_sound_index + sample_diff;
            
            % Create capture
            % Initialize as vector of ones
            % Multiply by ampl offset
            % Add random noise between +- noisePM
            capture = amplituteOffset * ones(frame_size,1) + (rand(frame_size,1)*2*noisePM)-noisePM;
            capture = capture + base_sound_zp(begin_index:end_index);

            y_i(soundIdxs(i_loc) : soundIdxs(i_loc+1),i_mic) = capture;
            
            % printing progress
            print_it = print_it + 1;
            if print_it == print_factor
                print_it = 0;
                current_it = current_it + 1;
                it_string = "1/3: Channel generation progress: " + string(current_it) + " of "+ string(total_progress_small) + "\n";
                fprintf(it_string);
            end

        end
        
        addSamples = amplituteOffset * ones(floor(timeVar(i_node)*fs),1) ...
          + (rand(floor(timeVar(i_node)*fs),1)*2*noisePM)-noisePM;

        % Cut off some samples at beginning of capture and add random noise to the rest
        y_i = [y_i(size(addSamples,1)+1:end,:); repmat(addSamples, [1, n_channels])]; 
        
        y(:,:,i_node) = y(:,:,i_node) + y_i;

    end
end

% printing progress
n_iterations = 2*length*size(sound_location, 1);
current_it = 0;
print_factor = floor(n_iterations/100);
print_it = 0;
total_progress_small = n_iterations/print_factor;

% Add sync channel
% The sync value toggles 1 and 0 for a random duration between s1 and s2 samples
s1 = 100;
s2 = 6000;
sync = zeros(2*length,1);
syncVal = 0;
rand_ctr = 0;

for i_sample=1:2*length*size(sound_location, 1)            % For all samples (twice because of time var offsets)
    % print progress
    print_it = print_it + 1;
    if print_it == print_factor
        print_it = 0;
        current_it = current_it + 1;
        it_string = "2/3: Sync channel generation progress: " + string(current_it) + " of "+ string(total_progress_small) + "\n";
        fprintf(it_string);
    end

    if rand_ctr == 0                                           % If random counter reached zero 
        rand_ctr = floor(s1+s2*rand(1,1));                       % New random counter
        syncVal = ~syncVal;                                      % Toggle value
    else                                                       % Random counter has not yet reached zero
        rand_ctr = rand_ctr - 1;                                 % Decrement counter
    end                                                        % 
        sync(i_sample) = syncVal;                                  % Write syncval
end

sync = 3.6*sync-1.8;
for i_node = 1:size(position_nodes, 1)
    %i_tmp = i_tmp+1
    i_sync = sync(((i_loc-1) * (length)) + 1 + floor(timeVar(i_node)*fs) : (i_loc) * (length) + floor(timeVar(i_node)*fs));
    y(:,6,i_node) = i_sync;
end

if size(y,4) ~= 1
    error('4D y matrix is deprecated');
end

%% Save to file 
dirName = sprintf('Model_Data/Microphone_Data');

fprintf("3/3: Saving data ... \n");
n_batch = length/samples_per_batch;
n_node = size(position_nodes,1);
for i_node = 1:n_node
    % printing progress
    it_string = "3/3: Writing audio file "+string(i_node)+" of "+string(n_node)+"...\n";
    fprintf(it_string);
    
    % saving data in wav file
    nodeDir = [dirName '/data_array_' sprintf('%d', i_node)];
    mkdir(nodeDir);
    wavData = y(:,:,i_node);
    wavData = wavData ./ (1.1*max(max(wavData)));
    audiowrite([nodeDir '/capture.wav'], wavData, fs);
    
    it_string = "3/3: Writing mat file "+string(i_node)+" of "+string(n_node)+"...\n";
    fprintf(it_string);
    % saving data in mat file (per batch)
    % reshaping array for batch processing in simulation
    storeData = zeros(n_batch,n_channels-1,samples_per_batch);
    wavData = wavData.';
    for index = 1:n_batch
        begin_index = ((index-1)*500)+1;
        end_index = index*500;
        storeData(index,:,:) = wavData(1:n_channels-1,begin_index:end_index);
    end
    save([nodeDir '/capture.mat'], 'storeData');
    
end
save([dirName '/position_nodes'], 'position_nodes');
save([dirName '/sound_location'], 'sound_location');

ex_time = toc/60;
fprintf("The execution time was: " + string(ex_time) + " minutes. \n");
end
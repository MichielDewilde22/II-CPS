function y = GenerateMicData_V4(baseSound, fs, position_nodes, ...
    locations, amplituteOffset, noisePM, timeVar, array_type, ...
    decimation_factor, write_audio_files)
% Create 6 wav channels per node
% Data is a wav file of 5 microphone captures and the sync channel
% Create the big y variable here
%
% Inputs
% - n_samples            : Capture n_samples in seconds
% - Fs                   : Sampling frequency in Hertz
% - position_nodes       : Matrix of node location and orientations (Nx6) [X, Y, Z, rX, rY, rZ]
% - locations       : Matrix of sound array_type (Mx3) [X, Y, Z]
% - pulseFreqVar         : Normal distributed deviation of start and end frequency in Hz
% - pulseAmplituteOffset : Pulse amplitute offset in volts
% - noisePM              : Plus or minus offset of noise amplitude
% - pulseTimeVar         : Variation in pulse timing in seconds
% - radPattern           : Scattered interpolant of the radiation pattern
% - timeVar              : Normal distributed offset in capture start
% - decimation_factor    : Decimation factor 
% - write_audio_files    : 1 if you want to write audio files, zero if not


C = 343; % Speed of sound

%% Generate
n_samples = size(baseSound, 1); % number of samples in the base sound
n_channels = size(NodePosToArrayPos([0 0 0 0 0 0],array_type),2); % number of channels per array
n_nodes = size(position_nodes,1); % number of arrays
y = zeros(n_samples, n_channels, n_nodes); % Create empty 3D y matrix dim(samples, channels, nodes)

n_locations = size(locations, 1);
begin_indxs = floor(linspace(1,n_samples-1,n_locations+1));
begin_indxs = begin_indxs(1:end-1);
end_indxs = ceil(linspace(1,n_samples,n_locations+1));
end_indxs = end_indxs(2:end);

zp_base_sound = ceil(n_samples/n_locations);

% We pad the end of the vector with zeros to emulate no sound is
% produced.
base_sound_zp = [zeros(zp_base_sound,1);baseSound; zeros(zp_base_sound,1)];

% printing progress
tic;
n_iterations = n_nodes*n_channels*n_locations;
current_it = 0;
print_factor = floor(n_iterations/100);
print_it = 0;
total_progress = floor(n_iterations/print_factor);

% For all sound array_type
for i_loc = 1:n_locations
    % index of the zp sound fragment for each location at the sound source.
    begin_indx_loc = begin_indxs(i_loc) + zp_base_sound;
    end_indx_loc = end_indxs(i_loc) + zp_base_sound;
    
    % For every node (3rd dimension)
    for i_node = 1:size(position_nodes, 1)
        position_node = position_nodes(i_node,:);
        array_pos = NodePosToArrayPos(position_node, array_type);
        
        batch_size = end_indx_loc - begin_indx_loc + 1;
        
        y_i = zeros(batch_size, n_channels);% 2D y matrix (samples, channels) as it would be captured on the device
        
        % For every channel
        for i_channel=1:n_channels
            % calculating distance from sound to microphone (in meters &
            % samples)
            distance = norm(locations(i_loc,1:3) - array_pos(:,i_channel)',2);
            sound_delay = round(fs * (distance)/C); % negative number of samples the sound should be delayed
            
            % index of the location of the zp sound fragment with respect
            % to the delay of the sound.
            begin_indx_channel = begin_indx_loc + sound_delay;
            end_indx_channel = end_indx_loc + sound_delay;
            
            % Create capture
            % Initialize as vector of ones
            % Multiply by ampl offset
            % Add random noise between +- noisePM
            capture = amplituteOffset * ones(batch_size,1) + (rand(batch_size,1)*2*noisePM)-noisePM;
            capture = capture + base_sound_zp(begin_indx_channel:end_indx_channel);

            y_i(:,i_channel) = capture;
            
            % printing progress
            if print_it == print_factor
                print_it = 0;
                current_it = current_it + 1;
                it_string = "1/2: Data generation progress: " + string(current_it) + " of "+ string(total_progress) + "\n";
                fprintf(it_string);
            end
            print_it = print_it + 1;

        end
        
        % Add offset of start capture of node. 
        addSamples = amplituteOffset * ones(floor(timeVar(i_node)*fs),1) ...
          + (rand(floor(timeVar(i_node)*fs),1)*2*noisePM)-noisePM;
        n_addSamples = size(addSamples,1);

        % Replace some samples at the beginning by noise, 
        y_i = [y_i(n_addSamples+1:end,:); repmat(addSamples, [1, n_channels])]; 
        
        y(begin_indxs(i_loc):end_indxs(i_loc),:,i_node) = y(begin_indxs(i_loc):end_indxs(i_loc),:,i_node) + y_i;
    end
end

%% Decimating
fprintf("2/3: Decimating data ... \n");
current=0;
total = size(position_nodes,1)*n_channels;
if (decimation_factor~=1)
    y_dec = zeros(n_samples/decimation_factor,  n_channels, n_nodes);
    for i_node = 1:size(position_nodes, 1)
        for i_channel=1:n_channels
            current = current + 1;
            it_string = "2/3: Decimating data "+string(current)+" of "+string(total)+"...\n";
            fprintf(it_string);
            y_dec(:,i_channel,i_node) = decimate(y(:,i_channel,i_node),decimation_factor);
        end
    end

    y = y_dec;
end

%% Save to file 
dirName = sprintf('Model_Data/Microphone_Data');
fprintf("3/3: Saving data ... \n");
if write_audio_files
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
        audiowrite([nodeDir '/capture.wav'], wavData, (fs/decimation_factor));
    end
    save([dirName '/position_nodes'], 'position_nodes');
    save([dirName '/locations'], 'locations');
end

ex_time = toc/60;
fprintf("The execution time was: " + string(ex_time) + " minutes. \n");
end
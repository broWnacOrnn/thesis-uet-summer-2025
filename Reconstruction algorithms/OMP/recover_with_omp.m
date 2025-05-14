clc 
clear all 
close all

% Start timing
tic;

% Define paths
input_video_dir = 'your/path/here/video.mp4';
frames_dir = 'your/path/here/frames_video';
marks_dir = 'your/path/here/marks_video';
results_dir = 'your/path/here/results_video/';
output_video_dir = 'your/path/here/output_video.mp4';

% Read the input video
video = VideoReader(input_video_dir);
num_frames = video.NumFrames;

% To calculate compression rate
total = 0;
total_m = 0;
m_values = [];

mark = zeros(256, 256); % Initialize a matrix to store marked frames
rec_frames = zeros(256, 256, num_frames); % Array to store reconstructed frames

for i = 1:num_frames
    % Process current frame
    cur_frame = readFrame(video);
    cur_frame = rgb2gray(cur_frame);
    cur_frame = imresize(cur_frame, [256 256]);
    height = size(cur_frame, 1);
    width = size(cur_frame, 2);
    filename_input = sprintf('%sframe_%03d.png', frames_dir, i);
    imwrite(cur_frame, filename_input);

    % Update mark every 5 frames 
    filename_rec = sprintf('%sframe_%03d.png', marks_dir, i);
    if (mod(i, 5) == 1)
        mark = cur_frame;
        imwrite(mark, filename_rec);
        rec_frames(:, :, i) = mark;
        imwrite(rescale(rec_frames(:,:,i), "InputMin", 0, "InputMax", 255), filename_rec);
        total = total + 256*256;
    else
        diff = double(cur_frame) - double(pre_frame); % Calculate the difference from the previous frame
        max_diff = max(max(abs(diff)));
        [spar, non_zeros] = cal_sparsity(diff);
        
        if (max_diff > 7 || non_zeros > 6500) % Check if the difference is significant
            row_blocks = width/16;
            col_blocks = height/16;
            pieces = mat2cell(diff, repmat(16, row_blocks, 1), repmat(16, col_blocks, 1)); % Divide the difference into pieces
            
            % Loop through each piece
            for j = 1:numel(pieces)
                piece = double(pieces{j});
                [sparsity, non_zeros] = cal_sparsity(piece);

                if sparsity < 0.4 % If sparsity is below threshold (meaningful)
                    if sparsity > 0
                        n = size(piece, 1)*size(piece, 2); % Total pixels of the piece
                        m = uint16(5*non_zeros*log10(n/non_zeros)); % Number of measurements

                        total_m = total_m + m; % Update total measurements
                        m_values(end+1) = m; % Store the measurement value
        
                        f = double(piece(:)); % Flatten the piece
                        A = get_A_random01(n, m); % Generate random measurement matrix
    
                        y = A * f; % Get measurements
                        total = total + size(y, 1);
                        xp = OMPv1(y, A, non_zeros); % Apply OMP algorithm to recover the piece
    
                        piece_rec = reshape(xp, size(piece));  
                        pieces{j} = piece_rec; 

                    end

                elseif sparsity > 0.4 % If sparsity is above threshold
                    pieces{j} = piece; % Keep the original piece
                end
            end

            diff_rec = cell2mat(pieces); % Combine the processed pieces back into a matrix
            rec_frames(:, :, i) = double(rec_frames(:, :, i-1)) + diff_rec; % Update the reconstructed frame with the difference
        else
            rec_frames(:, :, i) = cur_frame; % If no significant difference, use the current frame
        end
    end

    pre_frame = cur_frame; % Update the previous frame for the next iteration
end

total = total + numel(A);

% Save the reconstructed frames as images
for i = 1:num_frames
    rec_frames(:, :, i) = rescale(rec_frames(:, :, i), "InputMin", 0, "InputMax", 255);
    filename_output = sprintf('%sframe_%03d.png', results_dir, i);
    imwrite(rec_frames(:, :, i), filename_output);
end

% Specify the directory containing your frames
frames_output_dir = results_dir;

% Get a list of all the frames in the directory
frames = dir(fullfile(frames_output_dir, '*.png')); 

% Create a video writer object with MPEG-4 profile
video = VideoWriter(output_video_dir, 'MPEG-4');

% Set the frame rate (optional)
video.FrameRate = 15;

% Open the video writer object
open(video);

% Write each frame to the video
for i = 1:(numel(frames)-1)
    frame = imread(fullfile(frames_output_dir, frames(i).name));
    writeVideo(video, frame);
end

% Close the video writer object
close(video);

% Stop timing and display the elapsed time
elapsed_time = toc; 
fprintf('Elapsed time: %.2f seconds\n', elapsed_time);
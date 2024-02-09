function make_video_for_one_file(behav_data, params)

current_time_ind = params.current_time_ind;
disp_time_win = params.disp_time_win;
session = params.current_session;
run = params.current_run;
data_p = params.data_p;

time_vec = behav_data.time_vec;

% Create viewer figure
[fig, ax] = sg_disp.plotting.make_video_fig_and_axes(params);

last_ind = find(~isnan(time_vec));
last_ind = last_ind(end);

% Define video filename
videoFolder = fullfile(data_p, 'gaze_signal_videos', session);
if ~exist(videoFolder, 'dir')
    mkdir(videoFolder);
end
videoFilename = fullfile(videoFolder, ['gaze_signal_video_', session, '_', run, '.mp4']);

% Create VideoWriter object
videoWriterObj = VideoWriter(videoFilename, 'MPEG-4');
videoWriterObj.FrameRate = 100; % Adjust as needed
videoWriterObj.Quality = 50; % Adjust as needed

% Open the video writer
open(videoWriterObj);

progressInterval = 10;  % Adjust as needed
frameCount = 0;

fprintf('Generating video for Session: %s, Run: %s\n', session, run);

while current_time_ind <= last_ind% && ~ptb.util.is_esc_down()
    clear_all_axes(ax);
    disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win);
    monkey = 'm1';
    roi_color_table = sg_disp.plotting.draw_one_timeframe_for_one_monkey( ...
        ax, behav_data, params, disp_time_inds, monkey );
    % Plot the gaze location for m1
    monkey = 'm2';
    sg_disp.plotting.draw_one_timeframe_for_one_monkey( ...
        ax, behav_data, params, disp_time_inds, monkey );
    % Add legend for ROIs
    sg_disp.plotting.add_roi_legend(ax, roi_color_table);
    current_time = time_vec(current_time_ind);
    region = 'acc';
    sg_disp.plotting.draw_celltype_coded_raster_for_a_region( ...
        ax, params, current_time, region );
    region = 'bla';
    sg_disp.plotting.draw_celltype_coded_raster_for_a_region( ...
        ax, params, current_time, region );
    title_str = sprintf('Gaze Signals for Session: %s; Run: %s;', session, run);
    sgtitle(title_str);
    
    % Capture the frame
    frame = getframe(fig);
    
    % Write the frame to the video
    writeVideo(videoWriterObj, frame);
    
    current_time_ind = current_time_ind + 1;
    params.current_time_ind = current_time_ind;
    
    frameCount = frameCount + 1;
    if mod(frameCount, progressInterval) == 0 || current_time_ind > last_ind
        fprintf('Progress (Session: %s, Run: %s): %d / %d frames\n', session, run, current_time_ind, last_ind);
    end
end

% Close the video writer
close(videoWriterObj);

end

function disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win)
    num_time_inds_to_disp = disp_time_win * 1e3;
    disp_ind_start = max(1, current_time_ind - num_time_inds_to_disp + 1);
    disp_time_inds = disp_ind_start:current_time_ind;
end


function clear_all_axes(ax)
    % Iterate through each field of the struct
    fields = fieldnames(ax);
    for i = 1:numel(fields)
        % Clear the axis object using cla
        cla(ax.(fields{i}));
    end
end

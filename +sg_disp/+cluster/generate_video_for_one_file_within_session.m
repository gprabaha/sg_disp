function generate_video_for_one_file_within_session(behav_data, spike_data, params)

time_vec                = behav_data.time_vec;
session                 = behav_data.session;
run_number              = behav_data.run_number;
start_time_ind          = behav_data.start_time_ind;
end_time_ind            = behav_data.end_time_ind;

cluster_out_path        = params.cluster_out_path;
disp_time_win           = params.disp_time_win;
progress_interval       = params.progress_interval;
frame_rate              = params.frame_rate;
video_quality           = params.video_quality;
video_output_folder     = params.video_output_folder;

% Here we calculate the mean and std of spiking rate of units in session
spike_data = sg_disp.util.calculate_mean_and_std_activity_of_unit_within_run(...
    behav_data, spike_data, params);

all_time_inds = start_time_ind:end_time_ind;

[fig, ax] = sg_disp.plotting.make_video_fig_and_axes( params );

% Define video filename
video_folder = fullfile( cluster_out_path, video_output_folder, session );
if ~exist(video_folder, 'dir')
    mkdir(video_folder);
end
video_filename = sprintf( 'gaze_signal_video_session-%s_run-%02d', session, str2double( run_number ) );
video_filepath = fullfile( video_folder, video_filename );
% Create VideoWriter object
video_writer_obj = VideoWriter(video_filepath);
video_writer_obj.FrameRate = frame_rate; % Adjust as needed
video_writer_obj.Quality = video_quality; % Adjust as needed
% Open the video writer
open( video_writer_obj );

for i = 1:numel(all_time_inds)
    current_time_ind = all_time_inds(i);
    current_time = time_vec(current_time_ind);

    sg_disp.plotting.clear_all_axes( ax );
    disp_time_inds = sg_disp.util.calculate_disp_time_inds(current_time_ind, disp_time_win);

    monkey = 'm1';
    roi_color_table = sg_disp.plotting.draw_one_timeframe_for_one_monkey( ...
        ax, behav_data, params, disp_time_inds, monkey );
    monkey = 'm2';
    sg_disp.plotting.draw_one_timeframe_for_one_monkey( ...
        ax, behav_data, params, disp_time_inds, monkey );
    sg_disp.plotting.add_roi_legend( ...
        ax, roi_color_table );

    region = 'acc';
    sg_disp.plotting.draw_one_raster_timeframe_for_one_region( ...
        ax, spike_data, params, current_time, region );
    region = 'bla';
    sg_disp.plotting.draw_one_raster_timeframe_for_one_region( ...
        ax, spike_data, params, current_time, region );
    % drawnow;

    title_str = sprintf('Gaze Signals for Session: %s; Run: %s;', session, run_number);
    sgtitle(title_str);
    
    % Capture the frame
    frame = getframe( fig );
    writeVideo( video_writer_obj, frame );

    if rem(i, progress_interval) == 0
        fprintf('    Progress (Session: %s, Run: %s): %d / %d frames\n', ...
            session, run_number, ...
            current_time_ind - all_time_inds(1) + 1, ...
            end_time_ind - all_time_inds(1) + 1);
    end
end

close( video_writer_obj );
close all;

end
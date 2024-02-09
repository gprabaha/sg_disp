function make_video_for_one_file(behav_data, params)

current_time_ind = params.current_time_ind;
disp_time_win = params.disp_time_win;
session = params.current_session;
run = params.current_run;
pause_time = params.pause_time;

spike_data = params.spike_data;

% Create viewer figure
[fig, ax] = sg_disp.viewer.make_viewer_fig_and_axes( params );

last_ind = find( ~isnan( behav_data.time_vec ) );
last_ind = last_ind(end);

while current_time_ind <= last_ind
    disp_time_inds = calculate_disp_time_inds( current_time_ind, disp_time_win );
    monkey = 'm1';
    roi_color_table = sg_disp.plotting.draw_one_timeframe_for_one_monkey( ax, behav_data, params, disp_time_inds, monkey );
    % Plot the gaze location for m1
    monkey = 'm2';
    sg_disp.plotting.draw_one_timeframe_for_one_monkey( ax, behav_data, params, disp_time_inds, monkey );
    % Add legend for ROIs
    sg_disp.plotting.add_roi_legend(ax, roi_color_table);
    
    region = 'acc';
    %sg_disp.plotting.draw_celltype_coded_raster_for_a_region( ax, behav_data, params, disp_time_inds, region );


    title_str = sprintf('Gaze Signals for Session: %s; Run: %s;', session, run);
    sgtitle( title_str );
    drawnow;
    pause( pause_time );
    current_time_ind = current_time_ind + 1;
    params.current_time_ind = current_time_ind;
end



end

function disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win)
    num_time_inds_to_disp = disp_time_win * 1e3;
    disp_ind_start = max(1, current_time_ind - num_time_inds_to_disp + 1);
    disp_time_inds = disp_ind_start:current_time_ind;
end
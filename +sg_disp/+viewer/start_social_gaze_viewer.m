function start_social_gaze_viewer(params)
    % Extract parameters from the structure

    pos_file_list = params.pos_file_list;
    time_file_list = params.time_file_list;
    fix_file_list = params.fix_file_list;
    roi_file_list = params.roi_file_list;
    offset_file_list = params.offset_file_list;
    bounds_file_list = params.bounds_file_list;
    
    current_session = params.current_session;
    current_run = params.current_run;
    session_per_file = params.session_per_file;
    run_number_per_file = params.run_number_per_file;
    current_time_ind = params.current_time_ind;
    disp_time_win = params.disp_time_win;

    rois_of_interest = params.rois_of_interest;
    pause_time = params.pause_time;
    n_frames = params.n_frames;

    % Initialize file index
    current_file_ind = [];
    all_sessions = [];
    runs_in_session = [];
    behav_data = struct();
    neural_data = struct();

    % Create viewer
    [fig, ax] = sg_disp.viewer.make_viewer_fig_and_axes( params );

    [fig, session_menu, run_menu, all_sessions, runs_in_session] = ...
        sg_disp.viewer.make_dropdown_menus(fig, params, @fetch_behavioral_data);
    
    [fig, play_pause_button] = ...
        sg_disp.viewer.make_play_pause_button(fig, params, @generate_updating_plots);
    
    fetch_behavioral_data();

    function fetch_behavioral_data(~, ~)
        params.current_time_ind = 1; %reset start time to 1 everytime a new file is selected

        % Get the selected session and run number
        sessionIdx = get(session_menu, 'Value');
        runIdx = get(run_menu, 'Value');

        % Extract the current session and run number
        current_session = all_sessions{sessionIdx};
        current_run = runs_in_session{runIdx};
        current_file_ind = find(strcmp(session_per_file, current_session) & strcmp(run_number_per_file, current_run));

        pos_file = pos_file_list{current_file_ind};
        time_file = time_file_list{current_file_ind};
        fix_file = fix_file_list{current_file_ind};
        roi_file = roi_file_list{current_file_ind};
        offset_file = offset_file_list{current_file_ind};
        
        disp('Loading eyetracking files...');
        time_struct = load(time_file);
        pos_struct = load(pos_file);
        fix_struct = load(fix_file);
        roi_struct = load(roi_file);
        offset_struct = load(offset_file);
        disp('Done');

        behav_data.time_vec = time_struct.var.t;
        behav_data.pos_vecs = pos_struct.var;
        behav_data.fix_vecs = fix_struct.var;
        behav_data.roi_rects = sg_disp.util.get_roi_rects( roi_struct.var, rois_of_interest );
        behav_data.offsets = offset_struct.var;
    end

    % Callback function for the play/pause button
    function generate_updating_plots(~, ~)
        if get(play_pause_button, 'Value')
            set(play_pause_button, 'String', 'Pause');
        else
            set(play_pause_button, 'String', 'Play');
        end
        while play_pause_button.Value == 1
            current_time_ind = params.current_time_ind;
            disp_time_inds = calculate_disp_time_inds( current_time_ind, disp_time_win );
            if sum( ~isnan( behav_data.time_vec(disp_time_inds) ) ) > 1
                monkey = 'm1';
                sg_disp.plotting.draw_one_timeframe_for_one_monkey( monkey, ax, disp_time_inds, behav_data, params );
                monkey = 'm2';
                sg_disp.plotting.draw_one_timeframe_for_one_monkey( monkey, ax, disp_time_inds, behav_data, params );
                drawnow;
                pause(pause_time);
            end
            params.current_time_ind = current_time_ind + 1;
        end
    end
end


function disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win)
    num_time_inds_to_disp = disp_time_win * 1e3;
    disp_ind_start = max(1, current_time_ind - num_time_inds_to_disp + 1);
    disp_time_inds = disp_ind_start:current_time_ind;
end

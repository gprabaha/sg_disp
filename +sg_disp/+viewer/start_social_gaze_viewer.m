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
    time_ind_reset_method = params.time_ind_reset_method;

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
        
        time_struct = get_sub_struct( time_struct );

        params.current_time_ind = update_current_time_ind( ...
            time_struct.t, time_ind_reset_method ); % randsample or reset to 1

        behav_data.time_vec = time_struct.t;
        behav_data.pos_vecs = get_sub_struct( pos_struct );
        behav_data.fix_vecs = get_sub_struct( fix_struct );
        behav_data.roi_rects = sg_disp.util.get_roi_rects( roi_struct.var, rois_of_interest );
        behav_data.offsets = get_sub_struct( offset_struct );
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
                % Plot the gaze location for m1
                monkey = 'm1';
                roi_color_table = sg_disp.plotting.draw_one_timeframe_for_one_monkey( monkey, ax, disp_time_inds, behav_data, params );
                % Plot the gaze location for m1
                monkey = 'm2';
                sg_disp.plotting.draw_one_timeframe_for_one_monkey( monkey, ax, disp_time_inds, behav_data, params );
                % Add legend for ROIs
                sg_disp.plotting.add_roi_legend(ax, roi_color_table);
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


function current_time_ind = update_current_time_ind(time_vec, update_method)
    % Validate input update_method
    if ~(strcmp(update_method, 'randsample') || strcmp(update_method, 'reset'))
        error('update_method must be either ''randsample'' or ''reset''.');
    end
    % Determine the current time index based on the update method
    if strcmp(update_method, 'randsample')
        % Randomly select an index from time_vec using randsample
        current_time_ind = randsample(length(time_vec), 1);
    else
        % If update_method is 'reset', set current_time_ind to 1
        current_time_ind = 1;
    end
end

function str = get_sub_struct( input_struct )
    if numel(fieldnames(input_struct)) > 1
        error('Struct has more than one fields!');
    end
    str = input_struct.( char( fieldnames(input_struct) ) );
end
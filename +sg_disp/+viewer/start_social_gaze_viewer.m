function start_social_gaze_viewer(params)
    % Extract parameters from the structure

    current_session = params.current_session;
    current_run = params.current_run;
    session_per_file = params.session_per_file;
    run_number_per_file = params.run_number_per_file;

    pos_file_list = params.pos_file_list;
    time_file_list = params.time_file_list;
    fix_file_list = params.fix_file_list;
    roi_file_list = params.roi_file_list;


    bounds_file_list = params.bounds_file_list;
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
    fig = make_viewer_fig( params );

    [fig, session_menu, run_menu, all_sessions, runs_in_session] = make_dropdown_menus(fig, ...
        params, @fetch_behavioral_data);
    
    [fig, play_pause_button] = make_play_pause_button(fig, params, @generate_updating_plots);
    
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
        
        disp('Loading eyetracking files...');
        time_struct = load(time_file);
        pos_struct = load(pos_file);
        fix_struct = load(fix_file);
        roi_struct = load(roi_file);
        disp('Done');

        behav_data.time_vec = time_struct.var.t;
        behav_data.pos_vecs = pos_struct.var;
        behav_data.fix_vecs = fix_struct.var;
        behav_data.roi_rects = get_roi_rects( roi_struct.var, rois_of_interest );
    end

    % Callback function for the play/pause button
    function generate_updating_plots(~, event)
        if get(play_pause_button, 'Value')
            set(play_pause_button, 'String', 'Pause');
            % Call your play function here
            [fig, params] = make_display(fig, behav_data, params);
        else
            set(play_pause_button, 'String', 'Play');
            % Call your pause function here
            drawnow;
        end
    end
end

function fig = make_viewer_fig(params)
    border_fraction = params.border_fraction;
    font_size = params.font_size;
    % Get the figure position for the primary screen with borders
    fig_position = [border_fraction border_fraction...
        1-(2*border_fraction) 1-(2*border_fraction)];
    % Create a figure on the primary screen with borders
    fig = figure('Units', 'normalized', 'Position', fig_position);
    % Set default font size for all text within the figure
    set(fig, 'DefaultTextFontSize', font_size);
end
function roi_rects = get_roi_rects( roi_struct, rois_of_interest )
% List of fieldnames
monkeys = fieldnames( roi_struct );
% Create the struct
roi_rects = struct();
for i = 1:numel(monkeys)
    rect_map = roi_struct.(monkeys{i}).rects;
    % Initialize variables to store ROI names and rectangle coordinates
    roi_names = {};
    rect_coords = {};   
    % Iterate over ROIs
    for j = 1:numel(rois_of_interest)
        roi_name = rois_of_interest{j};  % Get ROI name      
        % Check if the ROI exists in the rect_map
        if isKey(rect_map, roi_name)
            roi_names = [roi_names; roi_name];  % Store ROI name
            rect_coord = rect_map(roi_name);  % Get rectangle coordinates
            rect_coords = [rect_coords; rect_coord];  % Store rectangle coordinates
        else
            disp(['ROI "', roi_name, '" not found in rect_map.']);  % Display a message if ROI is not found
        end
    end
    table_roi_rect = table(roi_names, rect_coords, 'VariableNames', {'roi', 'roi_rect'});
    roi_rects.(monkeys{i}) = table_roi_rect;
end
end


function [fig, session_menu, run_menu, all_sessions, runs_in_session] = make_dropdown_menus(fig,...
        params, callback_function)
    menu_pos_wrt_fig = params.menu_pos_wrt_fig; % x and y relative to figure (0 to 1)
    menu_width = params.menu_width;
    menu_height = params.menu_height;
    menu_x_offset = params.menu_x_offset;
    run_menu_y_offset = params.run_menu_y_offset;
    menu_font_size = params.menu_font_size;
    
    session_per_file = params.session_per_file;
    current_session = params.current_session;
    run_number_per_file = params.run_number_per_file;

    all_sessions = unique(session_per_file);

    % Set figure units to pixels
    set(fig, 'Units', 'pixels');
    % Get figure position in pixels
    fig_position_px = get(fig, 'Position');

    session_text_x = fig_position_px(3) * menu_pos_wrt_fig(1);
    session_text_y = fig_position_px(4) * menu_pos_wrt_fig(2);
    session_menu_x = fig_position_px(3) * (menu_pos_wrt_fig(1) + menu_x_offset);
    session_menu_y = session_text_y;

    % Create dropdown menu for session
    session_text = uicontrol('Parent', fig, ...
        'Style', 'text', ...
        'FontSize', menu_font_size, ...
        'Position', [session_text_x, session_text_y, menu_width, menu_height], ...
        'String', 'Session: ', ...
        'HorizontalAlignment', 'right');
    session_menu = uicontrol('Parent', fig, ...
        'Style', 'popupmenu', ...
        'FontSize', menu_font_size, ...
        'Position', [session_menu_x, session_menu_y, menu_width, menu_height], ...
        'String', all_sessions, ...
        'Callback', callback_function);  % Set callback function handle

    sessionIdx = get(session_menu, 'Value');
    if isempty(current_session)
        current_session = all_sessions{sessionIdx};
    end
    runs_in_session = run_number_per_file( strcmp(session_per_file, current_session) );

    run_text_x = fig_position_px(3) * menu_pos_wrt_fig(1);
    run_text_y = fig_position_px(4) * (menu_pos_wrt_fig(2) - run_menu_y_offset);
    run_menu_x = fig_position_px(3) * (menu_pos_wrt_fig(1) + menu_x_offset);
    run_menu_y = run_text_y;

    run_text = uicontrol('Parent', fig, ...
        'Style', 'text', ...
        'FontSize', menu_font_size, ...
        'Position', [run_text_x, run_text_y , menu_width, menu_height], ...
        'String', 'Run Number:', ...
        'HorizontalAlignment', 'right');
    run_menu = uicontrol('Parent', fig, ...
        'Style', 'popupmenu', ...
        'FontSize', menu_font_size, ...
        'Position', [run_menu_x, run_menu_y, menu_width, menu_height], ...
        'String', runs_in_session, ...
        'Callback', callback_function);  % Set callback function handle
end


function [fig, play_pause_button] = make_play_pause_button(fig, params, callback_funcition)
    position = params.play_pause_position;
    size = params.play_pause_size;
    play_pause_button = uicontrol('Parent', fig, ...
        'Style', 'togglebutton', ...
        'String', 'Play', ...
        'Units', 'normalized', ...
        'Position', [position size], ...
        'Callback', callback_funcition);  % Set callback function handle
end


function [fig, params] = make_display(fig, behav_data, params)
    current_time_ind = params.current_time_ind;
    disp_time_win = params.disp_time_win;
    pause_time = params.pause_time;

    m1_axes = params.m1_axes;
    m2_axes = params.m2_axes;

    if isempty(current_time_ind)
        current_time_ind = 1;
    end

    set(fig, 'KeyPressFcn', @space_bar_callback);
    set(fig, 'KeyPressFcn', @escape_callback);
    is_paused = false;
    stop_time_loop = false;
    
    ax = struct();
    ax.m1 = axes('Position', m1_axes); % x1 y1 width height
    ax.m2 = axes('Position', m2_axes);

    time_vec = behav_data.time_vec;

    while current_time_ind < numel(time_vec)
        if ( is_paused )
            drawnow;
            pause(0.1);
            continue;
        end

        if ( stop_time_loop )
            params.current_time_ind = current_time_ind;
            break;
        end
        
        disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win);
        
        monkey = 'm1';
        draw_gaze_timecourse_for_one_monkey( monkey, ax, disp_time_inds, behav_data );

        monkey = 'm2';
        draw_gaze_timecourse_for_one_monkey( monkey, ax, disp_time_inds, behav_data );
        
        drawnow;
        pause(pause_time);
        
        current_time_ind = current_time_ind + 1;
    end


    function space_bar_callback(~, event)
        if ( strcmp(event.Key, 'space') )
            is_paused = ~is_paused;
        end
    end

    function escape_callback(~, event)
        if ( strcmp(event.Key, 'esc') )
            stop_time_loop = ~stop_time_loop;
        end
    end
end



function disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win)
    num_time_inds_to_disp = disp_time_win * 1e3;
    disp_ind_start = max(1, current_time_ind - num_time_inds_to_disp + 1);
    disp_time_inds = disp_ind_start:current_time_ind;
end


function draw_gaze_timecourse_for_one_monkey( monkey, ax, disp_time_inds, behav_data )

relevant_axis = ax.(monkey);

pos_vec = behav_data.pos_vecs.(monkey);
time_vec = behav_data.time_vec;

x_vec = pos_vec(1, disp_time_inds)';
y_vec = pos_vec(2, disp_time_inds)';

white_to_black_cmap = linspace(1, 0, length(x_vec))';
cmap = [white_to_black_cmap, white_to_black_cmap, white_to_black_cmap]; % RGB values

% Plot scatter points with specified color and size
cla(relevant_axis);
scatter(relevant_axis, x_vec, y_vec, 50, cmap, 'filled');
    
start_time = time_vec(disp_time_inds(1));
current_time = time_vec(disp_time_inds(2));
colormap(relevant_axis, cmap);
clim( relevant_axis, [start_time, current_time] ); % Set colorbar limits
colorbar( relevant_axis );
title( relevant_axis, sprintf('%s Gaze Location from t=%0.3fs to %0.3fs', ...
    monkey, start_time, current_time ) );

end
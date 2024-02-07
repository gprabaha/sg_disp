%% Workspace cleanup
clear;
clc;

%% Script parameters

% Data root
data_p              = fullfile( sg_disp.util.project_path, 'processed_data' );

% Validity filter for units
validity_filter = {'valid-unit', 'maybe-valid-unit'};

% For analysis
excluded_categories = {'outlier', '<cell-type>', 'ofc', 'dmpfc'};

rois_of_interest = {'eyes'...
    , 'mouth'...
    , 'face'...
    , 'left_nonsocial_object'...
    , 'right_nonsocial_object'};    

% Viewer design parameters
border_fraction         = 0.05;
font_size               = 20;
menu_pos_wrt_fig        = [0.7 0.85];
menu_width              = 100; %px
menu_height             = 30; %px
menu_x_offset           = 0.065;
run_menu_y_offset       = 0.04;
menu_font_size          = 16;

% Paremeters for viewer
current_session         = '';
current_run             = '';
current_time_ind        = 151263;
disp_time_win           = 0.5; % seconds
monitor_size            = [1024 768]; % x1 y1 x2 y2


disp_size               = [1024*3 768]; % x1 y1 x2 y2
refresh_rate            = 10; % roughly the number of times a new screen-flip happens per second | human perception is 10hz
n_frames                = 1000;
pause_time              = 0;

%%
% Paths for raw beavior
raw_behavior_root   = fullfile(data_p,            'raw_behavior');
pos_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/position');
time_dir            = fullfile(raw_behavior_root, 'aligned_raw_samples/time');
bounds_dir          = fullfile(raw_behavior_root, 'aligned_raw_samples/bounds');
fix_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/raw_eye_mmv_fixations');
meta_dir            = fullfile(raw_behavior_root, 'meta');
events_dir          = fullfile(raw_behavior_root, 'raw_events_remade');
roi_dir             = fullfile(raw_behavior_root, 'rois');
offset_dir          = fullfile(raw_behavior_root, 'single_origin_offsets');

% List of positions, fixations, and ROIs
pos_file_list = shared_utils.io.findmat( pos_dir );
fix_file_list = shared_utils.io.findmat( fix_dir );
roi_file_list = shared_utils.io.findmat( roi_dir );
bounds_file_list = shared_utils.io.findmat( bounds_dir );
time_file_list = shared_utils.io.findmat( time_dir );
offset_file_list = shared_utils.io.findmat( offset_dir );

% Make sure we have the only the files that correspond with each other
pos_file_list(is_hidden(pos_file_list)) = [];
fix_file_list(is_hidden(fix_file_list)) = [];
roi_file_list(is_hidden(roi_file_list)) = [];
bounds_file_list(is_hidden(roi_file_list)) = [];
time_file_list(is_hidden(roi_file_list)) = [];

fnames_pos = shared_utils.io.filenames( pos_file_list );
fnames_roi = shared_utils.io.filenames( roi_file_list );
roi_file_list(~ismember(fnames_roi, fnames_pos)) = [];
bounds_file_list(~ismember(fnames_roi, fnames_pos)) = [];
time_file_list(~ismember(fnames_roi, fnames_pos)) = [];

session_per_file = cell( numel( pos_file_list ), 1 );
run_number_per_file = cell( numel( pos_file_list ), 1 );

% Loop through each path and extract the session and run number from the
% filename
for i = 1:numel(pos_file_list)
    [~, filename, ~] = fileparts(pos_file_list{i});
    split_filename = strsplit(filename, '_');
    session_per_file{i} = split_filename{1};
    run_number_per_file{i} = split_filename{3};
end


%% Loading Data
disp( 'Loading data...' );

% Neural data
if ~exist('sorted', 'var')
    disp('Loading sorted neural data...');
    sorted = shared_utils.io.fload( fullfile(data_p,...
      'sorted_neural_data_social_gaze.mat') );
else
    disp( 'Using existing sorted data in workspace' );
end

% Celltype labels
if ~exist( 'ct_labels', 'var' )
    disp( 'Loading celltype labels data...');
    ct_labels = shared_utils.io.fload(fullfile( data_p,...
        'celltype-labels_pfc-combined-class_p2v.mat'), 'ct_labels' );
else
    disp( 'Using existing ct_labels in workspace' );
end
disp( 'Done' );

%% Preprocessing Neural data

disp( 'Preprocessing data...' );
[unit_spike_ts, unit_wfs, spike_labels] = eisg.util.linearize_sorted( sorted );
bfw.add_monk_labels( spike_labels );
[uuid_I, uuids] = findall( spike_labels, 'uuid',...
  find( spike_labels, validity_filter ) );
match_I = bfw.find_combinations( ct_labels, uuids );
for i = 1:numel(uuid_I)
  if ( ~isempty( match_I{i} ) )
    ct_label = cellstr( ct_labels, 'cell-type', match_I{i} );
    addsetcat( spike_labels, 'cell-type', ct_label, uuid_I{i} );
  end
end
replace( spike_labels, 'n', 'narrow' );
replace( spike_labels, 'm', 'broad' );
replace( spike_labels, 'b', 'outlier' );
disp( 'Done' );


%%
% disp_size tells us about the calibration window size for the task. The
% offset kinda tells us how far the (0,0) point is from the top left edge
% of the 3-monitor window. so, if the offset is added to each data point or
% bounding box coordinate, then the points will be mapped in the space
% of the 3-monitor calibration window

% Gets you the offsets
offsets = table();
for i = 1:numel(offset_file_list)
    offset_file = shared_utils.io.fload( offset_file_list{i} );
    offsets = [ offsets; table(offset_file.m1(:)', string(offset_file.unified_filename) ...
        , 'va', {'offsets', 'unified_filename'}) ];
end

%%

% Viewer design parameters
border_fraction         = 0.05;
font_size               = 20;
menu_pos_wrt_fig        = [0.7 0.85];
menu_width              = 100; %px
menu_height             = 30; %px
menu_x_offset           = 0.065;
run_menu_y_offset       = 0.03;
menu_font_size          = 16;

%
pause_time = 0.02;


params                      = struct();

% Viewer design parameters
params.font_size                = font_size;
params.menu_pos_wrt_fig         = menu_pos_wrt_fig;
params.menu_width               = menu_width; %px
params.menu_height              = menu_height; %px
params.menu_x_offset            = menu_x_offset;
params.run_menu_y_offset        = run_menu_y_offset;
params.menu_font_size           = menu_font_size;
params.border_fraction          = border_fraction;

params.pos_file_list        = pos_file_list;
params.fix_file_list        = fix_file_list;
params.roi_file_list        = roi_file_list;
params.bounds_file_list     = bounds_file_list;
params.time_file_list       = time_file_list;

params.rois_of_interest     = rois_of_interest;

params.session_per_file     = session_per_file;
params.current_session      = current_session;
params.run_number_per_file  = run_number_per_file;
params.current_run          = current_run;
params.current_time_ind     = current_time_ind;
params.disp_time_win        = disp_time_win;
params.pause_time           = pause_time;
params.n_frames             = n_frames;

params.monitor_size         = monitor_size;

start_social_gaze_viewer(params);

% plot_gaze_loc_last_n_sec(params);

%%
start_social_gaze_viewer(params);

%%
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

    [session_menu, run_menu, all_sessions, runs_in_session] = make_dropdown_menus(fig, ...
        params, @get_files_and_make_plots);
    
    get_files_and_make_plots();

    function get_files_and_make_plots(~, ~)
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


        params = make_display( fig, behav_data, params );
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


function [session_menu, run_menu, all_sessions, runs_in_session] = make_dropdown_menus(fig,...
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



function params = make_display(fig, behav_data, params)
    
    current_time_ind = params.current_time_ind;
    disp_time_win = params.disp_time_win;
    pause_time = params.pause_time;

    if isempty(current_time_ind)
        current_time_ind = 1;
    end

    set(fig, 'KeyPressFcn', @space_bar_callback);
    set(fig, 'KeyPressFcn', @escape_callback);
    is_paused = false;
    stop_time_loop = false;
    
    ax = struct();
    ax.m1 = axes('Position', [0.1 0.6 0.4 0.9]);
    ax.m2 = axes('Position', [0.6 0.6 0.9 0.9]);

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
scatter(x_vec, y_vec, 50, cmap, 'filled');
    
start_time = time_vec(disp_time_inds(1));
current_time = time_vec(disp_time_inds(2));
colormap(gca, cmap);
clim([start_time, current_time]); % Set colorbar limits
colorbar;
title( sprintf('%s Gaze Location from t=%0.3fs to %0.3fs', ...
    monkey, start_time, current_time ) );

end




%% Helper functions

function tf = is_hidden(f)

fnames = shared_utils.io.filenames( f );
tf = startsWith( fnames, '.' );

end

%%

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

%% Old display function

function plot_gaze_loc_last_n_sec(params)

% Use the tic and toc functions in here to see how much time it takes for
% the set of computations needed for each frame of the plot. Set your
% refresh rate accordingly. Also check of you have mean_comp_time=x and
% then you add a pause for y amount of time, then does the time gap now
% become x+y on an average. Will help with setting up a parametrised
% refresh rate with a good approximation of the max value
    current_session = params.current_session;
    current_run = params.current_run;
    pos_file_list = params.pos_file_list;
    time_file_list = params.time_file_list;
    roi_file_list = params.roi_file_list;
    bounds_file_list = params.bounds_file_list;
    sessions = params.sessions;
    run_numbers = params.run_numbers;
    current_time_ind = params.current_time_ind;
    disp_time_win = params.disp_time_win;
    rois_of_interest = params.rois_of_interest;
    pause_time = params.pause_time;
    n_frames = params.n_frames;

    if isempty(current_session)
        current_session = sessions{1};
    end

    if isempty(current_run)
        current_run = run_numbers{1};
    end

    if isempty(current_time_ind)
        current_time_ind = 1;
    end

    tot_files = numel(pos_file_list);
    current_file_ind = strcmp(sessions, current_session) & ...
        strcmp(run_numbers, current_run);

    fig = gcf;
    set(fig, 'KeyPressFcn', @key_pressed_callback);
    is_paused = false;

    if ~(current_file_ind > tot_files)
        pos_file = pos_file_list{current_file_ind};
        time_file = time_file_list{current_file_ind};
        roi_file = roi_file_list{current_file_ind};
        bounds_file = bounds_file_list{current_file_ind};

        time_struct = load(time_file);
        time_struct = time_struct.var;
        time_vec = time_struct.t;

        pos_struct = load(pos_file);
        pos_struct = pos_struct.var;
        pos_vec_m1 = pos_struct.m1;
        pos_vec_m2 = pos_struct.m2;

        roi_struct = load(roi_file);
        roi_struct = roi_struct.var;

        % compute if location at each time point 'is fixation'
        fix_params = bfw.make.defaults.raw_fixations;
        non_nan = ~isnan(time_vec);

        fix_vec_m1 = is_fixation( ...
            pos_struct.m1, time_vec' ...
            , fix_params.t1, fix_params.t2, fix_params.min_duration);
        fix_vec_m1 = fix_vec_m1(1:end-1);

        fix_vec_m2 = is_fixation( ...
            pos_struct.m2, time_vec' ...
            , fix_params.t1, fix_params.t2, fix_params.min_duration);
        fix_vec_m2 = fix_vec_m2(1:end-1);

        roi_rects = get_roi_rects(roi_struct, rois_of_interest);

        % using current time, time window, and time
        n_inds_disp_time = disp_time_win * 1e3; % seconds to milli-seconds
        
        %%%% LOTS OF HARDCODING HERE!!! %%%%
        current_time_ind = randsample( numel(time_vec), 1 );
        n_frames = randsample( numel(time_vec) - current_time_ind, 1 );
        end_ind = current_time_ind + n_frames;
        %%%% LOTS OF HARDCODING HERE!!! %%%%

        while current_time_ind < end_ind
            if ( is_paused )
                drawnow;
                pause(0.1);
                continue;
            end
        
            disp_ind_start = max(1, current_time_ind - n_inds_disp_time + 1);
            disp_time_inds = disp_ind_start:current_time_ind;
    
            x_vec = pos_vec_m1(1, disp_time_inds)';
            y_vec = pos_vec_m1(2, disp_time_inds)';

            [~, cmap] = plot_gaze_locs_with_cmap(x_vec, y_vec);
    
            start_time = time_vec(disp_ind_start);
            current_time = time_vec(current_time_ind);

            % Set colorbar to reflect the colormap
            colormap(gca, cmap);
            caxis([start_time, current_time]); % Set colorbar limits
        
            colorbar;

            title( sprintf('M1 Gaze Location from t=%0.3fs to %0.3fs'...
                , start_time, current_time )...
                );

            current_time_ind = current_time_ind + 1;

            drawnow;

            %pause(pause_time);

        end

    end

    function key_pressed_callback(~, event)
        if ( strcmp(event.Key, 'space') )
            is_paused = ~is_paused;
        end
    end
end

function [scatter_handle, cmap] = plot_gaze_locs_with_cmap(x_vec, y_vec)
    % Calculate colormap going from white to black
    white_to_black_cmap = linspace(1, 0, length(x_vec))';
    cmap = [white_to_black_cmap, white_to_black_cmap, white_to_black_cmap]; % RGB values
    
    % Plot scatter points with specified color and size
    scatter_handle = scatter(x_vec, y_vec, 50, cmap, 'filled');
    % drawnow;
end



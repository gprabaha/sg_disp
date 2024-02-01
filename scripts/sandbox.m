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


% Paremeters for viewer
current_session         = '';
current_run             = '';
current_time_ind        = 151263;
disp_time_win           = 2; % seconds
monitor_size            = [1 1 1200 800]; % x1 y1 x2 y2
refresh_rate            = 10; % roughly the number of times a new screen-flip happens per second | human perception is 10hz

% Paths for raw beavior
raw_behavior_root   = fullfile(data_p,            'raw_behavior');
pos_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/position');
time_dir            = fullfile(raw_behavior_root, 'aligned_raw_samples/time');
bounds_dir          = fullfile(raw_behavior_root, 'aligned_raw_samples/bounds');
fix_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/raw_eye_mmv_fixations');
meta_dir            = fullfile(raw_behavior_root, 'meta');
events_dir          = fullfile(raw_behavior_root, 'raw_events_remade');
roi_dir             = fullfile(raw_behavior_root, 'rois');

% List of positions, fixations, and ROIs
pos_file_list = shared_utils.io.findmat( pos_dir );
fix_file_list = shared_utils.io.findmat( fix_dir );
roi_file_list = shared_utils.io.findmat( roi_dir );
bounds_file_list = shared_utils.io.findmat( bounds_dir );
time_file_list = shared_utils.io.findmat( time_dir );

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

sessions = cell( numel( pos_file_list ), 1 );
run_numbers = cell( numel( pos_file_list ), 1 );

% Loop through each path and extract the session and run number from the
% filename
for i = 1:numel(pos_file_list)
    [~, filename, ~] = fileparts(pos_file_list{i});
    split_filename = strsplit(filename, '_');
    sessions{i} = split_filename{1};
    run_numbers{i} = split_filename{3};
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

params                      = struct();
params.pos_file_list        = pos_file_list;
params.fix_file_list        = fix_file_list;
params.roi_file_list        = roi_file_list;
params.bounds_file_list     = bounds_file_list;
params.time_file_list       = time_file_list;

params.rois_of_interest     = rois_of_interest;

params.sessions             = sessions;
params.current_session      = current_session;
params.run_numbers          = run_numbers;
params.current_run          = current_run;
params.current_time_ind     = current_time_ind;
params.disp_time_win        = disp_time_win;

params.monitor_size         = monitor_size;

plot_gaze_loc_last_n_sec(params);








%%
monkey = 'm1';

%%

screenSize = get(0, 'ScreenSize');
width = screenSize(3);
height = screenSize(4);

fprintf('Screen width: %d pixels\n', width);
fprintf('Screen height: %d pixels\n', height);

%%






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

%%
function plot_gaze_loc_last_n_sec(params)
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
        disp_ind_start = max(1, current_time_ind - n_inds_disp_time + 1);

        disp_time_inds = disp_ind_start:current_time_ind;

        x_vec = pos_vec_m1(1, disp_time_inds)';
        y_vec = pos_vec_m1(2, disp_time_inds)';

        [~, cmap] = plot_gaze_locs_with_increasing_opacity(x_vec, y_vec);

        start_time = time_vec(disp_ind_start);
        current_time = time_vec(current_time_ind);

        % Set colorbar to reflect the colormap
        colormap(gca, cmap);
        caxis([start_time, current_time]); % Set colorbar limits
    
        colorbar;

        title( sprintf('M1 Gaze Location from t=%0.3fs to %0.3fs'...
            , start_time, current_time )...
            );

    end
end

function [scatter_handle, cmap] = plot_gaze_locs_with_increasing_opacity(x_vec, y_vec)
    % Calculate colormap going from white to black
    white_to_black_cmap = linspace(1, 0, length(x_vec))';
    cmap = [white_to_black_cmap, white_to_black_cmap, white_to_black_cmap]; % RGB values
    
    % Plot scatter points with specified color and size
    scatter_handle = scatter(x_vec, y_vec, 50, cmap, 'filled');
end



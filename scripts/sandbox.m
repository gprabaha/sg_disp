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
play_pause_position     = [0.43 0.85];
play_pause_size         = [0.07 0.05];
menu_pos_wrt_fig        = [0.43 0.87];
menu_width              = 100; %px
menu_height             = 30; %px
menu_x_offset           = 0.065;
run_menu_y_offset       = 0.03;
menu_font_size          = 16;
m1_axes                 = [0.05 0.55 0.37 0.37];
m2_axes                 = [0.55 0.55 0.37 0.37];

%
pause_time = 0.02;


params                      = struct();

% Viewer design parameters
params.font_size                = font_size;
params.play_pause_position      = play_pause_position;
params.play_pause_size          = play_pause_size;
params.menu_pos_wrt_fig         = menu_pos_wrt_fig;
params.menu_width               = menu_width; %px
params.menu_height              = menu_height; %px
params.menu_x_offset            = menu_x_offset;
params.run_menu_y_offset        = run_menu_y_offset;
params.menu_font_size           = menu_font_size;
params.border_fraction          = border_fraction;
params.m1_axes                  = m1_axes;
params.m2_axes                  = m2_axes;

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

sg_disp.viewer.start_social_gaze_viewer(params);

% plot_gaze_loc_last_n_sec(params);

%%
start_social_gaze_viewer(params);

%%



%% Helper functions

function tf = is_hidden(f)

fnames = shared_utils.io.filenames( f );
tf = startsWith( fnames, '.' );

end




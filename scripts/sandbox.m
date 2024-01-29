%% Workspace cleanup
clear;
clc;

%% Script parameters

% Data root
data_p              = fullfile(sg_disp.util.project_path, 'processed_data');

% Paremeters for viewer
current_session     = '';
current_run         = '';

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

%%

sessions = cell( numel( pos_file_list ), 1 );
run_number = nan( numel( pos_file_list ), 1 );

% Loop through each path and extract the filename
for i = 1:numel(pos_file_list)
    [~, filename, ~] = fileparts(pos_file_list{i});
    split_filename = strsplit(filename, '_');
    sessions{i} = split_filename{1};
    run_number(i) = split_filename{3};
end

% Display gaze position for a particular run in a session
if ~isempty(current_session)
    current_session = sessions{1};
end

if ~isempty(current_run)
    current_run = run_number{1};
end

disp_m1_gaze_pos( params, )


%% Helper functions

function tf = is_hidden(f)
    fnames = shared_utils.io.filenames( f );
    tf = startsWith( fnames, '.' );
end

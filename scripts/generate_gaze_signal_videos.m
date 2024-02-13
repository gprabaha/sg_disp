
% Data root
data_p = fullfile( sg_disp.util.project_path, 'processed_data' );

%% Load neural spiking data
disp( 'Loading spike data...' );

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


%% Preprocess and linearlize neural data
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

%% List paths to eyetracking data files
% Paths for raw beavior
raw_behavior_root   = fullfile(data_p,            'raw_behavior');
pos_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/position');
time_dir            = fullfile(raw_behavior_root, 'aligned_raw_samples/time');
bounds_dir          = fullfile(raw_behavior_root, 'aligned_raw_samples/bounds');
fix_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/raw_eye_mmv_fixations');
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

% Loop through each path and extract the session and run number from the
% filename
session_per_file = cell( numel( pos_file_list ), 1 );
run_number_per_file = cell( numel( pos_file_list ), 1 );
for i = 1:numel(pos_file_list)
    [~, filename, ~] = fileparts(pos_file_list{i});
    split_filename = strsplit(filename, '_');
    session_per_file{i} = split_filename{1};
    run_number_per_file{i} = split_filename{3};
end

%% Parameters
params                              = struct();
params.data_p                       = data_p;
% Data extraction
params.total_pos_file_number        = NaN;
params.current_pos_file_number      = NaN;
params.current_session              = NaN;
params.current_run                  = NaN;
params.rois_of_interest             = {'eyes', ...
    'mouth', ...
    'face', ...
    'left_nonsocial_object', ...
    'right_nonsocial_object'};
params.time_ind_update_method       = 'second_non_nan';
params.validity_filter              = {'valid-unit', 'maybe-valid-unit'};
params.excluded_categories          = {'outlier', ... % from spike labels
    '<cell-type>', ... 
    'ofc', ...
    'dmpfc'};
% Different categories of interest
params.monkeys                      = {'m1', 'm2'};
params.celltypes                    = {'narrow', 'broad'};
params.regions                      = {'acc', 'bla'};
% Plotting
params.disp_time_win                = 0.5; % seconds
params.monitor_size                 = [1024 768];
params.screen_prop_to_display       = 0.6;

spike_data                          = struct();
spike_data.unit_spike_ts            = unit_spike_ts;
spike_data.spike_labels             = spike_labels;

%%

num_pos_files = numel(pos_file_list);
params.total_pos_file_number = num_pos_files;
% for i = 1:num_pos_files
for i = 175
    params.current_pos_file_number = i;
    [~, filename, ~] = fileparts(pos_file_list{i});
    split_filename = strsplit(filename, '_');
    current_session = split_filename{1};
    params.current_session = current_session;
    current_run = split_filename{3};
    params.current_run = current_run;
    
    pos_file = pos_file_list{i};
    time_file = time_file_list{i};
    fix_file = fix_file_list{i};
    roi_file = roi_file_list{i};
    offset_file = offset_file_list{i};
    
    time_struct = load(time_file);
    time_struct = sg_disp.util.get_sub_struct( time_struct );
    pos_struct = load(pos_file);
    fix_struct = load(fix_file);
    roi_struct = load(roi_file);
    offset_struct = load(offset_file);
    
    behav_data                      = struct();
    behav_data.start_time_ind       = sg_disp.util.get_start_time_ind_for_file( ...
        time_struct.t, params.time_ind_update_method );
    behav_data.end_time_ind         = sg_disp.util.get_end_time_ind_for_file( ...
        time_struct.t );
    behav_data.time_vec             = time_struct.t;
    behav_data.pos_vecs             = sg_disp.util.get_sub_struct( pos_struct );
    behav_data.fix_vecs             = sg_disp.util.get_sub_struct( fix_struct );
    behav_data.roi_rects            = sg_disp.util.get_roi_rects( ...
        roi_struct.var, rois_of_interest );
    behav_data.offsets              = sg_disp.util.get_sub_struct( offset_struct );
    
    sg_disp.vid_gen.extract_and_save_video_data_for_one_file( behav_data, spike_data, params );

end












extract_data_for_gaze_signal_video_generation( params );

function [pos_file_list, fix_file_list, roi_file_list, bounds_file_list, ...
    time_file_list, offset_file_list, session_per_file, run_number_per_file] ...
    = fetch_behavior_files(data_p)
    % Construct paths based on data_p
    raw_behavior_root   = fullfile(data_p,            'raw_behavior');
    pos_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/position');
    time_dir            = fullfile(raw_behavior_root, 'aligned_raw_samples/time');
    bounds_dir          = fullfile(raw_behavior_root, 'aligned_raw_samples/bounds');
    fix_dir             = fullfile(raw_behavior_root, 'aligned_raw_samples/raw_eye_mmv_fixations');
    meta_dir            = fullfile(raw_behavior_root, 'meta');
    events_dir          = fullfile(raw_behavior_root, 'raw_events_remade');
    roi_dir             = fullfile(raw_behavior_root, 'rois');
    offset_dir          = fullfile(raw_behavior_root, 'single_origin_offsets');

    % List of positions, fixations, ROIs, etc.
    pos_file_list = shared_utils.io.findmat( pos_dir );
    fix_file_list = shared_utils.io.findmat( fix_dir );
    roi_file_list = shared_utils.io.findmat( roi_dir );
    bounds_file_list = shared_utils.io.findmat( bounds_dir );
    time_file_list = shared_utils.io.findmat( time_dir );
    offset_file_list = shared_utils.io.findmat( offset_dir );

    % Remove hidden files
    pos_file_list = remove_hidden_files( pos_file_list );
    fix_file_list = remove_hidden_files( fix_file_list );
    roi_file_list = remove_hidden_files( roi_file_list );
    bounds_file_list = remove_hidden_files( bounds_file_list );
    time_file_list = remove_hidden_files( time_file_list );
    offset_file_list = remove_hidden_files( offset_file_list );

    % Match files based on filenames
    [roi_file_list, bounds_file_list, offset_file_list, time_file_list] = ...
        match_files(roi_file_list, bounds_file_list, offset_file_list, time_file_list);

    % Extract session and run number from filename
    [session_per_file, run_number_per_file] = extract_session_run(pos_file_list);
end

function files = remove_hidden_files(files)
    fnames = shared_utils.io.filenames(files);
    files(startsWith(fnames, '.')) = [];
end

function [matched_roi_files, matched_bounds_files, matched_offset_files, matched_time_files] = ...
    match_files(roi_files, bounds_files, offset_files, time_files)

    fnames_roi = shared_utils.io.filenames(roi_files);
    fnames_bounds = shared_utils.io.filenames(bounds_files);
    fnames_offset = shared_utils.io.filenames(offset_files);
    fnames_time = shared_utils.io.filenames(time_files);
    
    common_fnames = intersect( intersect( intersect( fnames_roi, fnames_bounds ), fnames_offset ), fnames_time );
    
    matched_roi_files = roi_files(ismember(fnames_roi, common_fnames));
    matched_bounds_files = bounds_files(ismember(fnames_bounds, common_fnames));
    matched_offset_files = offset_files(ismember(fnames_offset, common_fnames));
    matched_time_files = time_files(ismember(fnames_time, common_fnames));
end

function [session_per_file, run_number_per_file] = extract_session_run(pos_file_list)
    session_per_file = cell(numel(pos_file_list), 1);
    run_number_per_file = cell(numel(pos_file_list), 1);

    for i = 1:numel(pos_file_list)
        [~, filename, ~] = fileparts(pos_file_list{i});
        split_filename = strsplit(filename, '_');
        session_per_file{i} = split_filename{1};
        run_number_per_file{i} = split_filename{3};
    end
end
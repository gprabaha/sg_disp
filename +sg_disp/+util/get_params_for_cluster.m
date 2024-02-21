function params = get_params_for_cluster()
    
    data_p = fullfile( sg_disp.util.project_path, 'processed_data' );
    % Fetch list of eyetracking files
    [pos_file_list, fix_file_list, roi_file_list, bounds_file_list, ...
        time_file_list, offset_file_list, session_per_file, run_number_per_file] ...
        = sg_disp.util.fetch_behavior_files( data_p );
    spike_data_filename = 'spike_data_celltype_labelled.mat';

    params                          = struct();
    % Data path
    params.data_p                   = data_p;
    % Cluster specific params
    params.cluster_out_path         = '/gpfs/milgram/scratch60/chang/pg496/';
    params.video_output_folder      = 'gaze_signal_videos_1000fps';
    params.mem_per_cpu              = 200; % gbs
    params.num_cpu                  = 10;
    % Behavioral file paths
    params.pos_file_list            = pos_file_list;
    params.fix_file_list            = fix_file_list;
    params.roi_file_list            = roi_file_list;
    params.bounds_file_list         = bounds_file_list;
    params.time_file_list           = time_file_list;
    params.offset_file_list         = offset_file_list;
    params.session_per_file         = session_per_file;
    params.run_number_per_file      = run_number_per_file;
    % Behavior display parameters
    params.rois_of_interest         = {'eyes'...
        , 'mouth'...
        , 'face'...
        , 'left_nonsocial_object'...
        , 'right_nonsocial_object'};
    % Spike file paths
    params.spike_data_filename      = spike_data_filename;
    % Spike display paremeters
    params.unit_validity_filter     = {'valid-unit', 'maybe-valid-unit'};
    params.raster_bin_width         = 0.001; % ms
    params.kernel_size              = 101; % 101 ms moving window
    params.celltypes_of_interest    = {'narrow', 'broad'};
    params.z_score_stdev_bound      = 5;
    % General video and figure paramerters
    params.frame_rate               = 1000;
    params.video_quality            = 50;
    params.clustur_job_suffix       = '500fps';
    params.disp_time_win            = 0.5; % seconds
    params.calib_monitor_size       = [1024 768]; % px
    params.screen_prop_to_display   = 0.6; % float
    params.progress_interval        = 1000; % print progress after n frames
    params.fig_position             = [0 0 1600 900]; % px
    params.font_size                = 25; % px
    params.m1_axis                  = [0.05 0.52 0.42 0.4]; % [x1 y1 width height] (normalized)
    params.m2_axis                  = [0.55 0.52 0.42 0.4];
    params.legend_axis              = [0.05 0.5 0.42 0.05];
    params.acc_axis                 = [0.05 0.05 0.42 0.42];
    params.bla_axis                 = [0.55 0.05 0.42 0.42];

end
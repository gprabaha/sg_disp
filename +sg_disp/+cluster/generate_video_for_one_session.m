function generate_video_for_one_session(session, params)

data_p                  = params.data_p;
pos_file_list           = params.pos_file_list;
time_file_list          = params.time_file_list;
fix_file_list           = params.fix_file_list;
roi_file_list           = params.roi_file_list;
offset_file_list        = params.offset_file_list;
session_per_file        = params.session_per_file;
run_number_per_file     = params.run_number_per_file;

spike_data              = load( fullfile( data_p, 'spike_data_celltype_labelled.mat' ) );
spike_data              = sg_disp.util.get_sub_struct( spike_data );

file_inds_for_session = find( strcmp( session_per_file, session ) );

for file_ind = file_inds_for_session'
    run_number = run_number_per_file{file_ind};
    pos_file = pos_file_list{file_ind};
    time_file = time_file_list{file_ind};
    fix_file = fix_file_list{file_ind};
    roi_file = roi_file_list{file_ind};
    offset_file = offset_file_list{file_ind};
    
    time_struct = load( time_file );
    time_struct = sg_disp.util.get_sub_struct( time_struct );
    pos_struct = load( pos_file );
    fix_struct = load( fix_file );
    roi_struct = load( roi_file );
    offset_struct = load( offset_file );
    
    behav_data                      = struct();
    behav_data.session              = session;
    behav_data.run_number           = run_number;
    behav_data.start_time_ind       = sg_disp.util.get_start_time_ind_for_file( ...
        time_struct.t );
    behav_data.end_time_ind         = sg_disp.util.get_end_time_ind_for_file( ...
        time_struct.t );
    behav_data.time_vec             = time_struct.t;
    behav_data.pos_vecs             = sg_disp.util.get_sub_struct( pos_struct );
    behav_data.fix_vecs             = sg_disp.util.get_sub_struct( fix_struct );
    behav_data.roi_rects            = sg_disp.util.get_roi_rects( ...
        roi_struct.var, params.rois_of_interest );
    behav_data.offsets              = sg_disp.util.get_sub_struct( offset_struct );
    
    sg_disp.cluster.generate_video_for_one_file_within_session( behav_data, spike_data, params );
end
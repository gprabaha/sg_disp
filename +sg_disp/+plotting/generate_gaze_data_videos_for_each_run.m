function generate_gaze_data_videos_for_each_run(params)

pos_file_list = params.pos_file_list;
time_file_list = params.time_file_list;
fix_file_list = params.fix_file_list;
roi_file_list = params.roi_file_list;
offset_file_list = params.offset_file_list;
session_per_file = params.session_per_file;
run_number_per_file = params.run_number_per_file;
rois_of_interest = params.rois_of_interest;
time_ind_reset_method = params.time_ind_reset_method;


for i=1:numel(session_per_file)
    session = session_per_file{i};
    run_number = run_number_per_file{i};

    behav_data = struct();
    pos_file = pos_file_list{i};
    time_file = time_file_list{i};
    fix_file = fix_file_list{i};
    roi_file = roi_file_list{i};
    offset_file = offset_file_list{i};
    
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
    params.current_session = session;
    params.current_run = run_number;

    behav_data.time_vec = time_struct.t;
    behav_data.pos_vecs = get_sub_struct( pos_struct );
    behav_data.fix_vecs = get_sub_struct( fix_struct );
    behav_data.roi_rects = sg_disp.util.get_roi_rects( roi_struct.var, rois_of_interest );
    behav_data.offsets = get_sub_struct( offset_struct );

    sg_disp.plotting.make_video_for_one_file( behav_data, params );
end

end



function str = get_sub_struct( input_struct )
    if numel(fieldnames(input_struct)) > 1
        error('Struct has more than one fields!');
    end
    str = input_struct.( char( fieldnames(input_struct) ) );
end



function current_time_ind = update_current_time_ind(time_vec, update_method)
    % Validate input update_method
    if ~(strcmp(update_method, 'randsample') || strcmp(update_method, 'reset') || strcmp(update_method, 'second_non_nan'))
        error('update_method must be either ''randsample'' or ''reset'' or ''second_non_nan''.');
    end
    % Determine the current time index based on the update method
    if strcmp(update_method, 'randsample')
        % Randomly select an index from time_vec using randsample
        current_time_ind = randsample(length(time_vec), 1);
    elseif strcmp(update_method, 'reset')
        % If update_method is 'reset', set current_time_ind to 1
        current_time_ind = 1;
    else
        % If update_method is 'first_non_nan', set current_time_ind to 1
        first_two_time_inds = find(  ~isnan( time_vec ), 2);
        current_time_ind = first_two_time_inds(2);
    end
end
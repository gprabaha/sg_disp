function vid_gen_frames = extract_and_save_video_data_for_one_file(behav_data, spike_data, params)

session = params.current_session;
run = params.current_run;

% Extraction start display
disp(['Starting extraction for position file ' ...
    num2str( params.current_pos_file_number ) '/' ...
    num2str( params.total_pos_file_number )]);

vid_gen_frames = struct();

% Data for each frame of M1 and M2 gaze position display
[gaze_m1, gaze_m2] = sg_disp.vid_gen.extract_gaze_pos_frames_for_both_monkeys( ...
   behav_data, params );

% Data for each frame of ACC or BLA spike display
[spikes_acc, spikes_bla, spike_abs_error_acc, spike_abs_error_bla] = ...
    sg_disp.vid_gen.extract_unit_spiking_frames_for_acc_and_bla( ...
    behav_data, spike_data, params );

vid_gen_frames.gaze_m1 = gaze_m1;
vid_gen_frames.gaze_m2 = gaze_m2;
vid_gen_frames.spikes_acc = spikes_acc;
vid_gen_frames.spikes_bla = spikes_bla;
vid_gen_frames.spike_abs_error_acc = spike_abs_error_acc;
vid_gen_frames.spike_abs_error_bla = spike_abs_error_bla;

data_p = params.data_p;
folder_name = 'gaze_vid_files';
save_folder = fullfile( data_p, folder_name, session );
file_name = sprintf( 'gaze_signal_vid_frames_session_%s_run_%02d.mat', session, str2double( run ) );
filepath = fullfile( save_folder, file_name, '-v7.3' );
if ~exist(save_folder, 'dir')
    % If the folder doesn't exist, create it
    mkdir(save_folder);
end
disp('Saving vid frames file...');
save( filepath, 'vid_gen_frames', '-v7.3' );
disp('Saved file');

% Extraction completion display
disp(['        Finished: position file ' ...
    num2str( params.current_pos_file_number ) '/' ...
    num2str( params.total_pos_file_number )]);
end
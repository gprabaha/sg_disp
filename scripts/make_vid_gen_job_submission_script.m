
%%

data_p                  = fullfile( sg_disp.util.project_path, 'processed_data' );

spike_data_filename     = 'spike_data_celltype_labelled.mat';
spike_data              = load( fullfile( data_p, spike_data_filename ) );
spike_data              = sg_disp.util.get_sub_struct( spike_data );
spike_labels            = spike_data.spike_labels;

%%
params                  = sg_disp.util.get_params_for_cluster();

%%

template_text = string( fileread('cluster_template_script.txt') );
job_submit_text = "";
session_per_file = params.session_per_file;
unique_sessions = unique( session_per_file );

for session_index = 1:numel( unique_sessions )
    session = unique_sessions{session_index};
    inds_of_units_in_session = find( spike_labels, session );
    if ~isempty( inds_of_units_in_session )
        regions_in_session = spike_labels(inds_of_units_in_session, 'region');
        if any( strcmp( regions_in_session, 'bla') | strcmp( regions_in_session, 'acc') )

            job_submit_script = compose( template_text, session, session, session, session );
            fid = fopen( sprintf('cluster/%s_vid_gen.sh', session), 'w' );
            fwrite( fid, job_submit_script );
            fclose( fid );
            
            job_submit_text = job_submit_text + compose("sbatch cluster/%s_vid_gen.sh\n", session);
            % sg_disp.cluster.generate_video_for_one_session( session, params );

        end
    end
end

fid = fopen( 'submit_vid_gen_jobs.sh', 'w' );
fwrite( fid, job_submit_text );
fclose( fid );
!chmod +x submit_vid_gen_jobs.sh

%%
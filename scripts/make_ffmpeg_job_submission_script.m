%%
params                  = sg_disp.util.get_params_for_cluster();
session_per_file        = params.session_per_file;
data_p                  = params.data_p;

spike_data_filename     = 'spike_data_celltype_labelled.mat';
spike_data              = load( fullfile( data_p, spike_data_filename ) );
spike_data              = sg_disp.util.get_sub_struct( spike_data );
spike_labels            = spike_data.spike_labels;

%%

template_text = string( fileread('cluster_ffmpeg_template_script.txt') );
job_submit_text = "";
unique_sessions = unique( session_per_file );

for session_index = 1:numel( unique_sessions )
    session = unique_sessions{session_index};
    inds_of_units_in_session = find( spike_labels, session );
    if ~isempty( inds_of_units_in_session )
        regions_in_session = spike_labels(inds_of_units_in_session, 'region');
        if any( strcmp( regions_in_session, 'bla') | strcmp( regions_in_session, 'acc') )

            job_submit_script = compose( template_text, ...
                session, ... % jobname
                session, ... % output
                session, ... % error
                session ); % bash input
            fid = fopen( sprintf('cluster/%s_ffmpeg_conv.sh', session), 'w' );
            fwrite( fid, job_submit_script );
            fclose( fid );
            
            job_submit_text = job_submit_text + compose("sbatch cluster/%s_ffmpeg_conv.sh\n", session);
        end
    end
end

fid = fopen( 'submit_ffmpeg_jobs.sh', 'w' );
fwrite( fid, job_submit_text );
fclose( fid );
!chmod +x submit_ffmpeg_jobs.sh



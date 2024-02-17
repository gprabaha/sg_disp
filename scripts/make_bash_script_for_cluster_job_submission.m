template_text = string( fileread('example_template.txt') );

%%
% whatever matlab script is called in the cluster, add some sort of a
% startup script on top of it

job_submit_text = "";

sessions = {'01022019', '01032019'};
cpus_per_task = 24;

for i = 1:numel(sessions)

    session = sessions{i};
    
    actual_script = compose( template_text, cpus_per_task, sprintf("'%s'", session) );
    
    fid = fopen( sprintf('%s.sh', session), 'w' );
    fwrite( fid, actual_script );
    fclose( fid );
    
    job_submit_text = job_submit_text + compose("sbatch %s.sh\n", session);

end

fid = fopen( 'submit.sh', 'w' );
fwrite( fid, job_submit_text );
fclose( fid );
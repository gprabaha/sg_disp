function p = project_path()
p = fileparts( fileparts(fileparts(which('sg_disp.util.project_path'))) );
end
function tf = is_hidden(f)

fnames = shared_utils.io.filenames( f );
tf = startsWith( fnames, '.' );

end
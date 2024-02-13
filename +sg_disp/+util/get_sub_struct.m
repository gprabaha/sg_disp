function out_struct = get_sub_struct( input_struct )
    if numel(fieldnames(input_struct)) > 1
        error('Struct has more than one fields!');
    end
    out_struct = input_struct.( char( fieldnames(input_struct) ) );
end
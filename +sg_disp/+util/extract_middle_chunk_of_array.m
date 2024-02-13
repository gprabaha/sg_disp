function middle_chunk = extract_middle_chunk_of_array(array, f)
    % Calculate number of elements to skip at the beginning and end
    num_elements = length(array);
    num_skip = round((1 - f) * num_elements / 2);
    % Extract middle fraction of the array
    middle_chunk = array(num_skip+1:end-num_skip);
end
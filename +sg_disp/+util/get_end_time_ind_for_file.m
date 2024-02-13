function last_non_nan_ind = get_end_time_ind_for_file(time_vec)
    last_non_nan_ind = numel(time_vec) - find(~isnan(flip(time_vec)), 1) + 1;
end
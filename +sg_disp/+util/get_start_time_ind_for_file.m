function time_ind = get_start_time_ind_for_file(time_vec)
    first_two_time_inds = find(  ~isnan( time_vec ), 2);
    time_ind = first_two_time_inds(2);
end
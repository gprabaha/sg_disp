function disp_time_inds = calculate_disp_time_inds(current_time_ind, disp_time_win)
    num_time_inds_to_disp = disp_time_win * 1e3;
    disp_ind_start = max(1, current_time_ind - num_time_inds_to_disp + 1);
    disp_time_inds = disp_ind_start:current_time_ind;
end
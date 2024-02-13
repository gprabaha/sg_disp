function time_ind = get_start_time_ind_for_file(time_vec, update_method)
    % Determine the current time index based on the update method
    if strcmp(update_method, 'randsample')
        % Randomly select an index from time_vec using randsample
        time_ind = randsample(length(time_vec), 1);
    elseif strcmp(update_method, 'reset')
        % If update_method is 'reset', set current_time_ind to 1
        time_ind = 1;
    elseif strcmp(update_method, 'second_non_nan')
        % If update_method is 'first_non_nan', set current_time_ind to 1
        first_two_time_inds = find(  ~isnan( time_vec ), 2);
        time_ind = first_two_time_inds(2);
    else
        error('update_method must be either ''randsample'' or ''reset'' or ''second_non_nan''.');
    end
end
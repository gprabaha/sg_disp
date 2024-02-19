function spike_data = calculate_mean_and_std_activity_of_unit_within_run(...
    behav_data, spike_data, params)
% CALCULATE_MEAN_AND_STD_ACTIVITY_OF_UNIT_WITHIN_RUN calculates the mean
% and standard deviation moving-window spiking rate of each unit within a 
% specific run

    % Extract relevant data from behav_data
    session = behav_data.session;
    time_vec = behav_data.time_vec;
    start_time_ind = behav_data.start_time_ind;
    end_time_ind = behav_data.end_time_ind;
    
    % Extract relevant parameters from params
    unit_validity_filter = params.unit_validity_filter;
    raster_bin_width = params.raster_bin_width;
    kernel_size = params.kernel_size;
    
    % Extract spike data
    all_unit_spike_ts = spike_data.all_unit_spike_ts;
    spike_labels = spike_data.spike_labels;

    % Initialize arrays to store mean and std activity
    n_units = numel(all_unit_spike_ts);
    mean_activity = nan(n_units, 1);
    std_activity = nan(n_units, 1);
    max_activity = nan(n_units, 1);
    min_activity = nan(n_units, 1);
    
    % Find unit indices for the current session and validity filter
    unit_inds_for_session = find(spike_labels, [{session}, unit_validity_filter(:)']);
    
    % Define time range for the current run
    run_start_time = time_vec(start_time_ind);
    run_end_time = time_vec(end_time_ind);
    
    % Define time bin edges for activity calculation
    fulltime_bin_edges = run_start_time:raster_bin_width:run_end_time;
    n_fulltime_bins = numel(fulltime_bin_edges) - 1;

    % Loop over each unit
    for unit_ind = unit_inds_for_session'
        % Get spike timestamps for the current unit
        unit_spike_ts = all_unit_spike_ts{unit_ind};
        
        % Discretize spike timestamps into time bins
        spike_ind_in_full_time_bin = discretize(unit_spike_ts, fulltime_bin_edges);
        
        % Create a raster plot for the current unit
        full_unit_raster = zeros(1, n_fulltime_bins);
        full_unit_raster(~isnan(spike_ind_in_full_time_bin)) = 1;
        
        % Apply a kernel to smooth the raster plot
        kernel = sg_disp.util.get_moving_window_kernel(kernel_size);
        spiking_rate_vec = conv(full_unit_raster, kernel, 'same');
        
        % Calculate mean and std activity for the current unit
        mean_activity(unit_ind) = mean(spiking_rate_vec, 'omitnan');
        std_activity(unit_ind) = std(spiking_rate_vec, 'omitnan');
        max_activity(unit_ind) = max(spiking_rate_vec, [], 'omitnan');
        min_activity(unit_ind) = min(spiking_rate_vec, [], 'omitnan');
    end
    spike_data.unit_inds_for_session = unit_inds_for_session;
    spike_data.mean_activity = mean_activity;
    spike_data.std_activity = std_activity;

    mean_activity = mean_activity(~isnan( mean_activity ));
    std_activity = std_activity(~isnan( std_activity ));
    max_activity = max_activity(~isnan( max_activity ));
    max_activity_z = (max_activity - mean_activity)./std_activity;
    max_activity_z( isnan(max_activity_z) ) = 0;
    max_activity_z = max( max_activity_z );
    min_activity = min_activity(~isnan( min_activity ));
    min_activity_z = (min_activity - mean_activity)./std_activity;
    min_activity_z( isnan(min_activity_z) ) = 0;
    min_activity_z = min( min_activity_z );

    spike_data.max_activity_z = max_activity_z;
    spike_data.min_activity_z = min_activity_z;
end

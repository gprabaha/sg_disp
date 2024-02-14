function [spikes_acc, spikes_bla, spike_abs_error_acc, spike_abs_error_bla] ...
    = extract_unit_spiking_frames_for_acc_and_bla(behav_data, spike_data, params)
    
    % Extracting necessary data from input structures
    time_vec = behav_data.time_vec;
    start_time_ind = behav_data.start_time_ind;
    end_time_ind = behav_data.end_time_ind;
    
    unit_spike_ts = spike_data.unit_spike_ts;
    spike_labels = spike_data.spike_labels;
    
    % Extracting parameters
    session = params.current_session;
    regions = params.regions;
    cell_type_labels = params.celltypes;
    raster_bin_width = params.raster_bin_width;
    kernel_size = params.moving_window_kernel_size;
    disp_time_win = params.disp_time_win;
    num_frames_for_progress_disp = params.num_frames_for_progress_disp;
    
    % Initialize variables
    time_inds_of_interest = start_time_ind:end_time_ind;
    num_rows = numel(time_inds_of_interest);
    column_names = {'RasterMatrix', 'ZScoredSpiking', 'CelltypeLabel', ...
        'Region', 'CurrentTime', 'DispTimeWin'};
    spikes_acc = cell( num_rows, numel( column_names ) );
    spikes_bla = cell( num_rows, numel( column_names ) );
    spike_abs_error_acc = [];
    spike_abs_error_bla = [];

    % Finding units for the current session
    unit_inds_for_session = find(spike_labels, session);
    if isempty(unit_inds_for_session)
        spike_abs_error_acc = 'There are no valid units for this session';
        spike_abs_error_bla = 'There are no valid units for this session';
    else
        for region_ind = 1:numel(regions)
            region = regions{region_ind};
            unit_inds_for_region = find(spike_labels, region, unit_inds_for_session);
            if isempty(unit_inds_for_region)
                % No valid units for the current region
                non_region_label = prune(spike_labels(unit_inds_for_session));
                region_for_units = retaineach(non_region_label, 'region');
                region_for_units = region_for_units('region');
                if strcmp(region, 'acc')
                    spike_abs_error_acc = ['No valid units for ' region ', ' ...
                        'but units present in ' strjoin(region_for_units)];
                elseif strcmp(region, 'bla')
                    spike_abs_error_bla = ['No valid units for ' region ', ' ...
                        'but units present in ' strjoin(region_for_units)];
                end
            else
                % Valid units found for the current region
                n_units_in_region = numel(unit_inds_for_region);
                run_start_time = time_vec(start_time_ind);
                run_end_time = time_vec(end_time_ind);
                fulltime_bin_edges = run_start_time:raster_bin_width:run_end_time;
                n_fulltime_bins = numel(fulltime_bin_edges) - 1;
                mean_activity = nan(n_units_in_region, 1);
                std_activity = nan(n_units_in_region, 1);
                
                % Calculating mean and standard deviation of activity
                for unit_ind = 1:n_units_in_region
                    regional_unit_spike_ts = unit_spike_ts{unit_inds_for_region(unit_ind)};
                    spike_ind_in_full_time_bin = discretize(regional_unit_spike_ts, fulltime_bin_edges);
                    full_unit_raster = zeros(1, n_fulltime_bins);
                    full_unit_raster(~isnan(spike_ind_in_full_time_bin)) = 1;
                    kernel = sg_disp.util.get_moving_window_kernel(kernel_size);
                    spiking_rate_vec = conv(full_unit_raster, kernel, 'same');
                    mean_activity(unit_ind) = mean(spiking_rate_vec, 'omitnan');
                    std_activity(unit_ind) = std(spiking_rate_vec, 'omitnan');
                end

                % Looping through each time frame of interest
                for row_ind = 1:num_rows
                    current_time = time_vec(time_inds_of_interest(row_ind));
                    frame_start_time = current_time - disp_time_win;
                    bin_edges_for_raster_in_frame = frame_start_time:raster_bin_width:current_time;
                    bin_edges_for_spiking_rate_in_frame = sg_disp.util.get_extended_bin_edges_for_spiking_in_frame(...
                        frame_start_time, current_time, raster_bin_width, kernel_size);
                    num_bins_raster = numel(bin_edges_for_raster_in_frame) - 1;
                    num_bins_spiking = numel(bin_edges_for_spiking_rate_in_frame) - 1;
                    raster_mat = [];
                    z_scored_spiking_mat = [];
                    table_celltype_labels = {};
                    
                    % Looping through each cell type label
                    for celltype_label_ind = 1:numel(cell_type_labels)
                        celltype = cell_type_labels{celltype_label_ind};
                        regional_celltype_inds = find(spike_labels, celltype, unit_inds_for_region);
                        if ~isempty(regional_celltype_inds)
                            num_regional_celltype_inds = numel(regional_celltype_inds);
                            frame_raster_mat = zeros(num_regional_celltype_inds, num_bins_raster);
                            frame_z_scored_spiking_mat = zeros(num_regional_celltype_inds, num_bins_raster);
                            celltype_label = cell(num_regional_celltype_inds, 1);
                            
                            % Looping through each unit of the current cell type
                            for i = 1:numel(regional_celltype_inds)
                                regional_celltype_unit_ind = regional_celltype_inds(i);
                                regional_celltype_unit_spike_ts = unit_spike_ts{regional_celltype_unit_ind};
                                bin_ind_for_each_spike = discretize(regional_celltype_unit_spike_ts, bin_edges_for_raster_in_frame);
                                bins_with_spike_for_raster = bin_ind_for_each_spike(~isnan(bin_ind_for_each_spike));
                                frame_raster_mat(i, bins_with_spike_for_raster) = 1;
                                bin_ind_for_spike_rate_calc = discretize(regional_celltype_unit_spike_ts, bin_edges_for_spiking_rate_in_frame);
                                bins_with_spike_for_spiking = bin_ind_for_spike_rate_calc(~isnan(bin_ind_for_spike_rate_calc));
                                spiking_in_and_around_frame = zeros(1, num_bins_spiking);
                                spiking_in_and_around_frame(bins_with_spike_for_spiking) = 1;
                                spiking_rate_in_frame = conv(spiking_in_and_around_frame, kernel, 'valid');
                                mean_std_activity_ind = find(unit_inds_for_region == regional_celltype_unit_ind);
                                if std_activity(mean_std_activity_ind) ~= 0
                                    frame_z_scored_spiking = sg_disp.util.zscore_spiking_in_frame(...
                                        spiking_rate_in_frame, mean_activity(mean_std_activity_ind), std_activity(mean_std_activity_ind));
                                else
                                    frame_z_scored_spiking = zeros(1, num_bins_raster);
                                end
                                frame_z_scored_spiking_mat(i, :) = frame_z_scored_spiking;
                                celltype_label{i} = celltype;
                            end
                            raster_mat = [raster_mat; frame_raster_mat];
                            z_scored_spiking_mat = [z_scored_spiking_mat; frame_z_scored_spiking_mat];
                            table_celltype_labels = [table_celltype_labels; celltype_label];
                        end
                    end
                    % Creating new rows for the region's table
                    new_row_data = {raster_mat, z_scored_spiking_mat, table_celltype_labels, region, current_time, disp_time_win};
                    eval(['spikes_' region '(row_ind, :) = new_row_data;']);
                    
                    % Progress display
                    if mod(row_ind, num_frames_for_progress_disp) == 0
                        disp(['    Position file:', num2str(params.current_pos_file_number), '/', ...
                            num2str(params.total_pos_file_number), ' | ', ...
                            region, ' Frame:', num2str(row_ind), '/', num2str(num_rows)]);
                    end
                end
                eval(['spikes_' region ' = cell2table(spikes_' region ');']);
                eval(['spikes_' region '.Properties.VariableNames = column_names;']);
            end
        end
    end
end

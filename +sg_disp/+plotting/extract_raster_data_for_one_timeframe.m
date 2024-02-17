function [raster_mat, z_scored_spiking_mat, raster_celltype_labels] = ...
    extract_raster_data_for_one_timeframe(spike_data, params, current_time, region)
    % Function to generate raster plot data and z-scored spiking data for
    % specified cell types in a given region

    % Extract data from inputs
    all_unit_spike_ts       = spike_data.all_unit_spike_ts;
    spike_labels            = spike_data.spike_labels;
    unit_inds_for_session   = spike_data.unit_inds_for_session;
    mean_activity           = spike_data.mean_activity;
    std_activity            = spike_data.std_activity;
    
    kernel_size             = params.kernel_size;
    disp_time_win           = params.disp_time_win;
    raster_bin_width        = params.raster_bin_width;
    celltypes               = params.celltypes_of_interest;

    % Calculate frame start time and bin edges
    frame_start_time = current_time - disp_time_win;
    bin_edges_for_raster_in_frame = frame_start_time:raster_bin_width:current_time;
    num_bins_raster = numel( bin_edges_for_raster_in_frame ) - 1;
    bin_edges_for_spiking_rate_in_frame = sg_disp.util.get_extended_bin_edges_for_spiking_in_frame(...
        frame_start_time, current_time, raster_bin_width, kernel_size);
    num_bins_spiking = numel( bin_edges_for_spiking_rate_in_frame ) - 1;
    kernel = sg_disp.util.get_moving_window_kernel( kernel_size );
    
    % Initialize variables
    raster_mat = [];
    z_scored_spiking_mat = [];
    raster_celltype_labels = {};
    
    unit_inds_for_region = find(spike_labels, region, unit_inds_for_session);
    if ~isempty( unit_inds_for_region )
        % Iterate over cell types
        for celltype_id = 1:numel(celltypes)
            celltype = celltypes{celltype_id};
            
            % Find indices of units corresponding to the specified cell type
            regional_celltype_inds = find(spike_labels, {celltype, region}, unit_inds_for_session);
            
            % Process units of the current cell type
            if ~isempty(regional_celltype_inds)
                num_regional_celltype_inds = numel(regional_celltype_inds);
                
                % Initialize matrices for current cell type
                frame_raster_mat = zeros(num_regional_celltype_inds, num_bins_raster);
                frame_z_scored_spiking_mat = zeros(num_regional_celltype_inds, num_bins_raster);
                celltype_label = cell(num_regional_celltype_inds, 1);
                
                % Iterate over units of the current cell type
                for i = 1:numel(regional_celltype_inds)
                    regional_celltype_unit_ind = regional_celltype_inds(i);
                    regional_celltype_unit_spike_ts = all_unit_spike_ts{regional_celltype_unit_ind};
                    
                    % Calculate bin indices for raster plot and spiking rate
                    bin_ind_for_each_spike = discretize(regional_celltype_unit_spike_ts, bin_edges_for_raster_in_frame);
                    bins_with_spike_for_raster = bin_ind_for_each_spike(~isnan(bin_ind_for_each_spike));
                    frame_raster_mat(i, bins_with_spike_for_raster) = 1;
                    
                    bin_ind_for_spike_rate_calc = discretize(regional_celltype_unit_spike_ts, bin_edges_for_spiking_rate_in_frame);
                    bins_with_spike_for_spiking = bin_ind_for_spike_rate_calc(~isnan(bin_ind_for_spike_rate_calc));
                    spiking_in_and_around_frame = zeros(1, num_bins_spiking);
                    spiking_in_and_around_frame(bins_with_spike_for_spiking) = 1;
                    
                    % Calculate z-scored spiking activity
                    spiking_rate_in_frame = conv(spiking_in_and_around_frame, kernel, 'valid');
                    if std_activity(regional_celltype_unit_ind) ~= 0
                        frame_z_scored_spiking = sg_disp.util.zscore_spiking_in_frame(...
                            spiking_rate_in_frame, mean_activity(regional_celltype_unit_ind), std_activity(regional_celltype_unit_ind));
                    else
                        frame_z_scored_spiking = zeros(1, num_bins_raster);
                    end
                    frame_z_scored_spiking_mat(i, :) = frame_z_scored_spiking;
                    
                    % Store cell type label
                    celltype_label{i} = celltype;
                end
                
                % Append data for current cell type to the overall matrices
                raster_mat = [raster_mat; frame_raster_mat];
                z_scored_spiking_mat = [z_scored_spiking_mat; frame_z_scored_spiking_mat];
                raster_celltype_labels = [raster_celltype_labels; celltype_label];
            end
        end
    end
end

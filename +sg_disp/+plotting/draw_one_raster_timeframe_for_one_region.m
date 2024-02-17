function draw_one_raster_timeframe_for_one_region(ax, spike_data, behav_data, params, current_time, region)

relevant_axis           = ax.(region);

all_unit_spike_ts       = spike_data.all_unit_spike_ts;
spike_labels            = spike_data.spike_labels;
unit_inds_for_session   = spike_data.unit_inds_for_session;
mean_activity           = spike_data.mean_activity;
std_activity            = spike_data.std_activity;
max_activity            = spike_data.max_activity;
min_activity            = spike_data.min_activity;

time_vec                = behav_data.time_vec;
start_time_ind          = behav_data.start_time_ind;
end_time_ind            = behav_data.end_time_ind;

disp_time_win           = params.disp_time_win;
raster_bin_width        = params.raster_bin_width;
celltypes               = params.celltypes_of_interest;

frame_start_time = current_time - disp_time_win;
bin_edges_for_raster_in_frame = frame_start_time:raster_bin_width:current_time;
bin_edges_for_spiking_rate_in_frame = sg_disp.util.get_extended_bin_edges_for_spiking_in_frame(...
    frame_start_time, current_time, raster_bin_width, kernel_size);
num_bins_raster = numel(bin_edges_for_raster_in_frame) - 1;
num_bins_spiking = numel(bin_edges_for_spiking_rate_in_frame) - 1;
    
for celltype_id = 1:numel(celltypes)
    celltype = celltypes{celltype_id};
    regional_celltype_inds = find(spike_labels, {celltype, region}, unit_inds_for_session);
    if ~isempty(regional_celltype_inds)
        num_regional_celltype_inds = numel(regional_celltype_inds);
        frame_raster_mat = zeros(num_regional_celltype_inds, num_bins_raster);
        frame_z_scored_spiking_mat = zeros(num_regional_celltype_inds, num_bins_raster);
        celltype_label = cell(num_regional_celltype_inds, 1);
        for i = 1:numel(regional_celltype_inds)
            regional_celltype_unit_ind = regional_celltype_inds(i);
            regional_celltype_unit_spike_ts = all_unit_spike_ts{regional_celltype_unit_ind};
            bin_ind_for_each_spike = discretize(regional_celltype_unit_spike_ts, bin_edges_for_raster_in_frame);
            bins_with_spike_for_raster = bin_ind_for_each_spike(~isnan(bin_ind_for_each_spike));
            frame_raster_mat(i, bins_with_spike_for_raster) = 1;
            bin_ind_for_spike_rate_calc = discretize(regional_celltype_unit_spike_ts, bin_edges_for_spiking_rate_in_frame);
            bins_with_spike_for_spiking = bin_ind_for_spike_rate_calc(~isnan(bin_ind_for_spike_rate_calc));
            spiking_in_and_around_frame = zeros(1, num_bins_spiking);
            spiking_in_and_around_frame(bins_with_spike_for_spiking) = 1;
            spiking_rate_in_frame = conv(spiking_in_and_around_frame, kernel, 'valid');
            mean_std_activity_ind = find(unit_inds_for_session == regional_celltype_unit_ind);
            if std_activity(mean_std_activity_ind) ~= 0
                frame_z_scored_spiking = sg_disp.util.zscore_spiking_in_frame(...
                    spiking_rate_in_frame, mean_activity(mean_std_activity_ind), std_activity(mean_std_activity_ind));
            else
                frame_z_scored_spiking = zeros(1, num_bins_raster);
            end
            frame_z_scored_spiking_mat(i, :) = frame_z_scored_spiking;
            celltype_label{i} = celltype;
        end
        % plot frame_z_scored_spiking_mat using imagesc. min and max will
        % be needed for color code
        
        % plot frame_raster_mat on top of it
    end
end


end
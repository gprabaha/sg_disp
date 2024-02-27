function draw_one_raster_timeframe_for_one_region( ...
    ax, spike_data, params, current_time, region)

relevant_axis           = ax.(region);

max_activity_z          = spike_data.max_activity_z;
min_activity_z          = spike_data.min_activity_z;

z_score_stdev_bound     = params.z_score_stdev_bound;
custom_colormap         = params.custom_colormap;

[raster_mat, z_scored_spiking_mat, raster_celltype_labels] = ...
    sg_disp.plotting.extract_raster_data_for_one_timeframe(...
    spike_data, params, current_time, region);

if isempty( raster_mat )
    text( relevant_axis, 0.5, 0.5, ...
            sprintf('No units in %s for this session', region), ...
            'Color', 'red', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);
    title( relevant_axis, ['No units in ' region] );
else
    num_neurons = size( raster_mat, 1 );
    hold( relevant_axis, 'on' );
    % Raster background
    colorbar_positive_bound = z_score_stdev_bound;
    imagesc( relevant_axis, z_scored_spiking_mat, [-colorbar_positive_bound colorbar_positive_bound] );
    [n_rows, n_cols] = size( z_scored_spiking_mat );
    xlim( relevant_axis, [-0.5, n_cols + 0.5] );
    ylim( relevant_axis, [0.5, n_rows + 0.5] );
    yticks( relevant_axis, 1:n_rows );
    yticklabels( relevant_axis, raster_celltype_labels );
    colormap( relevant_axis, custom_colormap );
    % colorbar( relevant_axis );
    % Raster
    for neuron = 1:num_neurons
        firing_times = find(raster_mat(neuron, :) == 1);
        unit_celltype = raster_celltype_labels{neuron};
        raster_tick_color = sg_disp.util.get_spike_tick_colors_for_celltype( unit_celltype );
        plot( relevant_axis, firing_times, repmat(neuron, size(firing_times)), ...
            '|', ...
            'MarkerSize', 13, ...
            'Color', raster_tick_color, ...
            'LineWidth', 3);
    end
    title_string = sprintf( 'Raster plot of spikes in %s overlayed on Z-scored [%0.1f to %0.1f] spiking rate', ...
        upper(region), -colorbar_positive_bound, colorbar_positive_bound );
    xlabel( relevant_axis, 'Time (ms)' );
    x_tick_nums = -500:50:0;
    x_tick_nums = num2str( x_tick_nums' );
    xticklabels( relevant_axis, x_tick_nums );
    title( relevant_axis, title_string );
    hold( relevant_axis, 'off' );
end

end
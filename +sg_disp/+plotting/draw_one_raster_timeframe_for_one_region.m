function draw_one_raster_timeframe_for_one_region( ...
    ax, spike_data, params, current_time, region)

relevant_axis           = ax.(region);

max_activity_z          = spike_data.max_activity_z;
min_activity_z          = spike_data.min_activity_z;

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
    bound = max( abs(max_activity_z), abs(min_activity_z) )/3;
    num_colors = 501; 
    low_color = [1, 0, 0]; % Red
    high_color = [0, 1, 0]; % Green
    custom_colormap = create_custom_colormap( num_colors, low_color, high_color ); % Generate the custom colormap
    imagesc( relevant_axis, z_scored_spiking_mat, [-bound bound] );
    [row, col] = size( z_scored_spiking_mat );
    xlim( relevant_axis, [-0.5, col + 0.5] );
    ylim( relevant_axis, [0.5, row + 0.5] );
    colormap( relevant_axis, custom_colormap );
    yticklabels( relevant_axis, raster_celltype_labels );
    colorbar( relevant_axis );
    % Raster
    for neuron = 1:num_neurons
        firing_times = find(raster_mat(neuron, :) == 1);
        plot( relevant_axis, firing_times, repmat(neuron, size(firing_times)), '|k', 'LineWidth', 2);
    end
    title_string = sprintf( 'Raster plot for units in %s overlayed on Z-scored spikng rate', region );
    xlabel( relevant_axis, 'Time (ms)' );
    x_tick_nums = -500:50:0;
    x_tick_nums = num2str( x_tick_nums' );
    xticklabels( relevant_axis, x_tick_nums );
    title( relevant_axis, title_string );
    hold( relevant_axis, 'off' );
end

end

function custom_colormap = create_custom_colormap(num_color_bins, low_color, high_color)
    % Check if the number of color bins is odd
    if mod(num_color_bins, 2) == 0
        error('Number of color bins must be odd.');
    end
    
    % Check if low_color and high_color are valid RGB values
    if any(low_color < 0) || any(low_color > 1) || any(high_color < 0) || any(high_color > 1)
        error('Low_color and high_color must be RGB values in the range [0, 1].');
    end
    
    % Initialize colormap
    custom_colormap = zeros(num_color_bins, 3);
    
    % Calculate mid index
    mid_index = (num_color_bins + 1) / 2;
    
    % Generate colormap from low_color to white to high_color
    custom_colormap(1:mid_index, 1) = linspace(low_color(1), 1, mid_index); % Red component
    custom_colormap(1:mid_index, 2) = linspace(low_color(2), 1, mid_index); % Green component
    custom_colormap(1:mid_index, 3) = linspace(low_color(3), 1, mid_index); % Blue component
    
    custom_colormap(mid_index:end, 1) = linspace(1, high_color(1), num_color_bins - mid_index + 1); % Red component
    custom_colormap(mid_index:end, 2) = linspace(1, high_color(2), num_color_bins - mid_index + 1); % Green component
    custom_colormap(mid_index:end, 3) = linspace(1, high_color(3), num_color_bins - mid_index + 1); % Blue component
end

function bin_edges_for_spiking = get_extended_bin_edges_for_spiking_in_frame( ...
    frame_start_time, current_time, raster_bin_width, kernel_size)

    % Calculate the number of bins on each side
    num_bins_each_side = floor(kernel_size/2);
    
    % Calculate the starting and ending times for the bins
    start_time = frame_start_time - raster_bin_width*num_bins_each_side;
    end_time = current_time + raster_bin_width*num_bins_each_side;
    
    % Generate bin edges using the specified raster bin width
    bin_edges_for_spiking = start_time:raster_bin_width:end_time;
end

function [display_x_range, display_y_range] = calculate_display_ranges(behav_data, params)
    
    monitor_size = params.monitor_size;
    screen_prop_to_display = params.screen_prop_to_display;
    offsets = behav_data.offsets;
    
    % Extract monitor dimensions
    screen_x = monitor_size(1);
    screen_y = monitor_size(2);

    % Define origin_x
    origin_x = -1024;
    if offsets.m1(1) == 0
        origin_x = origin_x + 1024;
    end

    % Calculate display_x_range
    display_x_range = [origin_x, origin_x + screen_x * 3];
    x_array = display_x_range(1):display_x_range(2);
    x_array = sg_disp.util.extract_middle_chunk_of_array(x_array, screen_prop_to_display);
    display_x_range = x_array([1, end]);

    % Calculate display_y_range
    display_y_range = [1, screen_y];
end

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
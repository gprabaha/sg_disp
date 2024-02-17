function cmap = get_fixation_colormap(disp_time_inds)
    % Define endpoint color
    color_end = [230, 25, 75] ./ 255; % Red color
    % Generate colormap based on the length of disp_time_inds
    n = length(disp_time_inds);
    cmap = [linspace(1, color_end(1), n)', linspace(1, color_end(2), n)', linspace(1, color_end(3), n)'];
end
function cmap = get_colormap_for_monkey(disp_time_inds, monkey)
    % Validate input monkey
    if ~(strcmp(monkey, 'm1') || strcmp(monkey, 'm2'))
        error('monkey must be either ''m1'' or ''m2''.');
    end
    % Define endpoint color based on monkey
    if strcmp(monkey, 'm1')
        color_end = [0, 0, 128] ./ 255; % Navy color
    else
        color_end = [128, 128, 0] ./ 255; % Olive color
    end
    % Generate colormap based on the length of disp_time_inds
    n = length(disp_time_inds);
    cmap = [linspace(1, color_end(1), n)', linspace(1, color_end(2), n)', linspace(1, color_end(3), n)'];
end
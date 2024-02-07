function [fig, ax] = make_viewer_fig_and_axes(params)

border_fraction = params.border_fraction;
font_size = params.font_size;
m1_axes = params.m1_axes;
m2_axes = params.m2_axes;

% Get the figure position for the primary screen with borders
fig_position = [border_fraction border_fraction...
    1-(2*border_fraction) 1-(2*border_fraction)];
% Create a figure on the primary screen with borders
fig = figure('Units', 'normalized', 'Position', fig_position);
% Set default font size for all text within the figure
set(fig, 'DefaultTextFontSize', font_size);
ax = struct();
ax.m1 = axes('Position', m1_axes); % x1 y1 width height
ax.m2 = axes('Position', m2_axes);

end
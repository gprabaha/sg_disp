function [fig, ax] = make_viewer_fig_and_axes(params)

border_fraction = params.border_fraction;
font_size = params.font_size;
m1_axis = params.m1_axis;
m2_axis = params.m2_axis;
legend_axis = params.legend_axis;
acc_axis = params.acc_axis;
bla_axis = params.bla_axis;

% Get the figure position for the primary screen with borders
fig_position = [border_fraction border_fraction...
    1-(2*border_fraction) 1-(2*border_fraction)];
% Create a figure on the primary screen with borders
fig = figure('Units', 'normalized', 'Position', fig_position);
% Set default font size for all text within the figure
set(fig, 'DefaultTextFontSize', font_size);
ax = struct();
ax.m1 = axes('Position', m1_axis); % x1 y1 width height

ax.m1 = prune_axis( ax.m1 );
ax.m2 = axes('Position', m2_axis);
ax.m2 = prune_axis( ax.m2 );
ax.legend = axes('Position', legend_axis);
ax.legend.Visible = 'off';
ax.acc = axes('Position', acc_axis);
ax.bla = axes('Position', bla_axis);

end

function ax_new = prune_axis( ax )
ax_new = ax;
ax_new.XAxis.Visible = 'off';
ax_new.YAxis.Visible = 'off';
end
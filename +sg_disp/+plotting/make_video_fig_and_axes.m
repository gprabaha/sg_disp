function [fig, ax] = make_video_fig_and_axes(params)

fig_position = params.fig_position;
font_size = params.font_size;
m1_axis = params.m1_axis;
m2_axis = params.m2_axis;
legend_axis = params.legend_axis;
acc_axis = params.acc_axis;
bla_axis = params.bla_axis;

% Create a figure of size specified by params
fig = figure( 'Position', fig_position );
% fig = figure('Position', fig_position, 'Visible', 'off');
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
function draw_one_timeframe_for_one_monkey( monkey, ax, disp_time_inds, behav_data, params )

relevant_axis = ax.(monkey);

pos_vec = behav_data.pos_vecs.(monkey);
time_vec = behav_data.time_vec;
offsets = behav_data.offsets;
roi_rects = behav_data.roi_rects;

monitor_size = params.monitor_size;
flanking_screen_prop = params.flanking_screen_prop;

screen_x = monitor_size(1);
screen_y = monitor_size(2);
display_x_range = [1 - screen_x*flanking_screen_prop,  screen_x + screen_x*flanking_screen_prop];
display_y_range = [1, screen_y];

offset = offsets.(monkey);
x_vec = pos_vec(1, disp_time_inds)';
x_vec = x_vec - offset(1);
y_vec = pos_vec(2, disp_time_inds)';
y_vec = y_vec - offset(2);

monkey_rois = roi_rects.(monkey);
roi_names = monkey_rois.roi;
roi_boxes = monkey_rois.roi_rect;
offset_adjusted_roi_boxes = adjust_rect_offset(roi_boxes, offset);

white_to_black_cmap = linspace(1, 0, length(x_vec))';
cmap = [white_to_black_cmap, white_to_black_cmap, white_to_black_cmap]; % RGB values

% Plot scatter points with specified color and size
cla(relevant_axis);
hold on;
for i=1:numel(roi_names)
    rect_corners = offset_adjusted_roi_boxes{i};
    rect_for_plotting = [rect_corners(1), rect_corners(2),...
        rect_corners(3)-rect_corners(1), rect_corners(4)-rect_corners(2)];
    rectangle(relevant_axis, 'Position', rect_for_plotting);
end
legend(relevant_axis, roi_names, 'Location', 'best');
scatter(relevant_axis, x_vec, y_vec, 50, cmap, 'filled');
hold off;

time_range = time_vec(disp_time_inds);
colormap(relevant_axis, cmap);
start_time = min(time_range, [], 'omitnan');
end_time = max(time_range, [], 'omitnan');
clim( relevant_axis, [start_time, end_time] ); % Set colorbar limits
colorbar( relevant_axis );
title( relevant_axis, sprintf('%s Gaze Location from t=%0.3fs to %0.3fs', ...
    monkey, start_time, end_time ) );
xlim( relevant_axis, display_x_range);
ylim( relevant_axis, display_y_range);

end

function rects = adjust_rect_offset(roi_boxes, offset)

rects = {};
for i = 1:numel(roi_boxes)
    new_rect = roi_boxes{i};
    new_rect = [new_rect(1)-offset(1), new_rect(2)-offset(2), new_rect(3)-offset(1), new_rect(4)-offset(2)];
    rects = [rects; new_rect];
end


end
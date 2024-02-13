function roi_color_table = draw_one_timeframe_for_one_monkey(...
    ax, behav_data, params, disp_time_inds, monkey)

relevant_axis = ax.(monkey);

pos_vec = behav_data.pos_vecs.(monkey);
time_vec = behav_data.time_vec;
offsets = behav_data.offsets;
fix_vec = behav_data.fix_vecs.(monkey);
roi_rects = behav_data.roi_rects;

monitor_size = params.monitor_size;
screen_prop_to_display = params.screen_prop_to_display;
disp_time_win = params.disp_time_win;

screen_x = monitor_size(1);
screen_y = monitor_size(2);

origin_x = -1024;
if ( offsets.m1(1) == 0 )
    origin_x = origin_x + 1024;
end
display_x_range = [origin_x, origin_x + screen_x * 3];
x_array = display_x_range(1):display_x_range(2);
x_array = extract_middle_chunk_of_array(x_array, screen_prop_to_display);
display_x_range = x_array([1, end]);
display_y_range = [1, screen_y];


x_vec = pos_vec(1, disp_time_inds)';
y_vec = pos_vec(2, disp_time_inds)';

monkey_rois = roi_rects.(monkey);
roi_names = monkey_rois.roi;
roi_boxes = monkey_rois.roi_rect;
offset_adjusted_roi_boxes = roi_boxes;

cmap = get_colormap_for_monkey(disp_time_inds, monkey);
cmap_fix = get_fixation_colormap(disp_time_inds);

fix_in_disp = fix_vec(disp_time_inds);

% Plot scatter points with specified colormaps
hold( relevant_axis, 'on' );
% Draw the roi boinding boxes
roi_color_table = draw_roi_bounding_boxes( relevant_axis, roi_names, offset_adjusted_roi_boxes, monkey );
% Plotting last n gaze locations
scatter( relevant_axis, x_vec, y_vec, 50, cmap, 'filled' );
% Plotting fixations
x_fix = x_vec(fix_in_disp);
y_fix = y_vec(fix_in_disp);
cmap_fix = cmap_fix(fix_in_disp, :);
scatter( relevant_axis, x_fix, y_fix, 50, cmap_fix, 'filled' );

time_range = time_vec(disp_time_inds);
colormap( relevant_axis, cmap );
% start_time = min(time_range, [], 'omitnan');
% end_time = time_range(end);
% clim( relevant_axis, [start_time, end_time] ); % Set colorbar limits
% colorbar takes a long time to draw
% colorbar( relevant_axis );
title( relevant_axis, sprintf('Last %0.1fs gaze location of %s at t=%0.3fs', ...
    disp_time_win, monkey, end_time ) );
xlim( relevant_axis, display_x_range);
ylim( relevant_axis, display_y_range);
hold( relevant_axis, 'off' );
set( relevant_axis, 'YDir', 'reverse' );
% drawnow;

end


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


function cmap = get_fixation_colormap(disp_time_inds)
    % Define endpoint color
    color_end = [230, 25, 75] ./ 255; % Red color
    % Generate colormap based on the length of disp_time_inds
    n = length(disp_time_inds);
    cmap = [linspace(1, color_end(1), n)', linspace(1, color_end(2), n)', linspace(1, color_end(3), n)'];
end


function roi_color_table = draw_roi_bounding_boxes(relevant_axis, roi_names, offset_adjusted_roi_boxes, monkey)
    % Validate input monkey
    if ~(strcmp(monkey, 'm1') || strcmp(monkey, 'm2'))
        error('monkey must be either ''m1'' or ''m2''.');
    end
    % Initialize ROI color table
    roi_color_table = table(roi_names, 'VariableNames', {'ROI_Name'});
    % Generate colormap based on the full list of ROI names
    colors = lines(numel(roi_names));
    % Filter out ROI names containing 'nonsocial' if monkey is 'm2'
    if strcmp(monkey, 'm2')
        nonsocial_indices = contains(roi_names, 'nonsocial');
        roi_names(nonsocial_indices) = [];
        offset_adjusted_roi_boxes(nonsocial_indices) = [];
        roi_color_table(nonsocial_indices,:) = [];
        % Update colors for remaining ROIs
        colors = colors(~nonsocial_indices, :);
    end
    % Draw the ROI bounding boxes with different colors
    r = gobjects(0);
    for i = 1:numel(roi_names)
        rect_corners = offset_adjusted_roi_boxes{i};
        rect_for_plotting = [rect_corners(1), rect_corners(2), ...
            rect_corners(3)-rect_corners(1), rect_corners(4)-rect_corners(2)];
        % Draw rectangle with thicker lines and different color for each ROI
        r(i) = rectangle(relevant_axis, 'Position', rect_for_plotting, ...
            'EdgeColor', colors(i,:), 'LineWidth', 2);
        % Add ROI name and corresponding color to ROI color table
        roi_color_table.Color(i,1) = {colors(i,:)};
    end
end

function middle_chunk = extract_middle_chunk_of_array(array, f)
    % Calculate number of elements to skip at the beginning and end
    num_elements = length(array);
    num_skip = round((1 - f) * num_elements / 2);
    
    % Extract middle fraction of the array
    middle_chunk = array(num_skip+1:end-num_skip);
end

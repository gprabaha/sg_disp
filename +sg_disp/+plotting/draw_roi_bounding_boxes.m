function roi_color_table = draw_roi_bounding_boxes(relevant_axis, roi_names, roi_boxes, monkey)
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
        roi_boxes(nonsocial_indices) = [];
        roi_color_table(nonsocial_indices,:) = [];
        % Update colors for remaining ROIs
        colors = colors(~nonsocial_indices, :);
    end
    % Draw the ROI bounding boxes with different colors
    r = gobjects(0);
    for i = 1:numel(roi_names)
        rect_corners = roi_boxes{i};
        rect_for_plotting = [rect_corners(1), rect_corners(2), ...
            rect_corners(3)-rect_corners(1), rect_corners(4)-rect_corners(2)];
        % Draw rectangle with thicker lines and different color for each ROI
        r(i) = rectangle(relevant_axis, 'Position', rect_for_plotting, ...
            'EdgeColor', colors(i,:), 'LineWidth', 2);
        % Add ROI name and corresponding color to ROI color table
        roi_color_table.Color(i,1) = {colors(i,:)};
    end
end
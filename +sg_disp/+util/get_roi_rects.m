function roi_rects = get_roi_rects( roi_struct, rois_of_interest )

% List of fieldnames
monkeys = fieldnames( roi_struct );
% Create the struct
roi_rects = struct();
for i = 1:numel(monkeys)
    rect_map = roi_struct.(monkeys{i}).rects;
    % Initialize variables to store ROI names and rectangle coordinates
    roi_names = {};
    rect_coords = {};   
    % Iterate over ROIs
    for j = 1:numel(rois_of_interest)
        roi_name = rois_of_interest{j};  % Get ROI name      
        % Check if the ROI exists in the rect_map
        if isKey(rect_map, roi_name)
            roi_names = [roi_names; roi_name];  % Store ROI name
            rect_coord = rect_map(roi_name);  % Get rectangle coordinates
            rect_coords = [rect_coords; rect_coord];  % Store rectangle coordinates
        else
            disp(['ROI "', roi_name, '" not found in rect_map.']);  % Display a message if ROI is not found
        end
    end
    table_roi_rect = table(roi_names, rect_coords, 'VariableNames', {'roi', 'roi_rect'});
    roi_rects.(monkeys{i}) = table_roi_rect;
end

end
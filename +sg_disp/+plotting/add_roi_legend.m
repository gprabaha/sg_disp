function add_roi_legend(ax, roi_color_table)
    fontsize = 14;
    legend_letter_width = 0.01;

    % Get the legend axis from ax.legend
    legend_axis = ax.legend;

    % Get ROI names and colors from roi_color_table
    roi_name = roi_color_table.ROI_Name;
    colors = roi_color_table.Color;
    entry_gap = 0.05; % Gap between legend entries

    % Calculate width of each legend entry and total width
    legend_widths = zeros(1, length(roi_name));
    total_width = 0;
    for i = 1:length(roi_name)
        % Replace underscores with spaces in ROI names
        legend_text = strrep(roi_name{i}, '_', ' ');
        
        % Construct legend entry with color
        legend_entry = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
            colors{i}(1), colors{i}(2), colors{i}(3), legend_text);
        
        % Create temporary text object to calculate width
        temp_text = text(0, 0, legend_entry, 'Visible', 'off', ...
            'FontSize', fontsize, 'Parent', legend_axis);
        legend_widths(i) = numel(legend_text)*legend_letter_width;
        total_width = total_width + legend_widths(i);
        delete(temp_text); % Remove temporary text object
    end

    % Calculate offset for the first entry (initially 0)
    first_entry_offset = 0.05;

    % Display text in the legend with corresponding colors
    for i = 1:length(roi_name)
        % Replace underscores with spaces in ROI names
        legend_text = strrep(roi_name{i}, '_', ' ');
        
        % Construct legend entry with color
        legend_entry = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
            colors{i}(1), colors{i}(2), colors{i}(3), legend_text);
        
        % Add text to the legend axis with appropriate offset
        text(first_entry_offset, 0, legend_entry, 'Color', colors{i}, ...
            'Units', 'normalized', 'Parent', legend_axis, ...
            'FontSize', fontsize, 'BackgroundColor', 'w');
        
        % Update offset for next entry
        first_entry_offset = first_entry_offset + legend_widths(i) + entry_gap;
    end
end

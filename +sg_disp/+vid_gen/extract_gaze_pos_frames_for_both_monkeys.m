function [gaze_m1, gaze_m2] = extract_gaze_pos_frames_for_both_monkeys(behav_data, params)
    % behav_data: A struct containing behavioral data
    % params: A struct containing parameters

    % Extract data from behav_data
    start_time_ind = behav_data.start_time_ind;
    end_time_ind = behav_data.end_time_ind;
    time_vec = behav_data.time_vec;
    pos_vecs = behav_data.pos_vecs;
    fix_vecs = behav_data.fix_vecs;
    roi_rects = behav_data.roi_rects;

    % Extract parameters from params
    disp_time_win = params.disp_time_win;
    monkeys = params.monkeys;
    num_frames_for_progress_disp = params.num_frames_for_progress_disp;

    % Initialize variables
    ind_vec = start_time_ind:end_time_ind;
    num_rows = numel(ind_vec);
    column_names = {'XVec', 'YVec', 'XFix', 'YFix', 'RoiNames', ...
                    'RoiBdBoxes', 'DispXRange', 'DispYRange', 'Monkey', ...
                    'CurrentTime', 'DispTimeWin'};
    gaze_m1 = cell( num_rows, numel(column_names) );
    gaze_m2 = cell( num_rows, numel(column_names) );
    
    % Calculate display ranges
    [display_x_range, display_y_range] = sg_disp.util.calculate_display_ranges(behav_data, params);

    % Loop through monkeys
    for monkey_ind = 1:numel(monkeys)
        monkey = monkeys{monkey_ind};
        pos_vec = pos_vecs.(monkey);
        fix_vec = fix_vecs.(monkey);
        rois = roi_rects.(monkey);
        roi_names = rois.roi;
        roi_bd_boxes = rois.roi_rect;

        % Loop through rows
        for row_ind = 1:num_rows
            current_time_ind = ind_vec(row_ind);
            current_time = time_vec(current_time_ind);
            disp_time_inds = sg_disp.util.calculate_disp_time_inds(current_time_ind, disp_time_win);
            x_vec = pos_vec(1, disp_time_inds)';
            y_vec = pos_vec(2, disp_time_inds)';
            fix_in_disp_vec = fix_vec(disp_time_inds);
            x_fix = x_vec(fix_in_disp_vec);
            y_fix = y_vec(fix_in_disp_vec);
            new_row_data = {x_vec, y_vec, x_fix, y_fix, roi_names, ...
                            roi_bd_boxes, display_x_range, display_y_range, monkey, ...
                            current_time, disp_time_win};
            eval(['gaze_' monkey '(row_ind, :) = new_row_data;']);
            
            % Progress display
            if mod(row_ind, num_frames_for_progress_disp) == 0
                disp(['    Position file:', num2str(params.current_pos_file_number), '/', ...
                      num2str(params.total_pos_file_number), ' | ', ...
                      monkey, ' Frame:', num2str(row_ind), '/', num2str(num_rows)]);
            end
        end
        eval(['gaze_' monkey ' = cell2table(gaze_' monkey ');']);
        eval(['gaze_' monkey '.Properties.VariableNames = column_names;']);
    end
end

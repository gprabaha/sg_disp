function extract_and_save_video_data_for_each_run(behav_data, spike_data, params)

time_vec = behav_data.time_vec;
pos_vecs = behav_data.pos_vecs;
fix_vecs = behav_data.fix_vecs;
roi_rects = behav_data.roi_rects;
offsets = behav_data.offsets;
start_time_ind = behav_data.start_time_ind;
end_time_ind = behav_data.end_time_ind;

unit_spike_ts = spike_data.unit_spike_ts;
spike_labels = spike_data.spike_labels;

validity_filter = params.validity_filter;
excluded_categories = params.excluded_categories;
rois_of_interest = params.rois_of_interest;
time_ind_update_method = params.time_ind_update_method;
monkeys = params.monkeys;
celltypes = params.celltypes;
regions = params.regions;
disp_time_win = params.disp_time_win;

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
x_array = sg_disp.util.extract_middle_chunk_of_array(x_array, screen_prop_to_display);
display_x_range = x_array([1, end]);
display_y_range = [1, screen_y];

ind_vec = start_time_ind:end_time_ind;
num_rows = numel(ind_vec);
column_names = {'XVec', 'YVec', 'XFix', 'YFix', 'RoiNames', ...
            'RoiBdBoxes', 'DispXRange', 'DispYRange', 'Monkey', ...
            'CurrentTime', 'DispTimeWin'};
gaze_m1 = table();
gaze_m2 = table();

for i=1:numel(monkeys)
    monkey = monkeys{i};
    pos_vec = pos_vecs.(monkey);
    fix_vec = fix_vecs.(monkey);
    rois = roi_rects.(monkey);
    roi_names = rois.roi;
    roi_bd_boxes = rois.roi_rect;
    for j=1:num_rows
        current_time_ind = ind_vec(i);
        current_time = time_vec( current_time_ind );
        disp_time_inds = sg_disp.util.calculate_disp_time_inds( ...
            current_time_ind, disp_time_win);
        x_vec = pos_vec(1, disp_time_inds)';
        y_vec = pos_vec(2, disp_time_inds)';
        fix_in_disp_vec = fix_vec(disp_time_inds);
        x_fix = x_vec(fix_in_disp_vec);
        y_fix = y_vec(fix_in_disp_vec);
        new_row_data = { x_vec, y_vec, x_fix, y_fix, roi_names, ...
            roi_bd_boxes, display_x_range, display_y_range, monkey, ...
            current_time, disp_time_win };
        eval(['gaze_' monkey ' = [gaze_' monkey '; new_row_data];']);

        % Disp
        if mod(j, 100) == 0
            disp([monkey, ' : ', num2str(j), '/', num2str(num_rows)]);
        end

    end
    eval(['gaze_' monkey '.Properties.VariableNames = column_names;']);
end

a = 1;

end


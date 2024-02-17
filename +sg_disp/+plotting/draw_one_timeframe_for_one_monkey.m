function roi_color_table = draw_one_timeframe_for_one_monkey(...
    ax, behav_data, params, disp_time_inds, monkey)

relevant_axis           = ax.(monkey);

pos_vec                 = behav_data.pos_vecs.(monkey);
time_vec                = behav_data.time_vec;
fix_vec                 = behav_data.fix_vecs.(monkey);
roi_rects               = behav_data.roi_rects;
end_time_ind            = behav_data.end_time_ind;

disp_time_win           = params.disp_time_win;

monkey_rois = roi_rects.(monkey);
roi_names = monkey_rois.roi;
roi_boxes = monkey_rois.roi_rect;

[display_x_range, display_y_range] = sg_disp.util.calculate_display_ranges(behav_data, params);
cmap = sg_disp.util.get_colormap_for_monkey( disp_time_inds, monkey );
cmap_fix = sg_disp.util.get_fixation_colormap( disp_time_inds );
x_vec = pos_vec(1, disp_time_inds)';
y_vec = pos_vec(2, disp_time_inds)';
fix_in_disp = fix_vec(disp_time_inds);
x_fix = x_vec(fix_in_disp);
y_fix = y_vec(fix_in_disp);
cmap_fix = cmap_fix(fix_in_disp, :);

hold( relevant_axis, 'on' );
roi_color_table = sg_disp.plotting.draw_roi_bounding_boxes( relevant_axis, roi_names, roi_boxes, monkey );
scatter( relevant_axis, x_vec, y_vec, 50, cmap, 'filled' );
scatter( relevant_axis, x_fix, y_fix, 50, cmap_fix, 'filled' );
colormap( relevant_axis, cmap );
title_string = sprintf( 'Last %0.1fs gaze location of %s at t=%0.3fs/%0.3fs', ...
    disp_time_win, monkey, time_vec(disp_time_inds(end)), time_vec(end_time_ind) );
title( relevant_axis, title_string );
xlim( relevant_axis, display_x_range);
ylim( relevant_axis, display_y_range);
hold( relevant_axis, 'off' );
set( relevant_axis, 'YDir', 'reverse' );

end


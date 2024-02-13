function [spikes_acc, spikes_bla] = extract_unit_spiking_frames_for_acc_and_bla( behav_data, spike_data, params )
    
    time_vec = behav_data.time_vec;
    start_time_ind = behav_data.start_time_ind;
    end_time_ind = behav_data.end_time_ind;
    
    unit_spike_ts = spike_data.unit_spike_ts;
    spike_labels = spike_data.spike_labels;
    
    session = params.current_session;
    validity_filter = params.unit_validity_filter;
    regions = params.regions;
    cell_type_labels = params.celltypes;
    raster_bin_width = params.raster_bin_width;
    
    disp_time_win = params.disp_time_win;
    
    % Initialize variables
    time_inds_of_interest = start_time_ind:end_time_ind;
    start_time = time_vec(start_time_ind);
    start_time_for_bins = start_time - disp_time_win;
    end_time = time_vec(end_time_ind);
    fulltime_bin_edges = start_time_for_bins:raster_bin_width:end_time;
    n_fulltime_bins = numel(fulltime_bin_edges) - 1;
    num_rows = numel(time_inds_of_interest);
    column_names = {'XVec', 'YVec', 'XFix', 'YFix', 'RoiNames', ...
                    'RoiBdBoxes', 'DispXRange', 'DispYRange', 'Monkey', ...
                    'CurrentTime', 'DispTimeWin'};

    spikes_acc = table();
    spikes_bla = table();
    spike_abs_error_acc = [];
    spike_abs_error_bla = [];

    valid_unit_inds_for_session = find( spike_labels, [{session}, validity_filter(:)'] );
    if isempty(valid_unit_inds_for_session)
        spike_abs_error_acc = 'There are no valid units for this session';
        spike_abs_error_bla = 'There are no valid units for this session';
    else
        for region_ind = 1:numel(regions)
            region = regions{region_ind};
            valid_unit_inds_for_region = find( spike_labels, region, valid_unit_inds_for_session );
            if isempty(valid_unit_inds_for_region)
                non_region_label = prune( spike_labels( valid_unit_inds_for_session ) );
                region_for_units = retaineach( non_region_label, 'region' );
                region_for_units = region_for_units('region');
                if strcmp(region, 'acc')
                    spike_abs_error_acc = ['No valid units for ' region ', ' ...
                        'but units present in ' strjoin(region_for_units)]];
                elseif strcmp(region, 'bla')
                    spike_abs_error_bla = ['No valid units for ' region ', ' ...
                        'but units present in ' strjoin(region_for_units)]];
                end
            else
                % command to eval update spike table
                % eval(['spikes_' region ' = [];']);
                for cell_type_label_ind = 1:numel(cell_type_labels)
                    cell_type_label = cell_type_labels(cell_type_label_ind);
                    cell_type_inds = find( spike_labels, cell_type_label, valid_unit_inds_for_region );
                    if ~isempty(cell_type_inds)
                        num_celltype_units = numel(cell_type_inds);
                        celltype_spike_ts = unit_spike_ts{cell_type_inds};
                        for unit_ind = 1:numel(cell_type_inds)
                            unit_spike_ts = celltype_spike_ts{unit_ind};
                            ind_in_full_time_bin = discretize(unit_spike_ts, fulltime_bin_edges);
                            full_unit_raster = zeros(1, n_fulltime_bins);
                            full_unit_raster(ind_in_full_time_bin) = 1;

                            % define a kernel of ones. if you want +- 50 ms
                            % then the kernel size has to determined
                            % accordingly based on bin width. then convolve
                            % using the kernel to get the mean fr on /ms
                            % unit.

                            % then, I guess get on with the robust
                            % z-scoring
                        end

                        % get time bins from start time to end time
                        % then get the spike bins and make those bins 1
                        % then get some sort of a moving window avg
                        % calculate robust z score using median abs dev

                        for row_ind = 1:num_rows
                            % Calculate time window
                            current_time = time_vec(time_inds_of_interest(row_ind));
                            frame_start_time = current_time - disp_time_win;
                            
                            % Create raster plot
                            bin_edges = frame_start_time:raster_bin_width:current_time;
                            num_bins = numel(bin_edges) - 1;
                            frame_spike_mat = zeros(num_celltype_units, num_bins);
                            for unit_ind = 1:numel(cell_type_inds)
                                unit_spike_ts = celltype_spike_ts{unit_ind};
                                bin_ind_for_each_spike = discretize(unit_spike_ts, bin_edges);
                                num_spikes_in_frame = sum(~isnan(bin_ind_for_each_spike));
                                bins_with_spike = bin_ind_for_each_spike( ~isnan(bin_ind_for_each_spike) );
                                unit_row_in_spike_mat(unit_ind, bins_with_spike) = 1;
                            end
                            repmat( cell_type_label, [numel(cell_type_inds), 1] );
                            
                            
                            % new_row = {current_time, unit_x_bin_spike_mat, spike_mat_bg, region};

                        end
                    end
                end
            end
        end
    end





end
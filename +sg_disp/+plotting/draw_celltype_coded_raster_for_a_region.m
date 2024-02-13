function draw_celltype_coded_raster_for_a_region( ax, params, current_time, region )

spike_data = params.spike_data;
validity_filter = params.unit_validity_filter;
session = params.current_session;
disp_time_win = params.disp_time_win;

unit_spike_ts = spike_data.unit_spike_ts;
spike_labels = spike_data.spike_labels;

unit_inds_for_session_and_region = find( spike_labels, [{session}, {region}, validity_filter(:)'] );

axis = ax.(region);

hold(axis, 'on');
if isempty(unit_inds_for_session_and_region)
    unit_inds_for_session = find( spike_labels, [{session}, validity_filter(:)'] );
    if isempty(unit_inds_for_session)
        text(axis, 0.5, 0.5, ...
            sprintf('There are no valid units recorded in region: %s for this session', region), ...
            'Color', 'red', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);
        title(axis, 'No valid units for session');
    else
        non_acc_bla_label = prune( spike_labels( unit_inds_for_session ) );
        region_for_units = retaineach( non_acc_bla_label, 'region' );
        region_for_units = region_for_units('region');
        text(axis, 0.5, 0.5, ...
            sprintf('No units in %s for this session, but units present in %s', ...
            region, strjoin( region_for_units) ), ...
            'Color', 'red', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);
        title(axis, 'No units in region');
    end
else
    narrow_inds = find( spike_labels, 'narrow', unit_inds_for_session_and_region );
    broad_inds = find( spike_labels, 'broad', unit_inds_for_session_and_region );
    if ~ ( isempty(narrow_inds) && isempty(broad_inds) )
        plot_raster( axis, unit_spike_ts, narrow_inds, broad_inds, current_time, disp_time_win, region );
    end
end
hold(axis, 'off');

end


function plot_raster( axis, unit_spike_ts, narrow_inds, broad_inds, current_time, disp_time_win, region)
    % Calculate time window
    start_time = current_time - disp_time_win;
    
    % Create raster plot
    bins = start_time:0.001:current_time;
    
    hold(axis, 'on');
    % Plot spikes in black for narrow units
    spike_tick_size = 10;
    narrow_spike_color = [24 75 241]/255; % Blue
    broad_spike_color = [227 154 6]/255; % Ochre
    if ~isempty(narrow_inds)
        num_narrow_units = length(narrow_inds);
        for i = 1:num_narrow_units
            spikes = unit_spike_ts{narrow_inds(i)};
            spike_indices = discretize(spikes, bins);
            if any( ~isnan(spike_indices) )
                spike_bins = spike_indices( ~isnan(spike_indices) );
                for j=1:numel(spike_bins)
                    plot(axis, bins(spike_bins(j)), i, '|', ...
                        'MarkerSize', spike_tick_size, ...
                        'LineWidth', 2.5, ...
                        'Color', narrow_spike_color);
                end
            else
                blue_background = [0.7, 0.7, 1];
                plot(axis, [start_time, current_time], ...
                    [i, i], ...
                    'Color', blue_background, ...
                    'LineWidth', 10);
            end
        end
    end
    
    % Plot spikes in black for broad units
    if ~isempty(broad_inds)
        num_broad_units = length(broad_inds);
        for i = 1:num_broad_units
            spikes = unit_spike_ts{broad_inds(i)};
            spike_indices = discretize(spikes, bins);
            if any( ~isnan(spike_indices) )
                spike_bins = spike_indices( ~isnan(spike_indices) );
                for j=1:numel(spike_bins)
                    plot(axis, bins(spike_bins(j)), num_narrow_units+i, '|', ...
                        'MarkerSize', spike_tick_size, ...
                        'LineWidth', 2.5, ...
                        'Color', broad_spike_color);
                end
            else
                red_background = [1, 0.7, 0.7];
                plot(axis, [start_time, current_time], ...
                    [num_narrow_units+i, num_narrow_units+i], ...
                    'Color', red_background, ...
                    'LineWidth', 10);
            end
        end
    end
    
    % Set plot properties
    title(axis, ['Raster Plot - ' region]);
    xlabel(axis, 'Time (s)');
    ylabel(axis, 'Unit');
    xlim(axis, [start_time current_time]);
    ylim(axis, [0.5 num_narrow_units+num_broad_units+0.5]);
    set(axis, 'YDir', 'reverse');
    hold(axis, 'off');
end

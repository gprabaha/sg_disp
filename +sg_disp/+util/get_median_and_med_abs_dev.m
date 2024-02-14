function [median_activity, mad_value] = get_median_and_med_abs_dev( data )

median_activity = median( data, 'omitnan');
mad_value = median(abs( data - median_activity ), 'omitnan');

end
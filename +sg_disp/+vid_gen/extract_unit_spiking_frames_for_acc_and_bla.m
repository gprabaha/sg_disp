function [spikes_acc, spikes_bla] = extract_unit_spiking_frames_for_acc_and_bla( behav_data, spike_data, params )

for region_ind = 1:numel(regions)
    region = regions{region_ind};

end
unit_inds_for_session_and_region = find( spike_labels, [{session}, {region}, validity_filter(:)'] );



end
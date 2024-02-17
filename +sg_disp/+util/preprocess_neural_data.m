function spike_data = preprocess_neural_data(data_p)
    
    disp('Loading sorted neural data...');
    sorted = shared_utils.io.fload(fullfile(data_p, 'sorted_neural_data_social_gaze.mat'));
    disp('Loading celltype labels data...');
    ct_labels = shared_utils.io.fload(fullfile(data_p, 'celltype-labels_pfc-combined-class_p2v.mat'), 'ct_labels');
    disp('Done');

    %% Preprocessing Neural data

    disp('Preprocessing data...');
    [all_unit_spike_ts, unit_wfs, spike_labels] = eisg.util.linearize_sorted(sorted);
    bfw.add_monk_labels(spike_labels);
    validity_filter = {'valid-unit', 'maybe-valid-unit'};
    [uuid_I, uuids] = findall(spike_labels, 'uuid', find(spike_labels, validity_filter));
    match_I = bfw.find_combinations(ct_labels, uuids);
    for i = 1:numel(uuid_I)
        if (~isempty(match_I{i}))
            ct_label = cellstr(ct_labels, 'cell-type', match_I{i});
            addsetcat(spike_labels, 'cell-type', ct_label, uuid_I{i});
        end
    end
    replace(spike_labels, 'n', 'narrow');
    replace(spike_labels, 'm', 'broad');
    replace(spike_labels, 'b', 'outlier');
    disp('Done');

    spike_data = struct();
    spike_data.all_unit_spike_ts = all_unit_spike_ts;
    spike_data.spike_labels = spike_labels;

    % Save spike_data
    save( fullfile( data_p, 'spike_data_celltype_labelled.mat' ), 'spike_data' );
end

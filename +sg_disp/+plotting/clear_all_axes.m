function clear_all_axes(ax)
    % Iterate through each field of the struct
    fields = fieldnames(ax);
    for i = 1:numel(fields)
        % Clear the axis object using cla
        cla(ax.(fields{i}));
    end
end
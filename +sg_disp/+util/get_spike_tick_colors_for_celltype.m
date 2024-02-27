function color = get_spike_tick_colors_for_celltype( celltype )

if strcmp( celltype, 'narrow')
    color = [128, 0, 0]./255; % maroon
elseif strcmp( celltype, 'broad')
    color = [240, 50, 230]./255; % magenta
else
    error(['!!Unknown celltype: ', celltype, '!!']);
end

end
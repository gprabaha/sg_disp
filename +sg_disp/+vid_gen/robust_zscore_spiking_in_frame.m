function rob_zsored_data = robust_zscore_spiking_in_frame( data, median, med_abs_dev )

rob_zsored_data = (data - median) / med_abs_dev;

end
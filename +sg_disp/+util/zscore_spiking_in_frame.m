function zscored_spiking = zscore_spiking_in_frame( spiking_vec, mean_activity, std_activity )

zscored_spiking = ( spiking_vec - mean_activity ) / std_activity;

end
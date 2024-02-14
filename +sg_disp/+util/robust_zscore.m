function robust_z_scores = robust_zscore(data)
    % Calculate the median and median absolute deviation (MAD)
    median_value = median(data);
    mad_value = median(abs(data - median_value));
    
    % Compute the robust z-scores
    robust_z_scores = (data - median_value) / mad_value;
end
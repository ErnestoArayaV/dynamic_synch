function disp_nice_metrics(metrics)

% metrics
% size(metrics,1)

if size(metrics,1) == 6
    rowNames = {'corr', 'rmse', 'kend', 'pflip', 'dafi', 'smot'}; % Cell array of row names
elseif size(metrics,1) == 7
     rowNames = {'corr', 'rmse', 'kend', 'pflip', 'dafi', 'smot', 'beta'}; % Cell array of row names
end
    
ATB= array2table(metrics, 'RowNames', rowNames);

columnNames = {'spectral','ppm','gtrs','gs','ltrs_gmd'};  % metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd
ATB.Properties.VariableNames = columnNames;
disp(ATB)

end
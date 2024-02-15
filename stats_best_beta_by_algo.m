function [ metrics ] = stats_best_beta_by_algo( MTX_metrics, beta_list )
% dafiMtx = squeeze(MTX_metrics(5, : , :))';
% save debug_best_beta.mat MTX_metrics   beta_list
% disp('savedddd MTX_metrics');
% sss 

% load  debug_best_beta.mat 

size(MTX_metrics);   %   6metrics x  5methods x  21betas

dafiMtx = squeeze(MTX_metrics(5, : , :))';

dafiMtx;  % nrBetas x nrMethods

nrBetas = size(dafiMtx,1);
nrMethods = size(dafiMtx,2);

% metrics = NULL;

metrics = [];
for i = 1:nrMethods
    x = dafiMtx(:,i);
    % disp('size of x'); size(x);
    [argvalue, argmax] = max(x);
    disp( [ 'i=' ,   int2str(i) ] ); 
    y = MTX_metrics(:, i , argmax );
    beta_star = beta_list(argmax);
    y = [ y;  beta_star ];
    metrics = [metrics y ];
    % input('key')
end

metrics;
% of size  metrics x nrMethods
% metrics has the last row as the beta optimal 

end
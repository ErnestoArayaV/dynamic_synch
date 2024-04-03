%--------------------------------------------------------------------------------------------------------
%% stats_best_beta_by_algo( MTX_metrics, beta_list )
%
%% Inputs: 
%
% MTX_metrics (Nr. of metrics x  Nr. of  methods x  Nr. of betas)
% beta_list: vector of candidates
%
%% Output
%
% metrics : Size of `metrics' is (Nr. of metrics + 1) x Nr. of Methods. Actually, the last row 
% contains the optimal beta for each algorithm (which is not really a metric)
%--------------------------------------------------------------------------------------------------------

function [ metrics ] = stats_best_beta_by_algo( MTX_metrics, beta_list )

size(MTX_metrics);  % tensor size: 6 metrics x  Nr. of  methods x  Nr. of betas

%--------------------------------------------------------------------
% dafiMtx stores the data fidelity value for each algorithm for each
% candidate choice of beta. Size is Nr. of betas x  Nr. of  methods.
%--------------------------------------------------------------------
dafiMtx = squeeze(MTX_metrics(5, : , :))'; 

nrBetas = size(dafiMtx,1);
nrMethods = size(dafiMtx,2);

metrics = [];
for i = 1:nrMethods
    
    % vector of data fidelity values (for different choices of beta) for ith algorithm 
    x = dafiMtx(:,i); 
    [~, argmax] = max(x);
    
    %--------------------------------------------------------------------------
    % Store the performance output for ith algorithm for optimal beta, in y
    % The last entry of y is the optimal beta for the ith algorithm
    %--------------------------------------------------------------------------
    y = MTX_metrics(:, i , argmax ); 
    beta_star = beta_list(argmax);
    y = [ y;  beta_star ];
    
    % Append column by column
    metrics = [metrics y ]; 
end

end
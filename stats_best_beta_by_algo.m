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
    
    if i <= 3  % (SPEC, PPM, GTRS)
    
    [~, argmax] = max(x);
    
    %--------------------------------------------------------------------------
    % Store the performance output for ith algorithm for optimal beta, in y
    % The last entry of y is the optimal beta for the ith algorithm
    % (corresponding to beta with large data fidelity value)
    %--------------------------------------------------------------------------
    y = MTX_metrics(:, i , argmax ); 
    beta_star = beta_list(argmax);
    y = [ y;  beta_star ];
    
    else % i = 4 or 5 (LTRS-GS or GMD-LTRS)
       
    angles = zeros(nrBetas,1);
        
        for j = 2:nrBetas
             angles(j) = atan((x(j)-x(j-1))/(beta_list(j)-beta_list(j-1)));
        end
        
     angles(1) = angles(2); % extrapolate linearly to the left
     
     angle_diffs = zeros(nrBetas,1);
     
        for j = 2:(nrBetas-1)
             angle_diffs(j) = abs(angles(j+1)-angles(j));
        end
        
     [~, argmax] = max(angle_diffs); % Find the index with the largest change in angle
    
    %---------------------------------------------------------------------------------
    % Store the performance output for ith algorithm for optimal beta, in y
    % The last entry of y is the optimal beta for the ith algorithm
    % (corresponding to beta with large change in the slope of data fidelity values. 
    %----------------------------------------------------------------------------------
    y = MTX_metrics(:, i , argmax ); 
    beta_star = beta_list(argmax);
    y = [ y;  beta_star ];
        
    end
    
    % Append column by column
    metrics = [metrics y ]; 
end

end
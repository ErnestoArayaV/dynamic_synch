%
% run_MonteCarlo(30, 10, 'wigner', 0.10, 1, 20 )
% run_MonteCarlo(30, 10, 'wigner', 0.10, 1, 3, 4 )
%

function [avg_metrics , std_metrics] = run_MonteCarlo(n, T, noise_model, noise, p, scan_ID, nrExp, ALGO)

randseedoffset = randi(10^5) + 1;

disp([ 'nrExp=', int2str(nrExp) ] ); 

parfor i = 1:nrExp
    rng(randseedoffset+i, 'twister');
    
%----------------------------------------------------------------------------------------------    
% Columns of MTX_metrics(:,:,i) are in order: 
% [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd];
%
% Rows of MTX_metrics(:,:,i) are ordered as: 
% [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT; optimal beta (via DataFi)]
%-----------------------------------------------------------------------------------------------
    MTX_metrics(:,:,i) = run_MonteCarlo_instance(n, T, noise_model, noise, p, scan_ID, ALGO);
end

% calculate average and std. deviation of metrics 

avg_metrics = mean(MTX_metrics,  3 ); % 7 by 5
std_metrics = std(MTX_metrics, 0, 3 ); % 7 by 5


disp('------------------------------->>>   Average:  <<<------------------------------- ')
disp_nice_metrics(avg_metrics);
disp('------------------------------->>>   Stdev:    <<<------------------------------- ')
disp_nice_metrics(std_metrics);
disp([' ------>>   n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)  ' ; nrExp=' int2str(nrExp)]);

end


% function [] = test_parfor_is_working()
% 
% tic
% n = 30;
% A = 500;
% a = zeros(1,n);
% for i = 1:n
%     a(i) = max(abs(eig(rand(A))));
% end
% toc
% 
% 
% tic
% a = zeros(1,n);
% parfor i = 1:n
%     a(i) = max(abs(eig(rand(A))));
% end
% toc
% 
% zzzz
% 
% end

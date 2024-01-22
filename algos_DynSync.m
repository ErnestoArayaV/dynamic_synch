function [ metrics, sols] = algos_DynSync(data, gt, PARS)
% algos_DynSync:  Summary of this function goes here

% disp('Start of algos_DynSync()::: ');

PARS.nrMetrics = 6;  

%% spectral algo
if PARS.run_spectral == 1
    g_init = algo_spectral_so2(data, PARS.E_n, PARS.T, PARS.lam);
    metrics_spectral = perf_metrics(g_init, gt, PARS);  % input('xx')
else
    g_init = NaN(PARS.n * PARS.T, 1); 
    metrics_spectral = NaN(PARS.nrMetrics, 1); 
end

    
%% ppm-DynSync algo: 
if PARS.run_ppm == 1
    g_ppm = algo_ppm_DynSync(data, PARS.E_n1, PARS.T, g_init, PARS.lam, PARS.num_iter_ppm);
    metrics_ppm  = perf_metrics(g_ppm, gt, PARS);  %  input('xx')
else
    g_ppm = NaN(PARS.n * PARS.T, 1); 
    metrics_ppm = NaN(PARS.nrMetrics, 1); 
end


%% GTRS-DynSync alg.(global GTRS)
if PARS.run_GTRS == 1       
    g_gtrs = algo_GTRS_DynSync(data, PARS.E_n1, PARS.T, 1000*PARS.lam);
    metrics_gtrs = perf_metrics(g_gtrs, gt, PARS); % input('xx')
else
    g_gtrs = NaN(PARS.n * PARS.T, 1); 
    metrics_gtrs = NaN(PARS.nrMetrics, 1); 
end
%EA:NOTE= this part was crashing. I detected it was to the TRSgep function.
%It seems to happen when it enters to the 'hard case'. Apparently, there is
%a numerical issue, when the lambda for TRS is large and
%PARS.num_small_eigs is not too small. 

%% LTRS-GS-DynSync alg. (local TRS+low freq.proj.)
if PARS.run_LTRS_GS == 1       
    g_ltrs_gs = algo_LTRS_GS_DynSync(data, PARS.T, PARS.P_tau_n1);
    metrics_ltrs_gs = perf_metrics(g_ltrs_gs, gt, PARS); % input('xx')
else
    g_ltrs_gs = NaN(PARS.n * PARS.T, 1); 
    metrics_ltrs_gs = NaN(PARS.nrMetrics, 1); 
end


%% LTRS-GMD-DynSync alg. (global matrix denoising+ local sync.)
if PARS.run_LTRS_GMD == 1       
    g_ltrs_gmd = algo_LTRS_GMD_DynSync(data, PARS.T, PARS.P_tau_n);
    metrics_ltrs_gmd= perf_metrics(g_ltrs_gmd, gt, PARS); % input('xx')
else
    g_ltrs_gmd = NaN(PARS.n * PARS.T, 1); 
    metrics_ltrs_gmd = NaN(PARS.nrMetrics, 1); 
end

sols = [ g_init  g_ppm  g_gtrs  g_ltrs_gs  g_ltrs_gmd ];
size(sols);

metrics = [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ];

% disp('End of algos_DynSync().');
end


function [ metrics ] = perf_metrics(est, gt, PARS)

% data, PARS.E_n1,  
% A,      SMt_n_1    

%corr = abs(dot(est, gt))/( PARS.n * PARS.T  );% recall to change
corr= real(est'*gt)/( PARS.n * PARS.T  );

%% to double check later:
% RMSE = sqrt( norm(gt - est ,2)  / ( PARS.n * PARS.T ) );
RMSE = ( 1 / sqrt(PARS.n * PARS.T) )  *  norm(gt - est ,2);

ANG_EST = get_ANG_EST(est);

ANG_GT = get_ANG_EST(gt);

[perc_flips, nr_flips, ~, corrKend] = kendall( ANG_GT, ANG_EST);

% 5th metric: edge happy/unhappyness
% 6th metric: smoothness term 

size(PARS.A_tilde_blk); 
size(PARS.b); 
size(est);
[ est  gt];

[ g_tilde ] = extract_g_tilde(est, PARS);

DAFI = real( ctranspose(g_tilde) * PARS.A_tilde_blk * g_tilde + 2 * real( ctranspose(PARS.b) * g_tilde ) );

SMt_n_1 = PARS.E_n1;
lam_smot =  PARS.lam;
SMOT = real(lam_smot * ctranspose(g_tilde) *  SMt_n_1 * g_tilde);

metrics = [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT ]; 

% for the real data, add the objective function value (since no ground truth)
end


function [ g_tilde ] = extract_g_tilde(est, PARS)

n = PARS.n;
T = PARS.T;
% N = n * T;
% disp('In extract_g_tilde():::');
% disp(n);
% disp(T);
g_tilde = zeros( (n-1) * T, 1);

for k = 1 : T
    % from each slide, select indicex 2:n
    g_tilde( ((k-1)* (n-1) +1): k*(n-1) ) = est( ((k-1)*n+2) : (k*n) );
end

end
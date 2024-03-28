%
%
%% algos_DynSync(data, gt, PARS)
%
%
%% Inputs:
%
% data: nT x N data matrix
% gt: nT x 1 vector of smooth ground truth signal
% PARS: main structure for storing simulation related data
%
%% Output: 
%
% `metrics', this is a matrix which stores the performance of each
% algorithm for the different criteria (corr, rmse etc.) for the specified beta (grid value). 
% Its size is Nr. of metrics x Nr. of algorithms.
% The 'ordering' of the columns is  
%

function [ metrics, sols] = algos_DynSync(data, gt, PARS)

%
% Currently 6 performance metrics are used for measuring the performance of
% each algorithm
%
PARS.nrMetrics = 6;  

%% spectral algo
% Local spectral heuristic. NOTE: It doesn't depend on beta. So it will be a horizontal line.  
if PARS.run_spectral == 1
    g_spec = algo_spectral_local(data, PARS.T);
    metrics_spectral = perf_metrics(g_spec, gt, PARS); 
else
    g_spec = NaN(PARS.n * PARS.T, 1); 
    metrics_spectral = NaN(PARS.nrMetrics, 1); 
end


%% GTRS-DynSync alg.(global TRS)
if PARS.run_GTRS == 1       
    g_gtrs = algo_GTRS_DynSync(data, PARS.E_n1, PARS.T, PARS.lam_gtrs);
    metrics_gtrs = perf_metrics(g_gtrs, gt, PARS); % input('xx')
else
    g_gtrs = NaN(PARS.n * PARS.T, 1); 
    metrics_gtrs = NaN(PARS.nrMetrics, 1); 
end
%EA:NOTE= this part was crashing. I detected it was to the TRSgep function.
%It seems to happen when it enters to the 'hard case'. Apparently, there is
%a numerical issue, when the lambda for TRS is large and
%PARS.num_small_eigs is not too small. 

%% LTRS-GS-DynSync alg. (local TRS+ Global smoothing (via low freq.proj.))
if PARS.run_LTRS_GS == 1       
    g_ltrs_gs = algo_LTRS_GS_DynSync(data, PARS.T, PARS.P_tau_n1);
    metrics_ltrs_gs = perf_metrics(g_ltrs_gs, gt, PARS); 
else
    g_ltrs_gs = NaN(PARS.n * PARS.T, 1); 
    metrics_ltrs_gs = NaN(PARS.nrMetrics, 1); 
end


%% LTRS-GMD-DynSync alg. (global matrix denoising+ local sync.)
if PARS.run_LTRS_GMD == 1       
    g_ltrs_gmd = algo_LTRS_GMD_DynSync(data, PARS.T, PARS.P_tau_n);
    metrics_ltrs_gmd= perf_metrics(g_ltrs_gmd, gt, PARS); 
else
    g_ltrs_gmd = NaN(PARS.n * PARS.T, 1); 
    metrics_ltrs_gmd = NaN(PARS.nrMetrics, 1); 
end

%% PPM-DynSync algo: 
% Set initializer: 'SPEC', 'GTRS', 'LTRS-GS', 'LTRS-GMD'

if strcmp(PARS.ppm_initializer,'SPEC')
    g_init = g_spec;
elseif strcmp(PARS.ppm_initializer,'GTRS')
     g_init = g_gtrs;
elseif strcmp(PARS.ppm_initializer, 'LTRS-GS')
     g_init = g_ltrs_gs;
elseif strcmp(PARS.ppm_initializer,'LTRS-GMD')
     g_init = g_ltrs_gmd;
else 
    disp('incorrect initializer');
    return;
end

% Run PPM with specified initializer
if PARS.run_ppm == 1
    g_ppm = algo_ppm_DynSync(data, PARS.E_n1, PARS.T, g_init, PARS.lam_ppm, PARS.num_iter_ppm);
    metrics_ppm  = perf_metrics(g_ppm, gt, PARS);  %  input('xx')
else
    g_ppm = NaN(PARS.n * PARS.T, 1); 
    metrics_ppm = NaN(PARS.nrMetrics, 1); 
end


%% Store solutions of the algorithms
sols = [ g_spec  g_ppm  g_gtrs  g_ltrs_gs  g_ltrs_gmd ];

%% Store the performance outputs for all the algorithms
metrics = [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ];

end
%-----------------------------------------------------------------------------------------------

%% perf_metrics(est, gt, PARS)
%
%
%% Inputs:
%
% est: nT x 1 vector, this is an estimate of gt (below)
% gt: nT x 1 vector of smooth ground truth signal
% PARS: main structure for storing simulation related data
%
%% Output: 
%
% `metrics', this is a matrix which stores the performance of each
% algorithm for the different criteria (corr, rmse etc.) for the specified beta (grid value). 
% Its size is Nr. of metrics x Nr. of algorithms
%------------------------------------------------------------------------------------------------

function [ metrics ] = perf_metrics(est, gt, PARS)

% 1st criteria: Correlation 
corr = real(est'*gt)/( PARS.n * PARS.T  );

% 2nd criteria: RMSE 
RMSE = ( 1 / sqrt(PARS.n * PARS.T) )  *  norm(gt - est ,2);

% 3rd and 4th criteria: KendallTau correlation and percentage of `upsets' 
ANG_EST = get_ANG_EST(est);
ANG_GT = get_ANG_EST(gt);
[perc_flips, nr_flips, ~, corrKend] = kendall( ANG_GT, ANG_EST);

%
% 5th criteria: data fidelity (edge `happy/unhappyness')
% DAFI is just the data fidelity objective term in the paper
%
[ g_tilde_est ] = extract_g_tilde(est, PARS); % extract gtilde part
DAFI = real( ctranspose(g_tilde_est) * PARS.A_tilde_blk * g_tilde_est + 2 * real( ctranspose(PARS.b) * g_tilde_est ) );

% 6th metric: smoothness term 
SMt_n_1 = PARS.E_n1;

%lam_smot =  PARS.lam;
%SMOT = real(lam_smot * ctranspose(g_tilde) *  SMt_n_1 * g_tilde); %% HT Remove
%this!!

SMOT = real(ctranspose(g_tilde_est) *  SMt_n_1 * g_tilde_est);

% Store the above computed values in metrics
metrics = [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT ]; 

% for the real data, add the objective function value (since no ground truth)
end

%-----------------------------------
%% extract_g_tilde(g, PARS)
%
%
%% Inputs: 
% 
% g: nT x 1 vector
% PARS: main structure for storing sims related info
%
%% Ouput:
%
% g_tilde: (n-1)T x 1 vector formed by extracting the bottom n-1
% coordinates from each n x 1 block of g (see paper)
%
%
function [ g_tilde ] = extract_g_tilde(g, PARS)

n = PARS.n;
T = PARS.T;
% N = n * T;
% disp('In extract_g_tilde():::');
% disp(n);
% disp(T);
g_tilde = zeros( (n-1) * T, 1);

for k = 1 : T
    % from each slide, select indicex 2:n
    g_tilde( ((k-1)* (n-1) +1): k*(n-1) ) = g( ((k-1)*n+2) : (k*n) );
end

end
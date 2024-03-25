%
%
%% algos_DynSync_given_beta(beta_reg, data, gt, PARS)
%
%
%% Inputs:
%
% beta_reg: value of beta on the grid (scalar)
% data: nT x N data matrix
% gt: nT x 1 vector of smooth ground truth signal
% PARS: main structure for storing simulation related data
%
%% Output: 
%
% `metrics', this is a matrix which stores the performance of each
% algorithm for the different criteria (corr, rmse etc.) for the specified beta (grid value). 
% Its size is Nr. of metrics x Nr. of algorithms
%

function [ metrics ] = algos_DynSync_given_beta(beta_reg, data, gt, PARS)

%
% Lambda is a regularization parameter used in the GTRS and PPM methods, see
% paper. The larger the value of lambda, the more smooth the solution.
%

if PARS.run_ppm == 1
   PARS.lam_ppm_scale = 0.5;
   PARS.lam_ppm =  PARS.lam_ppm_scale*beta_reg;
end

if PARS.run_GTRS == 1 
   PARS.lam_gtrs_scale = 0.5;
   PARS.lam_gtrs = PARS.lam_gtrs_scale*beta_reg;
end

%
% It is a reg. parameter used in the LTRS-GS AND GMD-LTRS methods. 
% This is the number of eigenvalues of the path laplacian (starting with
% smallest). Should be an integer smaller than T. The smaller the value of
% tau, the smoother the solution.
%
PARS.tau = min(floor(beta_reg)+1, PARS.T); 

%
% Projection matrices onto the 'low freq' space
% (space spanned by smallest tau eigenvectors of path laplacian)
%
PARS.V_tau =  projmat_smalleigs_lap(PARS.T, PARS.tau,'number'); 
PARS.P_tau_n = kron(PARS.V_tau, speye(PARS.n));
PARS.P_tau_n1 = kron(PARS.V_tau, speye(PARS.n - 1));

% Store the performance output for different algorithms for different
% metrics. Size is Nr. of metrics x Nr. of algorithms
[metrics, ~] = algos_DynSync(data, gt, PARS);  
metrics = round(metrics,4);

end


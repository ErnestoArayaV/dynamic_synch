function [ metrics ] = algos_DynSync_given_beta(beta_reg, data, gt, PARS)

% beta_reg 
% beta_reg = 2/3; % parameter for regularization as T^beta_reg. see definition of 'lam'

% PARS.lam = ((PARS.T / PARS.ST ).^beta_reg) * (PARS.noise^( 4/3));         %  the larger the lambda, the larger  the smoothness 
% PARS.tau = ((PARS.T / PARS.ST ).^beta_reg) * (PARS.noise^(-4/3)) / PARS.n;%  the larger the tau,    the smaller the smoothness 
PARS.lam = beta_reg;%((PARS.T / PARS.ST ).^beta_reg) * (PARS.noise^( 4/3));
PARS.tau = min(ceil(beta_reg)+1, PARS.T);%min(ceil((((PARS.T)^2* PARS.ST ).^beta_reg) * (PARS.noise^(-2/3)) / (PARS.n)^(1/3)),PARS.T);%  the larger the tau,    the smaller the smoothness 

% projection matrices onto the 'low freq' space
%PARS.V_tau =  projmat_smalleigs_lap(PARS.T, PARS.tau,'bound');
PARS.V_tau =  projmat_smalleigs_lap(PARS.T, PARS.tau,'number');
PARS.P_tau_n = kron(PARS.V_tau, speye(PARS.n));
PARS.P_tau_n1 = kron(PARS.V_tau, speye(PARS.n - 1));

[ metrics ] = algos_DynSync(data, gt, PARS);  

metrics = round(metrics,4);

% scatterplot beta/lambda vs  edgeUnhappyness/data fidelity   or   smoothness

end


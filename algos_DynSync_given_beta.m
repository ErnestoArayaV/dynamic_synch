%beta_reg is a hyperparameter that controls the level of regularization
%see the definition of tau and lambda below

function [ metrics ] = algos_DynSync_given_beta(beta_reg, data, gt, PARS)

PARS.lam = beta_reg;
PARS.tau = min(floor(beta_reg)+1, PARS.T);%this should be an integer smaller than T

% projection matrices onto the 'low freq' space
%PARS.V_tau =  projmat_smalleigs_lap(PARS.T, PARS.tau,'bound');
PARS.V_tau =  projmat_smalleigs_lap(PARS.T, PARS.tau,'number');%prefered option
PARS.P_tau_n = kron(PARS.V_tau, speye(PARS.n));
PARS.P_tau_n1 = kron(PARS.V_tau, speye(PARS.n - 1));

[ metrics ] = algos_DynSync(data, gt, PARS);  

metrics = round(metrics,4);

% scatterplot beta/lambda vs  edgeUnhappyness/data fidelity   or   smoothness

end


%% Simulations to study performance of algorithms for different values of T
%
%% sim_eType1_varyT(n, noise_model, noise, p, scan_ID, nrExp)

clear; clc;

% Simulations #1

sim_eType1_varyT(30, 'wigner', 3,  1,  1, 20);  
sim_eType1_varyT(30, 'wigner', 3,  1,  2, 20);
sim_eType1_varyT(30, 'wigner', 3,  1,  3, 20);

sim_eType1_varyT(30, 'outlier', 0.2, 0.2, 1, 20);
sim_eType1_varyT(30, 'outlier', 0.2, 0.2, 2, 20);
sim_eType1_varyT(30, 'outlier', 0.2, 0.2, 3, 20);


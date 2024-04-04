%% Simulations to study performance of algorithms for different values of T
%
%% sim_eType1_varyT(n, noise_model, noise, p, scan_ID, nrExp)

clear; clc;

% Simulations for Wigner model
sim_eType1_varyT(30, 'wigner', 4,  1,  1, 20);  
sim_eType1_varyT(30, 'wigner', 4,  1,  2, 20);
sim_eType1_varyT(30, 'wigner', 4,  1,  3, 20);

% Simulations for Outliers model
sim_eType1_varyT(30, 'outlier', 0.3, 0.2, 1, 20);
sim_eType1_varyT(30, 'outlier', 0.3, 0.2, 2, 20);
sim_eType1_varyT(30, 'outlier', 0.3, 0.2, 3, 20);
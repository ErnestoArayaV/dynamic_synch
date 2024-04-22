%% Simulations to study performance of algorithms for different noise levels
%
%% sim_eType2_varyNoise(n, T, noise_model, p, scan_ID, nrExp)

% Simulations for small T

sim_eType2_varyNoise(30, 20, 'wigner', 1, 1, 20);
sim_eType2_varyNoise(30, 20, 'wigner', 1, 2, 20);
sim_eType2_varyNoise(30, 20, 'wigner', 1, 3, 20);

sim_eType2_varyNoise(30, 20, 'outlier', 0.2, 1, 20);
sim_eType2_varyNoise(30, 20, 'outlier', 0.2, 2, 20);
sim_eType2_varyNoise(30, 20, 'outlier', 0.2, 3, 20);

% Simulations for large T

sim_eType2_varyNoise(30, 100, 'wigner', 1, 1, 20);
sim_eType2_varyNoise(30, 100, 'wigner', 1, 2, 20);
sim_eType2_varyNoise(30, 100, 'wigner', 1, 3, 20);

sim_eType2_varyNoise(30, 100, 'outlier', 0.2, 1, 20);
sim_eType2_varyNoise(30, 100, 'outlier', 0.2, 2, 20);
sim_eType2_varyNoise(30, 100, 'outlier', 0.2, 3, 20);

% Simulations with 50 MC runs

% sim_eType2_varyNoise(30, 20, 'wigner', 1, 1, 50);
% sim_eType2_varyNoise(30, 20, 'outlier', 0.2, 1, 50);
% 
% sim_eType2_varyNoise(30, 100, 'wigner', 1, 1, 50);
% sim_eType2_varyNoise(30, 100, 'outlier', 0.2, 1, 50);





%% simulations to study performance of algorithms for different noise levels

%% sim_eType2_varyNoise(n, T, noise_model, p, scan_ID, nrExp)

clear; clc;

sim_eType2_varyNoise(30, 20, 'wigner', 1, 2, 25);
sim_eType2_varyNoise(30, 100, 'wigner', 1, 2, 25);

sim_eType2_varyNoise(30, 20, 'wigner', 1, 3, 25);
sim_eType2_varyNoise(30, 100, 'wigner', 1, 3, 25);

sim_eType2_varyNoise(30, 20, 'outlier', 0.2, 2, 25);
sim_eType2_varyNoise(30, 100, 'outlier', 0.2, 2, 25);

sim_eType2_varyNoise(30, 20, 'outlier', 0.2, 3, 25);
sim_eType2_varyNoise(30, 100, 'outlier', 0.2, 3, 25);
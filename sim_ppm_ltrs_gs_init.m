%% simulations to study PPM performance with initialization by LTRS-GS

clear; clc;

% Tests for scan-Id = 3
sim_eType1_varyT(30, 'wigner', 0.01,  1,  3, 25);
sim_eType1_varyT(30, 'wigner', 0.05,  1,  3, 25);
sim_eType1_varyT(30, 'wigner', 0.1,  1,  3, 25);
sim_eType1_varyT(30, 'wigner', 0.5,  1,  3, 25);
sim_eType1_varyT(30, 'wigner', 1,  1,  3, 25);

sim_eType1_varyT(30, 'outlier', 0.005,  0.2,  3, 25);
sim_eType1_varyT(30, 'outlier', 0.01,  0.2,  3, 25);
sim_eType1_varyT(30, 'outlier', 0.05,  0.2,  3, 25);
sim_eType1_varyT(30, 'outlier', 0.1,  0.2,  3, 25);
sim_eType1_varyT(30, 'outlier', 0.2,  0.2,  3, 25);

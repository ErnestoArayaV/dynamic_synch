%% simulations to study PPM performance with initialization by LTRS-GS

clear; clc;

 sim_eType1_varyT(30, 'wigner', 0.1, 1, 2, 25);
 sim_eType1_varyT(30, 'wigner', 1, 1, 2, 25);
 sim_eType1_varyT(30, 'wigner', 3, 1, 2, 25);
 sim_eType1_varyT(30, 'wigner', 10, 1, 2, 25);
 sim_eType1_varyT(30, 'wigner', 15, 1, 2, 25);

 
% sim_eType1_varyT(30, 'wigner', 0.5,  1,  2, 25);
% sim_eType1_varyT(30, 'wigner', 1,  1,  2, 25);

% sim_eType1_varyT(30, 'wigner', 2,  1,  2, 25);
% sim_eType1_varyT(30, 'wigner', 2,  1,  3, 25);
% sim_eType1_varyT(30, 'wigner', 3,  1,  2, 25);
% sim_eType1_varyT(30, 'wigner', 3,  1,  3, 25);

sim_eType1_varyT(30, 'outlier', 0.01,  0.2,  2, 25);
sim_eType1_varyT(30, 'outlier', 0.05,  0.2,  2, 25);
sim_eType1_varyT(30, 'outlier', 0.2,  0.2,  2, 25);
sim_eType1_varyT(30, 'outlier', 0.6,  0.2,  2, 25);
sim_eType1_varyT(30, 'outlier', 0.8,  0.2,  2, 25);

% sim_eType1_varyT(30, 'outlier', 0.15,  0.2,  2, 25);
% sim_eType1_varyT(30, 'outlier', 0.15,  0.2,  3, 25);

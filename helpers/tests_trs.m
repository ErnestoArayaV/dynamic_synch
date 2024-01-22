n = 20;
T = 10;
ST = 1/T;
beta_reg = 2/3;
noise_lev = 0;
M = laplacian_path(T);
pm = projmat_smalleigs_lap(T,4,'number');
gt = generate_ground_truth(n,T,pm);
sig = generate_AGN_signal(gt,T,noise_lev);

%lam_trs = noise_lev*T;
tau = ((T/ST).^beta_reg)*(noise_lev^(-4/3))/n;
g_denproj = algo_denoiseNproject(sig,T,tau);
abs(dot(g_denproj, gt))/(n*T)
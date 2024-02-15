% n = 50 keep fixed
% T scan 10 :10 :50
% noise level scan to crash all methods 
% keep the beta_range constant across all algos; each algo chooses its optimal beta
% {Wigner, outliers} noise models


% run_instance(30, 10, 'wigner', 0.10, 1)
% run_instance(30, 10, 'outlier', 0.10, 1)

function  [  metrics, sols ] = run_instance(n, T, noise_model, noise, p)

% rand('state', 123);
 
addpath(genpath('helpers'));
addpath(genpath('algos'));

disp([' ------>>  n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) ]);

PARS.n=n;
PARS.T=T;
PARS.noise_model = noise_model;
PARS.noise = noise;
PARS.p = p;

%% set to 0 if we want to disable any single algo
PARS.run_spectral = 1;
PARS.run_ppm = 1;
PARS.run_GTRS = 1;       
PARS.run_LTRS_GS = 1;  
PARS.run_LTRS_GMD = 1;   

%EA:NOTE = If we use the number of eigenvalues to generate the ground truth we won't need this part. Additionally, it's better if 'beta_reg' doesn't depend on an unobserved param.
%Check it pls.
% PARS.scan_ID = 1;
% if PARS.scan_ID ==1
%     %%% ST = 1./T; % smoothness parameters initialiation (indepenent of n)
%     ST = 1 / sqrt(T);
% elseif PARS.scan_ID ==2
%     ST = 1;
% elseif PARS.scan_ID ==3
%      ST = sqrt(T);
% elseif PARS.scan_ID ==4
%      ST = 1/T;
% end
% PARS.ST = ST;

PARS.scan_ID = 3;
if PARS.scan_ID ==1
    %fix the smoothness of the ground truth signal
    % smoothness parameters for GT generation
    num_small_eigs=1; %completely smooth
elseif PARS.scan_ID ==2
    num_small_eigs=2; %project onto the 'low frequency' space: two first eigs 
elseif PARS.scan_ID ==3
      num_small_eigs=ceil(sqrt(T));%project onto the 'low frequency' space: sqrt(T) first eigs 
elseif PARS.scan_ID ==4
     num_small_eigs=T;%non-smooth
end
%EA: one can think in more options for the smoothness...

PARS.num_small_eigs = num_small_eigs;

PARS.num_iter_ppm = 10; % number of ppm iterations. Arbitrary for the moment, should be O(log nT) when n, T are large?
proj_mat = projmat_smalleigs_lap(T, PARS.num_small_eigs, 'number');

% generate ground truth 
gt = generate_ground_truth(n, T, proj_mat);

% add noise
if strcmp(PARS.noise_model,'wigner') == 1
    % data = generate_AGN_data(gt, T, noise);      size(data);
    [ data, G_union, list_Gk ]  = generate_AGN_data_sparse(gt, T, noise, p);  size(data);
elseif strcmp(PARS.noise_model,'outlier') == 1
    [ data, G_union, list_Gk ]  = generate_Outlier_data_sparse(gt, T, noise, p);  size(data);
end

% record the number of connected components:
%% sparsify the graph: within each slice, only retain each edge with probability p
% record the number of connected components:
% ensure the union graph is connected 
[bfs_comp_vertex , comp_number, length_comp] = BFS_connected_components(G_union);
disp([ 'comp_number=', int2str(comp_number) ]);  
if comp_number > 1
    disp('Abort missing.. the union graph is disconnected');
end
length_comp


%% smoothness matrices.
%% TODO: this matrices can be precomputed outside and load them here.   -- can move before the Monte Carlo 
M = laplacian_path(T);
PARS.E_n = kron(M, speye(n));
PARS.E_n1 = kron(M, speye(n-1));

[ A_tilde_blk, b]=subroutine_matrix_tilde_decomp(data,n,T);%decompose the matrix into its 'tilde' parts.
PARS.A_tilde_blk = A_tilde_blk;
PARS.b = b;

[ metrics ] = algos_DynSync_auto_beta(data, gt, PARS);

disp_nice_metrics(metrics);
disp([' ------>>   n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) ]);

% disp('---- End of run_instance() ----');
end

%------------------------------------------------------
%% run_MonteCarlo_instance(n, T, noise_model, noise, p, scan_ID, ALGO)
%
%% Inputs:
% n : size of the graph at each time point
% T : the number of time points
% noise: sigma for Wigner model and 1 - eta for outliers model 
% noise_model: {Wigner, outlier} 
% p: Graph sparsity (it should be 1 in Wigner model)
% scan_ID: 1,2 and 3 (set Quadratic smoothness of the ground truth). E.g., scan_ID = 1
% means ST = 1/T, see the code for other values.
%
% ALGO: Structure containing algorithm related parameters (algo 'on/off' flags,
% etc.)

%% Description: 
% This should be called specifically from the run_MonteCarlo() routine.
% Generate a smooth ground truth signal, then generate the data with
% appropriate noise model. For each algorithm, the optimal reg. parameter
% is found by a search over a range of values, and by using a ``data fidelity
% criteria''.
%
%% Output: 
% Performance of each algorithm (RMSE, correlation etc) displayed for the optimal 
% reg. parameter. metrics is a 7 x 5 matrix.
%
% Columns of metrics are in order: 
% [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd];
%
% Rows of metrics are ordered as: 
% [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT; optimal beta (via DataFi)]
%------------------------------------------------------

function  [  metrics, sols ] = run_MonteCarlo_instance(n, T, noise_model, noise, p, scan_ID, ALGO)

disp([' ------>>  n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) '; scan_ID =' num2str(scan_ID) ]);

%% populate simulation parameters 
PARS.n=n;
PARS.T=T;
PARS.noise_model = noise_model;
PARS.noise = noise;
PARS.p = p;
PARS.scan_ID = scan_ID;

%% Populate algo flags (on/off)
PARS.run_spectral = ALGO.run_spectral;
PARS.run_ppm = ALGO.run_ppm;
PARS.run_GTRS = ALGO.run_GTRS;       
PARS.run_LTRS_GS = ALGO.run_LTRS_GS;  
PARS.run_LTRS_GMD = ALGO.run_LTRS_GMD;   

%% Set PPM related parameters
if PARS.run_ppm == 1
   
   % Set scale for lambda for PPM
   PARS.lam_ppm_scale = 10;
   
   %% number of ppm iterations. Arbitrary for the moment, should be O(log nT) when n, T are large?
    PARS.num_iter_ppm = 10; 

    %% PPM initializer
    % Set to 'SPEC', 'GTRS', 'LTRS-GS', 'LTRS-GMD'
    PARS.ppm_initializer = 'LTRS-GS';
end

%% Set scale for lambda for GTRS 
if PARS.run_GTRS == 1 
   PARS.lam_gtrs_scale = 10;
end

%% smoothness parameters initialization (indepenent of n)

if PARS.scan_ID ==1
    ST = 1/T;
elseif PARS.scan_ID ==2
    ST = 1;
elseif PARS.scan_ID ==3
     ST = T^(0.25);
end
PARS.ST = ST;

%% generate ground truth 
gt = generate_ground_truth(n, T, PARS.ST);

%% Generate noisy pairwise data as per noise model. `G_union' is the union graph
if strcmp(PARS.noise_model,'wigner') == 1
    [ data, G_union, list_Gk ]  = generate_AGN_data_sparse(gt, T, noise, p);  size(data);
elseif strcmp(PARS.noise_model,'outlier') == 1
    [ data, G_union, list_Gk ]  = generate_Outlier_data_sparse(gt, T, noise, p);  size(data);
end

%% record the number of connected components:
%% sparsify the graph: within each slice, only retain each edge with probability p
%% record the number of connected components (comp_number) to ensure the union graph 
%% is connected 

%% HT: I am not sure of the point of this since we do not abort 
%% if the union graph is not connected!

[bfs_comp_vertex , comp_number, length_comp] = BFS_connected_components(G_union);
disp([ 'comp_number=', int2str(comp_number) ]);  
if comp_number > 1
    disp('Abort missing.. the union graph is disconnected');
end

%% smoothness matrices.
%% TODO: these matrices can be precomputed outside and loaded here
%% -- can move before the Monte Carlo 
%%
M = laplacian_path(T); % Laplacian of path graph
PARS.E_n = kron(M, speye(n)); % Kronecker of M and I_n
PARS.E_n1 = kron(M, speye(n-1)); % Kronecker of M and I_{n-1}

%% Decompose the matrix into its 'tilde' parts.
[ A_tilde_blk, b] = subroutine_matrix_tilde_decomp(data,n,T); 
PARS.A_tilde_blk  = A_tilde_blk;
PARS.b = b;

%% Run each algorithm for different choices of its reg. parameter. 
%% The output for each algorithm is stored for the best reg. parameter 
%% (as found via the data fidelity criteria) in a column of the 
%% matrix `metrics' (length of a column is the number of performance criteria)

% Columns of metrics are in order: 
% [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd];
%
% Rows of metrics are ordered as: 
% [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT; optimal beta (via DataFi)]

[ metrics ] = algos_DynSync_auto_beta(data, gt, PARS);

disp_nice_metrics(metrics);
disp([' ------>>   n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)]);

% disp('---- End of run_instance() ----');
end

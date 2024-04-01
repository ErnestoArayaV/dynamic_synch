%------------------------------------------------------
%% run_instance(n, T, noise_model, noise, p, scan_ID)
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
%% Description: 
% Generate a smooth ground truth signal, then generate the data with
% appropriate noise model. For each algorithm, the optimal reg. parameter
% is found by a search over a range of values, and by using a ``data fidelity
% criteria''.
%
%% Output: 
% Performance of each algorithm (RMSE, correlation etc) displayed for the optimal 
% reg. parameter.
%
%% Example
% run_instance(30, 10, 'wigner', 0.10, 0.5, 1)
% run_instance(30, 10, 'outlier', 0.10, 0.5, 2)
%------------------------------------------------------

function  [  metrics, sols ] = run_instance(n, T, noise_model, noise, p, scan_ID)

%% HT: commenting this out when using MC runs since the seed is
%% being set outside this function. Also the path has been set outside as
%% well.

%rand('state', 123);  

addpath(genpath('helpers'));
addpath(genpath('algos'));

disp([' ------>>  n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) '; scan_ID =' num2str(scan_ID) ]);

PARS.n=n;
PARS.T=T;
PARS.noise_model = noise_model;
PARS.noise = noise;
PARS.p = p;
PARS.scan_ID = scan_ID;

%% set to 0 if we want to disable any single algo
PARS.run_spectral = 1;
PARS.run_ppm = 1;
PARS.run_GTRS = 1;       
PARS.run_LTRS_GS = 1;  
PARS.run_LTRS_GMD = 1;   

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

%% Run each algorithm for different choices of its reg. parameter. The output for each algorithm is stored 
%% for the best reg. parameter (as found via the data fidelity criteria) in a column of the matrix `metrics' (length of a column is the number of performance criteria)
[ metrics ] = algos_DynSync_auto_beta(data, gt, PARS);

disp_nice_metrics(metrics);
disp([' ------>>   n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)]);

% disp('---- End of run_instance() ----');
end

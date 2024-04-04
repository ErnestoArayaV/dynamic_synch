%
% Signal plus noise (complex spiked Wigner) generative model.
%
% Input:          gt    - Ground truth vector with entries in SO(2). Size nTx1
%                 T     - Size of the path Laplacian. Also number of blocks.
%                 sigma - Noise level
%                 p     - the edge sparsity level 
%
% Output: data_mtx      - matrix with data of the form  gt * {gt}^H +sigma*Noise   in sparse format 
%
% additive Gaussian noise with sparsity 
%
%

function  [ data_mtx, G_union, list_Gk ] = generate_AGN_data_sparse(gt, T, sigma, p)

n = size(gt,1)/T;
list_Gk = struct([]);
data_mtx = sparse(n*T,n);  % tall matrix of stacked matrices

G_union = sparse(n,n);

for k=1:T
    G_k = ErdosRenyi(n,p); % Generate Erdos Renyi graph
    [bfs_comp_vertex , comp_number, length_comp] = BFS_connected_components(G_k);
    disp(['For slice t=', int2str(k), ' comp_number=', int2str(comp_number) ]);
    
    list_Gk(k).G = G_k;
    G_union = G_union + G_k;
    
    W = (1/sqrt(2)) * complex(randn(n,n),randn(n,n)); % noise matrix with complex Wigner law
    W = (1/sqrt(2)) * (W + W'); % Make Hermitian
    W_k_sparse = W .* G_k; % sparsify noise matrix
    %% Note: can make faster by first generating the graph and then adding noise only for the existing edges 
    
    % H_k is the complete (full) clean pairwise: 
    H_k = gt( (k-1)*n + 1 : k*n) * gt( (k-1)*n+1 : k*n )';
    H_k_sparse = H_k .* G_k;

    % Generate noisy data for the kth time point
    data_mtx((k-1)*n+1 : k*n,:) = H_k_sparse + sigma * W_k_sparse;
end

G_union = (G_union > 0);

end    

% Signal plus noise (complex spiked Wigner) generative model.
%
% Input:          gt    - Ground truth vector with entries in SO(2). Size nTx1
%                 T     - Size of the path Laplacian. Also number of blocks.
%                 sigma - Noise level
%                 p     - the edge sparsity level 

% Output: data_mtx      - matrix with data of the form  gt * {gt}^H +sigma*Noise   in sparse format 

% addive Gaussian noise with sparsity 
function  [ data_mtx, G_union, list_Gk ] = generate_AGN_data_sparse(gt, T, sigma, p)
n = size(gt,1)/T;
list_Gk = struct([]);

% data_mtx = zeros(n*T,n);  % tall matrix of stacked matrices
data_mtx = sparse(n*T,n);  % tall matrix of stacked matrices

G_union = sparse(n,n);

for k=1:T
    G_k = ErdosRenyi(n,p);
    [bfs_comp_vertex , comp_number, length_comp] = BFS_connected_components(G_k);
    disp(['For slice t=', int2str(k), ' comp_number=', int2str(comp_number) ]);
    
    list_Gk(k).G = G_k;
    G_union = G_union + G_k;
    
    W = (1/sqrt(2)) * complex(randn(n,n),randn(n,n)); % noise matrix with complex Wigner law
    % to fix - make Hermitian
    W = 1/2 * (W + W');
    
    isH = ishermitian(W);
    disp(['isH=' int2str(isH)]);
    W_k_sparse = W .* G_k;
    % todo - can make faster by first generating the graph and then adding noise only for the existing edges 
    
    % H_k is the complete (full) clean pairwise: 
    H_k = gt( (k-1)*n + 1 : k*n) * gt( (k-1)*n+1 : k*n )';
    H_k_sparse = H_k .* G_k;

    data_mtx((k-1)*n+1 : k*n,:) = H_k_sparse + sigma * W_k_sparse;
end

G_union = (G_union > 0);

end    

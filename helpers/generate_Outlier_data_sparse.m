% Signal plus noise (complex spiked Wigner) generative model.
%
% Input:          gt    - Ground truth vector with entries in SO(2). Size nTx1
%                 T     - Size of the path Laplacian. Also number of blocks.
%                 eta   - fraction of outliers
%                 p     - the edge sparsity level 

% Output: data_mtx      - matrix with data of the form  gt * {gt}^H for the clearn entries, 
%        and completely random measurements for the outliers positions; in sparse format 

function  [ data_mtx, G_union, list_Gk ] = generate_Outlier_data_sparse(gt, T, eta, p)
n = size(gt,1)/T;
list_Gk = struct([]);

data_mtx = sparse(n*T,n);  % tall matrix of stacked matrices

G_union = sparse(n,n);

for k=1:T
    G_k = ErdosRenyi(n,p);
    [bfs_comp_vertex , comp_number, length_comp] = BFS_connected_components(G_k);
    disp(['For slice t=', int2str(k), ' comp_number=', int2str(comp_number) ]);
    
    list_Gk(k).G = G_k;
    G_union = G_union + G_k;
    
    % H_k is the complete (full) clean pairwise matrix. H_k_sparse is its
    % sparsified version
    H_k = gt( (k-1)*n + 1 : k*n) * gt( (k-1)*n+1 : k*n )';
    H_k_sparse = H_k .* G_k;

    % Add outlier noise to H_k_sparse. Note that H_k_sparse_wOutliers is
    % Hermitian.
    H_k_sparse_wOutliers = addOutlierNoise( H_k_sparse, G_k, eta);
    
    isH = ishermitian(H_k_sparse_wOutliers);
    
    if(isH == 0)
      disp('Not Hermitian, abort...');
      return;
    end
    
    data_mtx((k-1)*n+1 : k*n,:) = H_k_sparse_wOutliers;
    

end

G_union = (G_union > 0);

end

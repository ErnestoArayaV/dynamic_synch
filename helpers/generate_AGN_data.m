% Signal plus noise (complex spiked Wigner) generative model.
%
% Input:          gt    - Ground truth vector with entries in SO(2). Size nTx1
%                 T     - Size of the path Laplacian. Also number of blocks.
%                 sigma - Noise level
%
% Output: data_mtx      - matrix with data of the form  gt * {gt}^H +sigma*Noise 

function data_mtx = generate_AGN_data(gt,T,sigma)
n = size(gt,1)/T;
data_mtx = zeros(n*T,n);  % tall matrix of stacked matrices

for k=1:T
    W = (1/sqrt(2)) * complex(randn(n,n),randn(n,n)); % noise matrix with complex Wigner law
    data_mtx((k-1)*n+1 : k*n,:) = gt( (k-1)*n + 1 : k*n) * gt( (k-1)*n+1 : k*n )' + sigma * W;
end

    
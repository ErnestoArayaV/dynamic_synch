%spectral algorithm for dyn. synchro. NOT included in the paper, just 
%to have as a benchmark...
%
%Input: A        -Data Matrix. Size nTxnT
%       T        -Number of time blocks.
%       SMt        -Smoothness matrix. Size nTxnT
%       lam_spec -regularization parameter.
%
%Output:g_spec   -projected spectral estimator. Size nTx1

function g_spec = algo_spectral_so2(A,SMt,T,lam_spec)
n = size(A,1)/T;
%form the block diagonal data matrix
A_blk(1:n,1:n)=A(1:n,1:n);
for k=2:T
    A_blk = blkdiag(A_blk,A((k-1)*n+1:k*n,1:n));
end
%add the smoothness regularizer
A_reg = A_blk-lam_spec*SMt;
[g_spec,~]=eigs(sparse(A_reg),1,'largestabs','Tolerance',1e-6);
g_spec=proj_C(g_spec);%projection onto the SO(2)
g_spec=proj_2(g_spec,T);%anchoring. 

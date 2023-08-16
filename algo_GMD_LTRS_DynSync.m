%Global matrix denoising + Local TRS for DynSync.(GMD-LTRS-DynSync) Algorithm 3 in the paper.
%
%Input: A                   -Data Matrix. Size nTxn
%       T                   -Number of time blocks
%       P_tau_n             -Projection low freq. matrix. Size nTxnT
%
%Output:g_hat               -Estimator. Size nTx1

function g_hat = algo_GMD_LTRS_DynSync(A,T,P_tau_n)
n = size(A,1)/T;
G_hat = P_tau_n*sparse(A);%projects onto the low frequency space. Global denoising stage.
%hermitianize each block
for k=1:T
    G_hat((k-1)*n+1:k*n,1:n) = G_hat((k-1)*n+1:k*n,1:n)+G_hat((k-1)*n+1:k*n,1:n)';
end
g_tilde_hat = subroutine_localTRS(G_hat,n,T);%solve TRS for each block. Local synchronization stage.
%this to add a 1 as first coord. at each block and projects the rest onto
%SO(2).
g_hat = zeros(n*T,1);
for k = 1:T
     g_hat((k-1)*n+1:k*n) = [1;proj_C(g_tilde_hat((k-1)*(n-1)+1:k*(n-1)))];
end







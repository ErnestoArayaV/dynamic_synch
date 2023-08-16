%Global TRS algorithm for Dyn. Sync. (GTRS-DynSyncs). Algorithm 1 in the
%paper.
%
%Input: A           -Data Matrix. Size nTxn.
%       T           -Number of time blocks.
%       SMt_n_1     -Smoothness matrix. Size (n-1)Tx(n-1)T.
%       lam_trs     -regularization parameter.
%
%Output:g_hat       -final estimator. Size nTx1.

function g_hat=algo_GTRS_DynSync(A,SMt_n_1,T,lam_trs)
n = size(A,1)/T;
[A_tilde_blk, b]=subroutine_matrix_tilde_decomp(A,n,T);%decompose the matrix into its 'tilde' parts.
%transform complex data to real, to feed the 'standard' TRS.
A_re = complextoreal(A_tilde_blk-lam_trs* SMt_n_1);%this doubles de dimension.
b_re = complextoreal(b);
%apply TRS alg. globally.
[g_trs,~] = TRSgep(-sparse(A_re),-2*b_re,speye(2*(n-1)*T),(n-1)*T);
g_trs = realtocomplex(g_trs);%back to the complex...
%this to add a 1 as first coord. at each block and projects the rest onto
%SO(2).
g_hat = zeros(n*T,1);
for k=1:T
    g_hat((k-1)*n+1:k*n) = [1;proj_C(g_trs((k-1)*(n-1)+1:k*(n-1)))];
end

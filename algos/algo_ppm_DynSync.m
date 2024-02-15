%projected power method for Dyn. Sync. (PPM_DynSync). Algorithm
%4 in the paper.
%
%Input: A       -Data Matrix. Size nTxnT
%       SMt_n_1 -Smoothness matrix. Size (n-1)Tx(n-1)T
%       T       -Number of time blocks.
%       g_0     -Initial point for the power iteration. nTx1
%       lam_ppm -Regularization parameter.
%       S       -Number of ppm iterations.
%
%Ouput: g_hat   -Estimator. Size nTx1.

function g_hat=algo_ppm_DynSync(A,SMt_n_1,T,g_0,lam_ppm,S)
n = size(A,1)/T;
[A_tilde_blk, b]=subroutine_matrix_tilde_decomp(A,n,T);%find the 'tilde' decomposition of A.
A_reg = A_tilde_blk-lam_ppm*SMt_n_1;%add the smoothness regularization term.
g_tilde = subroutine_vector_tilde_decomp(g_0,n,T); %remove the first element per block.
%power iterations
for i=1:S
    aux = sparse(A_reg)*g_tilde+b;%power step, we use the gradient of global TRS.
    g_tilde = proj_C(aux); %projection onto SO(2).
end
%adds a 1 as the first element of each block.
g_hat = zeros(n*T,1);
for k = 1:T
     g_hat((k-1)*n+1:k*n) = [1;g_tilde((k-1)*(n-1)+1:k*(n-1))];
end
    

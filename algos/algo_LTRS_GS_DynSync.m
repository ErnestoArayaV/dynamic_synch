%Local TRS + Global Smoothing algorithm for Dyn. Sync.(LTRS-GS-DynSync).
%Algorithm 2 in the paper.
%
%Input: A                   - Data Matrix. Size nTxn
%       T                   - Number of time blocks
%       P_tau_n_1           - Projection low freq. matrix. Size (n-1)Tx(n-1)T
%
%Output:g_hat               - final local TRS estimator. Size nTx1

function g_hat = algo_LTRS_GS_DynSync(A,T,P_tau_n_1)
n = size(A,1)/T;
g_tilde_hat = subroutine_localTRS(A,n,T);%this solve the local TRS problem for each block and concatenate the solutions
h_tilde = P_tau_n_1*g_tilde_hat;%project onto the low frequency space.  
%this to add a 1 as first coord. at each block and projects the rest onto
%SO(2).
g_hat = zeros(n*T,1);
for k = 1:T
     g_hat((k-1)*n+1:k*n) = [1;proj_C(h_tilde((k-1)*(n-1)+1:k*(n-1)))];
end




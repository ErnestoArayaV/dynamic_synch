%spectral algorithm for SO2 dyn. synchro.
%Input: A        -Data Matrix. Size n*Txn*T
%       T 
%       E        -Smoothness matrix. Size n*Txn*T
%       lam_spec -regularization parameter
%Output:g_spec   -projected spectral estimator. Size n*Tx1
function g_spec = algo_spectral_so2(A,E,T,lam_spec)

A_reg = A-lam_spec*E;
[g_spec,~]=eigs(sparse(A_reg),1,'largestabs','Tolerance',1e-6);
g_spec=proj_1(g_spec);
g_spec=proj_2(g_spec,T);

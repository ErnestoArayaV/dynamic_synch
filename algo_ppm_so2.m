%projected power method for SO2 dynamic synchronization
%Input: A       -Data Matrix. Size n*Txn*T
%       E       -Smoothness matrix. Size TxT
%       T
%       g_init  -Initial point for the power iteration. n*Tx1
%       lam_ppm -Regularization parameter
%       nb_iter -Number of iterations
%Ouput: g_ppm   -Estimator. Size n*Tx1.
function g_ppm=algo_ppm_so2(A,E,T,g_init,lam_ppm,nb_iter)
A_reg = A-lam_ppm*E; %add the regularization term to the data matrix
g_ppm = g_init; %initialization
%power iteration
for i=1:nb_iter
    aux = sparse(A_reg)*g_ppm; 
    g_ppm = proj_1(aux); %projection onto the product of circles
end
g_ppm=proj_2(g_ppm,T); %anchoring projection

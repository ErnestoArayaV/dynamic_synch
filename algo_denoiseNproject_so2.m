%'denoise/project' algorithm for SO(2). EA:this is just a provisory name 
%Input: A                   -Data Matrix. Size n*Txn*T
%       T 
%       proj_small_eigs     -Projection low freq. matrix. Size n*Txn*T
%Output:g_spec              -projected TRS denoise/project estimator. Size n*Tx1

function g_denproj = algo_denoiseNproject_so2(A,T,proj_small_eigs)
n = size(A,1)/T;

G = A-diag(diag(A))+speye(n*T);
G = G/norm(G,'fro');
G_proj = proj_small_eigs*sparse(G);

[g_denproj,~,~] = eigs(G_proj,1,'largestabs');
g_denproj = proj_1(g_denproj);
g_denproj = proj_2(g_denproj,T);






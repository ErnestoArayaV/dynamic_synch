%local spectral algorithm for dyn. synchro. NOT included in the paper, just 
%to have as a benchmark and heuristic for initialize ppm...
%It solves a spectral algorithm localy and then applies anchoring, do not
%impose any smoothness
%
%
%Input: A        -Data Matrix. Size nTxnT
%       T        -Number of time blocks.

%
%Output:g_spec_local -locally projected spectral estimator. Size nTx1

function g_spec_local= algo_spectral_local(A,T)
n = size(A,1)/T;
g_spec_local=zeros(n*T,1);
for k=1:T
    A_loc = A((k-1)*n+1:k*n,1:n);
    [g_spec,~]=eigs(sparse(A_loc),1,'largestabs','Tolerance',1e-6);
    g_spec=proj_C(g_spec);%projection onto the SO(2)
    g_spec=proj_2(g_spec,1);%anchoring. 
    g_spec_local((k-1)*n+1:k*n)=g_spec;
end

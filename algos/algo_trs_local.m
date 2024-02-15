%local TRS algorithm for ppm initialization. 
%It solves a the static anchored synchronization problem localy, do not
%impose any smoothness.
%
%
%Input: A        -Data Matrix. Size nTxnT
%       T        -Number of time blocks.

%
%Output:g_trs_local -local TRS estimator. Size nTx1

function g_trs_local= algo_trs_local(A,T)
n = size(A,1)/T;
g_trs_local=zeros(n*T,1);
g_trs = subroutine_localTRS(A,n,T);%solve TRS for each block. Local synchronization stage.
%this to add a 1 as first coord. at each block and projects the rest onto
%SO(2).
for k = 1:T
     g_trs_local((k-1)*n+1:k*n) = [1;proj_C(g_trs((k-1)*(n-1)+1:k*(n-1)))];
end

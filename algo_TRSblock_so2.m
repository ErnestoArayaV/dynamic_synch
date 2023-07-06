%TRS block algorithm for SO2 dyn. synchro.
%Input: A                   -Data Matrix. Size n*Txn*T
%       T 
%       proj_small_eigs     -Projection low freq. matrix. Size (n-1)*Tx(n-1)*T
%Output:g_spec              -projected TRS block estimator. Size n*Tx1

function g_trs_b = algo_TRSblock_so2(A,T,proj_small_eigs)
n = size(A,1)/T;
g_trs_re = zeros((n-1)*T,1);
g_trs_co = zeros((n-1)*T,1);
for k=1:T
    A_tilde =A((k-1)*n+2:k*n,(k-1)*n+2:k*n); 
    b =  A((k-1)*n+2:k*n,(k-1)*n+1); 
    %transform complex data to real
    A_re = complextoreal(A_tilde);
    b_re = complextoreal(b);
    %apply TRS alg. 
    [g_trs,~] = TRSgep(-sparse(A_re),-2*b_re,speye(2*(n-1)),(n-1));
    g_trs_re((k-1)*(n-1)+1:k*(n-1)) = g_trs(1:(n-1));
    g_trs_co((k-1)*(n-1)+1:k*(n-1)) = g_trs(n:2*(n-1));
end

g_trs_b = [g_trs_re;g_trs_co];
g_trs_b = realtocomplex(g_trs_b);
g_trs_b = proj_small_eigs*g_trs_b;
%this to add a 1 as first coord. at each block 
g_aux = zeros(n*T,1);
for k = 1:T
     g_aux((k-1)*n+1:k*n) = [1;g_trs_b((k-1)*(n-1)+1:k*(n-1))];
end
g_trs_b = g_aux;
g_trs_b = proj_1(g_trs_b); %project to achieve unit norm




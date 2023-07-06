%TRS global algorithm for SO2 dyn. synchro.
%Input: A        -Data Matrix. Size n*Txn*T
%       T 
%       E        -Smoothness matrix. Size (n-1)*Tx(n-1)*T
%       lam_spec -regularization parameter
%Output:g_spec   -projected spectral estimator. Size n*Tx1
function g_trs=algo_TRSglobal_so2(A,E,T,lam_trs)
n = size(A,1)/T;
b = zeros((n-1)*T,1);
b(1:n-1) = A(2:n,1);
A_tilde = A(2:n,2:n);
for k=2:T
    A_tilde = blkdiag(A_tilde,A((k-1)*n+2:k*n,(k-1)*n+2:k*n)); %recursively construct the data matrix with first row/column for each block delted
    b((k-1)*n-(k-2):k*(n-1)) =  A((k-1)*n+2:k*n,(k-1)*n+1); %idem for b
end
%transform complex data to real
A_re = complextoreal(A_tilde-lam_trs*E);%this doubles de dimension
b_re = complextoreal(b);
%apply TRS alg. 
[g_trs,~] = TRSgep(-sparse(A_re),-2*b_re,speye(2*(n-1)*T),(n-1)*T);
%this to add a 1/0 as first coord. at each block (1 for 'real' part and 0 for 'complex' part)
g_aux = zeros(2*n*T,1);
for k = 1:2*T
    if k<=T
        g_aux((k-1)*n+1:k*n) = [1;g_trs((k-1)*(n-1)+1:k*(n-1))];%EA: I use 'real' because the alg can return something with small complex value. 
    else
        g_aux((k-1)*n+1:k*n) = [0;g_trs((k-1)*(n-1)+1:k*(n-1))];%I add 0 as the first coordinate of the 'complex' part
    end
end
g_trs = g_aux;
g_trs = realtocomplex(g_trs);
g_trs = proj_1(g_trs); %project to achieve unit norm




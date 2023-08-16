%subroutine for solving the local TRS for each block.

function g_tilde_hat = subroutine_localTRS(A,n,T)
g_tilde_hat = zeros((n-1)*T,1);
for k=1:T
    %form the 'tilde' decomposition of the data matrix A.
    A_tilde =A((k-1)*n+2:k*n,2:n);
    b =  A((k-1)*n+2:k*n,1); 
    %transform complex data to real.
    A_re = complextoreal(A_tilde);
    b_re = complextoreal(b);
    %apply TRS alg. 
    [g_trs,~] = TRSgep(-sparse(A_re),-2*b_re,speye(2*(n-1)),(n-1));
    g_trs_real= g_trs(1:(n-1));
    g_trs_comp = g_trs(n:2*(n-1));
    %back to complex.
    g_tilde_hat((k-1)*(n-1)+1:k*(n-1)) = complex(g_trs_real,g_trs_comp);
end

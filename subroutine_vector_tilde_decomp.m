%Subroutine that takes a vector x in nTx1 and removes the first element per
%block, and returns x_tilde of size (n-1)Tx1.

function x_tilde=subroutine_vector_tilde_decomp(x,n,T)
x_tilde = zeros((n-1)*T,1);
x_tilde(1:n-1) = x(2:n,1);
for k=2:T
    x_tilde((k-1)*n-(k-2):k*(n-1)) =  x((k-1)*n+2:k*n,1); 
end



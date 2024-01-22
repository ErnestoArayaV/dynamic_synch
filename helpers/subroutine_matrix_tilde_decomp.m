%subroutine that finds the 'tilde' decomposition for each nxn block of
%the data matrix A of size nTxnT, and construct a block diagonal matrix
%out of those blocks. EA: we can cite the paper here for the specific
%notation.
%
%Outputs: A_tilde_blk     -block diagonal matrix of size (n-1)Tx(n-1)T with
%                          A_tilde(k) in each block. 
%         b               -vector b in the paper. 

function [A_tilde_blk, b]=subroutine_matrix_tilde_decomp(A,n,T)
b = zeros((n-1)*T,1);%initialize the tall vector b
b(1:n-1) = A(2:n,1);%its first block
A_tilde_blk(1:n-1,1:n-1) = A(2:n,2:n);%the first tilde block
%recursively construct A_tilde_blk
for k=2:T
    A_tilde_blk = blkdiag(A_tilde_blk,A((k-1)*n+2:k*n,2:n)); 
    b((k-1)*n-(k-2):k*(n-1)) =  A((k-1)*n+2:k*n,1); 
end

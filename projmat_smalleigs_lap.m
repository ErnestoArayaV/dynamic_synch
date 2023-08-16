%auxiliary function to construct a low frequency projection matrix bases on
%the laplacian of the path graph. 
%
%Inputs:  T        -size of the path graph.
%         val      -number of small eigenvalues.
%         str      -a string. Can be either 'number' (select 'val' amount of eigenvalues)
%                             or 'bound' to select all the eigenvalues
%                             smaller that 'val'.
%Ouput: proj_mat = projection matrix of size TxT.

%TODO: find a way to use the eigs for the 'bound' option. EA: so far I'm
%using it in the main tests, but I don't know if we are going to have some
%results for this in the paper. 

function proj_mat= projmat_smalleigs_lap(T,val,str)
tol=0.000001;% the sigma parameter in the the 'eigs' function. EA: so far, it's hardcoded, but it can be received as an input. 
M = laplacian_path(T);
if strcmp(str,'number')
    [V,~] = eigs(M,val,tol);
    proj_mat = V*V';
elseif strcmp(str,'bound')
    [V,d] = eig(full(M),'vector');
    [~, ind] = sort(d);
    V = V(:, ind);
    num = sum(d<val);
    proj_mat = V(:,1:num)*V(:,1:num)';
end


    


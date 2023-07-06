%auxiliary function to construct a low frequency projection matrix bases on
%the laplacian of the path graph. Here size=T.
%
function proj_mat= projmat_smalleigs_lap(size,val,str)
M = laplacian_path(size);
[V,d] = eig(M,'vector');
[~, ind] = sort(d);
V = V(:, ind);
if strcmp(str,'number')
    proj_mat = V(:,1:val)*V(:,1:val)';
elseif strcmp(str,'bound')
    num = sum(d<val);
    proj_mat = V(:,1:num)*V(:,1:num)';
end

    


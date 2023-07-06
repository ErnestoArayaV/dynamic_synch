%proj_2 corresponds to the anchoring projection, which sets the first
%element of each block to 1
function proj=proj_2(g,T)
n = size(g,1)/T; % I assume size(g,1) is divisible by T.
aux = zeros(T,1);
%define an auxiliary vector which is contant on each block. Its value is the first
%coordinate element of the block.
for i=1:T
    aux(i)=g((i-1)*n+1);
end
aux = kron(conj(aux),ones(n,1)); 
proj = g.*aux; 
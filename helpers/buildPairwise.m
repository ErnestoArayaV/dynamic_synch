function H = buildPairwise(alphas,A)
% size(A)
% size(alphas)

% Input: set of angles alphas, and connectivity matrix A
% Output: H_{i,j} = alpha_i - alpha_j, whenever A_{ij} = 1 (and 0 otherwise)

n = length(alphas);
ctmtx = repmat(alphas,1,n);
offset = mod(ctmtx - ctmtx', 2*pi);
H = offset .* A;
end


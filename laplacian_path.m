%laplacian matrix for the path graph on T vertices
function lap=laplacian_path(size)
A = zeros(size,size);
D = zeros(size,size);
% Create adjacencies of path graphs with T and T+1 vertices respctively.
for i=1:size
    for j=1:size
  
        if abs(i-j) <= 1 && i ~= j
            A(i,j) = 1;
        end
    end
    D(i,i) = sum(A(i,:));
end

% Create Laplacians
lap = D - A;

%
%% Laplacian matrix for the path graph on T vertices
%

function lap=laplacian_path(T)
lap = toeplitz([2,-1,zeros(1,T-2)]);
lap(1,1)=1;
lap(T,T)=1;
lap =sparse(lap);

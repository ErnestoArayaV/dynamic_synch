
function [ W, G ]  = matrix_completion( W, G )

% save debug_matrix_completion W G
% qweqeqw



% colormap('jet'); imagesc(W); colorbar; axis tight; zzz
W = sparse(W .* G);
n = size(W,1);
G_onesDiag = G;
for i=1:n
    G_onesDiag(i,i)=1;
end

omega = find(G_onesDiag==1);
observations = W(omega);
mu           = .001;        % smoothing parameter

%% ? change to 1 to large problems (if it makes a difference for large n? How large n??)
opts.largeScale = 0;
opts.maxIts = 500;

p_est = nnz(G) / prod(size(G));

if  p_est > 0.9
    opts.maxIts = 50;
elseif p_est > 0.45
    opts.maxIts = 100;
else
    % opts.maxIts = 200;
    opts.maxIts = 100;
end

disp('opts.maxIts ')
disp(opts.maxIts);

Xk = solver_sNuclearBP( {n,n,omega}, observations, mu, [],[], opts );
W = Xk;
G = Gnp(n,1);

W = (W - W')/2;

% dif = sort(abs(max(W + W')))

% colormap jet
% subplot(1,2,1); imagesc(W);  colorbar;
% subplot(1,2,2); imagesc(Xk); colorbar;

% The relative error (without the rounding):
% fprintf('Relative error: %.8f%%\n', ...
%                norm(R_FULL-Xk,'fro')/norm(R_FULL,'fro')*100 );

% xxx
end



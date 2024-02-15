% rand_unif = rand((n-1)*T,1);
% g_star=exp(2*pi*rand_unif*complex(0,1));
% g_star=[ones(1,T),reshape(g_star,n-1,T)];
% g_star=g_star(:);
n=2;
rand_unif = rand(n,1);
g_star=exp(2*pi*rand_unif*complex(0,1));
g_star_sq=g_star*g_star';
T=10;
lap=laplacian_path(10);
[V,D] = eig(full(lap));
v1=V(:,1);
v6=V(:,6);
M1=kron(v1,g_star_sq);
M6=kron(v6,g_star_sq);
% 
% M1=v1*v1';
% M6=v6*v6';
G_star=M6;
DG_star=.5*M1+.5*M6;
d=sign(v6);
D=kron(d,eye(n));
DD=[];
for k=1:T
DD=blkdiag(DD,D((k-1)*n+1:k*n,1:n));
end
D_times_G_star=DD*G_star;

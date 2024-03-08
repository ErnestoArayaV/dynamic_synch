%generate ground truth signal close to the 'low frequency' space given by
% the psd matrix 'proj_mat'.

%Input:        n,T      - number of elements, number of blocks (resp)
%              proj_mat - psd matrix of size TXT, used to define a 'low frequency' space. See
%                         projmat_smalleigs_lap.m
%Output:       gt       -'low frenquency' ground truth vector. Size nTx1

function gt = generate_ground_truth(n,T,ST)

% kronLapl = kron(laplacian_path(T), speye(n-1));

num_small_eigs = min(floor(1 + sqrt(T*ST)),T); % map ST to the number of 
proj_mat = projmat_smalleigs_lap(T, num_small_eigs, 'number');

P_tau_n1 = kron(proj_mat,speye(n-1));
rand_std_gauss = randn((n-1)*T,1);% create a vector of random standard gaussians 
ft = P_tau_n1*rand_std_gauss; % project it onto the 'low frequency' space defined by 'proj_mat'

ft = sqrt(T)*(ft/norm(ft,2)); % scale ft to have l2 norm sqrt(T)
gt = exp(0.5*pi*ft*complex(0,1)); % map it to the manifold

% ft'*(kronLapl)*ft
% gt'*(kronLapl)*gt

gt=reshape(gt, n-1,T);
gt=[ones(1,T);gt];
gt=gt(:);



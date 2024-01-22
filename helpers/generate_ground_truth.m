%generate ground truth signal close to the 'low frequency' space given by
% the psd matrix 'proj_mat'.

%Input:        n,T      - number of elements, number of blocks (resp)
%              proj_mat - psd matrix of size TXT, used to define a 'low frequency' space. See
%                         projmat_smalleigs_lap.m
%Output:       gt       -'low frenquency' ground truth vector. Size nTx1

function gt = generate_ground_truth(n,T,proj_mat)
P_tau_n1 = kron(proj_mat,speye(n-1));
rand_unif = rand((n-1)*T,1);% create a vector of random uniform numbers
gt =P_tau_n1*rand_unif; % project it onto the 'low frequency' space defined by 'proj_mat'
gt = exp(pi*gt*complex(0,1)); % map it to the manifold
gt=reshape(gt, n-1,T);
gt=[ones(1,T);gt];
gt=gt(:);



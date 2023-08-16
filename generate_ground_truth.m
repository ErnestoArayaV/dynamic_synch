%generate ground truth signal close to the low frequency space given by
% the psd matrix proj_mat.

%Input:        n,T      - number of elements, number of blocks (resp)
%              proj_mat - psd matrix of size TXT, used to define a 'low frequency' space. See
%                         projmat_smalleigs_lap.m
%Output:       gt       -'low frenquency' ground truth vector. Size nTx1

function gt = generate_ground_truth(n,T,proj_mat)
P_tau_n = kron(proj_mat,speye(n));
rand_angles = 2*pi*rand(n*T,1);
gt = exp(rand_angles*complex(0,1));
gt = P_tau_n*gt;
gt = proj_C(gt);% projection onto SO(2)
gt = proj_2(gt,T);%anchoring


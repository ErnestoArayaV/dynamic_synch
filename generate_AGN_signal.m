%Signal plus noise (complex spike Wigner) generative model. 
%Input:           gt    -Ground truth vector with entries in the complex
%                        circle. Size n*Tx1
%                 T     -Size of the path Laplacian. Also number of blocks.
%                 sigma -Noise level
%Output: signal         =gt * gt^h + sigma* Noise
function signal = generate_AGN_signal(gt,T,sigma)
n = size(gt,1)/T;
signal=zeros(n*T,n*T);
for k=1:T
    W = (1/sqrt(2))*complex(randn(n,n),randn(n,n)); %noise matrix with complex Wigner law
    signal((k-1)*n+1:k*n,(k-1)*n+1:k*n)=gt((k-1)*n+1:k*n)*gt((k-1)*n+1:k*n)'+sigma*W;
end

    
%script to test dyn. synchr. methods.
%EA: I use the correlation(inner product) between estimator and the gt as
%the error measure. 
%%TODO:          - how 'lam' depends on T should be revised (issues with higher noise)
%                - for better scalability: precompute smoothness matrices, store them in a file and only load them here.
%                - how to choose 'lam' and 'tau' in practice (cross val., etc)
%                - define other generative/noise models.

n = 20;%number of nodes of each comparison graph
T = [10,30,50];%[10,30,50,70,100];%25:25:100; number of time blocks
noise = 0:0.05:0.1;%additive noise level for the spiked Wigner model
beta_reg = 2/3;%parameter for regularization as T^beta_reg. see definition of 'lam'
ST=1./T; %smoothness parameters initialiation
num_small_eigs = ceil((1/n)*(T+n+ST.*((T+1)/(n*pi-pi)).^(2/3))); %smoothness in terms of number of 'low freq.' eigs. I used Transync paper rule. To be revised.
num_noiseins = length(noise); 
num_timeblocks = length(T);
num_iter_ppm = 10;%number of ppm iterations. Arbitrary for the moment, should be O(log nT) when n, T are large?
num_runs = 15;%number of Monte Carlo runs. 
corr_spectral = zeros(num_timeblocks,num_noiseins,num_runs);%initialize the spectral correlation vector
corr_ppm = zeros(num_timeblocks,num_noiseins,num_runs);%initialize the ppm correlation
corr_trs_gl = zeros(num_timeblocks,num_noiseins,num_runs);%initialize the trs correlation
corr_trs_b = zeros(num_timeblocks,num_noiseins,num_runs);%initialize the trs_block correlation
corr_denproj = zeros(num_timeblocks,num_noiseins,num_runs);%initialize the denoise 'n' project correlation

proj_mats = cell(num_timeblocks,1);%this defines the smoothing projection matrices to generate data. Each element of the cell array is a TxT matrix.
for t=1:num_timeblocks
    proj_mats{t} = projmat_smalleigs_lap(T(t),num_small_eigs(t),'number');
end
%% run each algorithm in a Montecarlo loop
tic
for i1=1:num_timeblocks
    %smoothness matrices. 
    %%TODO: this matrices can be precomputed outside and load them here.
    M = laplacian_path(T(i1));
    E_n = kron(M,speye(n));
    E_n1 = kron(M,speye(n-1));
    for i2 = 1:num_noiseins
        %define regularization parameters (depend on T,ST and noise)
        lam = ((T(i1)/ST(i1)).^beta_reg)*(noise(i2)^(4/3));
        tau = ((T(i1)/ST(i1)).^beta_reg)*(noise(i2)^(-4/3))/n;
        %projection matrices onto the 'low freq.'space
        V_tau =  projmat_smalleigs_lap(T(i1),tau,'bound');
        P_tau_n = kron(V_tau, speye(n));
        P_tau_n1 = kron(V_tau, speye(n-1));
        for i3 = 1:num_runs
            if mod(i3,5) == 0 %to print some info while running
                fprintf('noise = %i, montecarlo = %i, T=%i \n',[noise(i2),i3, T(i1)]);
            end
            %generate data
            gt = generate_ground_truth(n,T(i1),proj_mats{i1});
            sig = generate_AGN_signal(gt,T(i1),noise(i2));
            %spectral 
            g_init = algo_spectral_so2(sig,E_n,T(i1),lam);
            corr_spectral(i1,i2,i3) = abs(dot(g_init,gt))/(n*T(i1));
            %ppm 
            g_ppm = algo_ppm_so2(sig,E_n,T(i1),g_init,lam,num_iter_ppm);
            corr_ppm(i1,i2,i3) = abs(dot(g_ppm,gt))/(n*T(i1));
            %trs global
            g_trs = algo_TRSglobal_so2(sig,E_n1,T(i1),lam);
            corr_trs_gl(i1,i2,i3) =  abs(dot(g_trs, gt))/(n*T(i1));
            %trs block
            g_trs_b = algo_TRSblock_so2(sig,T(i1),P_tau_n1);
            corr_trs_b(i1,i2,i3) =  abs(dot(g_trs_b, gt))/(n*T(i1));
            %denoise/project
            g_denproj = algo_denoiseNproject_so2(sig,T(i1),P_tau_n);
            corr_denproj(i1,i2,i3) =  abs(dot(g_denproj, gt))/(n*T(i1));
        end
    end
end
%average correlation/recovery over Montecarlo runs
mean_corr_spec = mean(corr_spectral,3);
mean_corr_ppm = mean(corr_ppm,3);
mean_corr_trs = mean(corr_trs_gl,3);
mean_corr_trs_b = mean(corr_trs_b,3);
mean_corr_denproj = mean(corr_denproj,3);
toc
%% plot if necessary
%figure in the noiseless case (uncomment to plot)
%  figure;
%  plot(T,mean_corr_spec(:,1),'-o','Color','blue');
%  hold on;
%  plot(T,mean_corr_ppm(:,1),'-*','Color','red');
%  xlabel('T','FontSize',15);
%  ylabel('Average Correlation with gt','FontSize',13);
%  legend('spectral','spectral+ppm');
%  set(gca,'linewidth',2);
%  title('Noiseless case')
%figure for choosen noise level(uncomment to plot)
%  plot_noise = 5; %index for the noise level to plot
%  figure;
%  plot(T,mean_corr_spec(:,plot_noise),'-o','Color','blue');
%  hold on;
%  plot(T,mean_corr_ppm(:,plot_noise),'-*','Color','red');
%  xlabel('T','FontSize',15);
%  ylabel('Average Correlation with gt','FontSize',13);
%  legend('spectral','spectral+ppm');
%  set(gca,'linewidth',2);
%  title(['Noise level = ',num2str(noise(plot_noise))])
%% sanity checks
%EA: a couple of test I believe our experiments should pass.
%test1 counts the proportion of instances (T,noise_level) where ppm improves over
%spectral (Montecarlo averages considered).
test1 = sum(sum(mean_corr_ppm>mean_corr_spec))/(size(mean_corr_ppm,1)*size(mean_corr_ppm,2));
%test2 counts the proportion of instances (T,noise_level) where a larger value of T
%improves the results in ppm. Choose t1>t2!
t1 = 1;t2 = 2;
test2_ppm = sum(sum(mean_corr_ppm(t1,:)>mean_corr_ppm(t2,:)))/length(mean_corr_ppm(t1,:));
%EA: if those test are small, for me it is an indication that 'lam' should
%be choosen differently (except maybe in the 'high noise' regime. To be precised.). 

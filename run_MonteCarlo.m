
 % run_MonteCarlo(30, 10, 'wigner', 0.10, 1, 20 )

 % run_MonteCarlo(30, 10, 'wigner', 0.10, 1, 3 )

function [avg_metrics , std_metrics] = run_MonteCarlo(n, T, noise_model, noise, p, nr_runs)
rng(0);

randseedoffset = random('unid', 10^5) + 1;

% nr_runs = 20

% run_instance(30, 10, 'wigner', 0.10)
disp([ 'nr_runs=', int2str(nr_runs) ] ); 

parfor i = 1:nr_runs
    rng(randseedoffset+i, 'twister');
    MTX_metrics(:,:,i) = run_instance(n, T, noise_model, noise, p);
end

noise

MTX_metrics;

avg_metrics = mean(MTX_metrics, 3 )

std_metrics = std(MTX_metrics, 0, 3 );

save results_MTX_metrics 

size(results_MTX_metrics)


end


function [] = test_parfor_is_working()

tic
n = 30;
A = 500;
a = zeros(1,n);
for i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
toc


tic
a = zeros(1,n);
parfor i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
toc

zzzz

end


 % run_MonteCarlo(30, 10, 'wigner', 0.10, 1, 20 )
 %
 % run_MonteCarlo(30, 10, 'wigner', 0.10, 1, 3, 4 )

function [avg_metrics , std_metrics] = run_MonteCarlo(n, T, noise_model, noise, p, scan_ID, nrExp)

randseedoffset = randi(10^5) + 1;

disp([ 'nrExp=', int2str(nrExp) ] ); 

parfor i = 1:nrExp
    rng(randseedoffset+i, 'twister');
    MTX_metrics(:,:,i) = run_instance(n, T, noise_model, noise, p, scan_ID);
end

avg_metrics = mean(MTX_metrics,  3 );
std_metrics = std(MTX_metrics, 0, 3 );
% save results_MTX_metrics 

size(avg_metrics); % 7 by 5
size(std_metrics); % 7 by 5

disp('------------------------------->>>   Average:  <<<------------------------------- ')
disp_nice_metrics(avg_metrics);
disp('------------------------------->>>   Stdev:    <<<------------------------------- ')
disp_nice_metrics(std_metrics);
disp([' ------>>   n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel=' num2str(noise) '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)  ' ; nrExp=' int2str(nrExp)]);

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

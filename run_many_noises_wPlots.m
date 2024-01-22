 % run_many_noises_wPlots(30, 10, 'wigner', 10)

% run_many_noises_wPlots(100, 20, 'wigner', 20)

%  todo: outer wrapper varying T, and calling run_many_noises_wPlots() ..
%  build a 4tensor, and slice/dice as wanted: eg, for a fixed noise level,
%  show perf_metric across T.

% separate extraction + plotting functionality for the above. + Heatmaps
% T = 10:10:100

% Also vary smoothness 

% add checker on the connectivity of the union graph

% outliers model: 


function [ ] = run_many_noises_wPlots(n, T, noise_model, nr_runs)
disp('----> Start of run_many_noises_wPlots() <------');
addpath(genpath('helpers'));
addpath(genpath('algos'));

if strcmp(noise_model,'wigner') == 1
    noises = 0: 5: 50;
elseif strcmp(noise_model,'OutliersER') == 1     ||  strcmp( tipNoise, 'ERO') == 1
    noises = 0 : 5 : 95;  noises = noises / 100;
end
noises

scan_ID = 1;  % create a folder for each experimental setup.

label_orig = [ noise_model ': n=' int2str(n) ', T=' int2str(T), ' (' int2str(nr_runs ) ')'];
label = [ noise_model '_n' int2str(n) '_T' int2str(T) '_nrExp' int2str(nr_runs)];
% label = regexprep(label, '\.', 'p');  % disp(label);
disp(label);
fsData     = [ 'DATA/DATA_'   int2str(scan_ID) '/' label ];           disp(fsData);
plotFolder = [ 'PLOTS/PLOTS_' int2str(scan_ID) '/' label ]; disp(plotFolder);



doWork = 1      % = 0 skip (preload from file);  =1 do the work
allow_preload = 1;
MANY_AVG=[];  MANY_STD=[];

if doWork == 1 
    if allow_preload ==1  && exist(fsData, 'file');
        disp('Allow_preload = 1  and file exists! Just pre-load!');
        load(fsData);
    else
        disp('Allow_preload = 0 or file does not exist. Do work:');
        i=0;
        tic
        for noise = noises
            i = i+1;  disp(noise);
            [avg_metrics , std_metrics] = run_MonteCarlo(n, T, noise_model, noise, nr_runs);
            MANY_AVG(:,:,i) = avg_metrics;
            MANY_STD(:,:,i) = std_metrics;
        end
        noises
        toc
        save(fsData,'MANY_AVG','MANY_STD','n','T','noise_model','noises','nr_runs');
    end
else
    try
        load(fsData);
    catch ME;
        disp(['File not found : '  fsData ] );
    end
end

MANY_AVG   % metrics x algos x noises
MANY_STD;
fsData


plot_nice(MANY_AVG, MANY_STD, plotFolder, label_orig, scan_ID, noises)

disp('----> End of run_many_noises_wPlots() <------');
end


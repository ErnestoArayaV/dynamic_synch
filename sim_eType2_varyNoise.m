%%  eType_2:  fix n, T, noise_model, p, scan_ID, (and nrExp).  Vary noise

%% Run_1: sim_eType2_varyNoise(30, 10, 'wigner', 1, 1, 50)

%% Run_2: sim_eType2_varyNoise(30, 50, 'wigner', 1, 1, 50)



% sim_eType2_varyNoise(30, 10, 'wigner', 1, 1, 3)
% sim_eType2_varyNoise(100, 20, 'wigner', 20)

% separate extraction + plotting functionality for the above. + Heatmaps
% T = 10:10:100

% old name:  run_many_noises_wPlots
function [ ] =  sim_eType2_varyNoise(n, T, noise_model, p, scan_ID, nrExp)
disp('----> Start of sim_eType2_varyNoise() <------');
addpath(genpath('helpers'));
addpath(genpath('algos'));
close("all"); 

if strcmp(noise_model,'wigner') == 1
    if n <= 30 && T<=50 && p==1 && scan_ID ==1 
        noises = 0: 0.5: 15  
        input('see noises...');
    end
elseif strcmp(noise_model,'OutliersER') == 1  ||  strcmp( tipNoise, 'ERO') == 1
    noises = 0 : 5 : 95;  noises = noises / 100;
end
noises

% scan_ID = 1;  % create a folder for each experimental setup (smoothness level)

label_nice = [ 'siD' int2str(scan_ID) ': ' noise_model ': n=' int2str(n) ', T=' int2str(T), ', p=' num2str(p) ' (nrExp=' int2str(nrExp ) ')'];
label      = [ 'scan_ID' int2str(scan_ID) '_'  noise_model  '_n' int2str(n)   '_T'  int2str(T)   '_p' num2str(p) '_nrExp' int2str(nrExp) ];

% label = regexprep(label, '\.', 'p');  % disp(label);
disp(label);
fsData  = [ 'DATA/DATA_'   int2str(scan_ID) '/' label ];     disp(fsData);
fsPlots = [ 'PLOTS/PLOTS_' int2str(scan_ID) '/' label ];     disp(fsPlots);

doWork = 0      % = 0 skip (preload from file);  =1 do the work
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
            [avg_metrics , std_metrics] = run_MonteCarlo(n, T, noise_model, noise, p, scan_ID, nrExp);
            MANY_AVG(:,:,i) = avg_metrics;
            MANY_STD(:,:,i) = std_metrics;
        end
        noises
        toc
        save(fsData, 'MANY_AVG', 'MANY_STD','n','T','noise_model','noises', 'p', 'scan_ID', 'nrExp');
        disp(['Saved all data to file: '  fsData ] );
    end
else
    try
        load(fsData);
    catch ME;
        disp(['File not found : '  fsData ] );
    end
end

%% metrics x algos x noises   (AVG):
MANY_AVG   

%% metrics x algos x noises   (STD):
MANY_STD;


%% Individual plots
plot_individual_figs = 1;
if plot_individual_figs == 1
    indivPlotBool = 1;
    for indMetric=1:7
        plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, noises, '\gamma noise level', indivPlotBool)
    end
end



%% Multi-plot figure:
plot_big_picture = 1;
if  plot_big_picture == 1
    indivPlotBool = 0;
    figure(8)
    for indMetric=1:7
        subplot(2,4, indMetric);
        plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, noises, '\gamma noise level', indivPlotBool)
    end
end

disp([' ------>>   n=' int2str(n) ' ; T=' int2str(T) '; noiseModel=' noise_model ...
    '; noiseLevel VARY'  '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)  ' ; nrExp=' int2str(nrExp)]);

disp('----> End of sim_eType2_varyNoise() <------');
end


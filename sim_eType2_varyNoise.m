%%  eType_2:  fix n, T, noise_model, p, scan_ID, (and nrExp).  Vary noise

%% Run_1: sim_eType2_varyNoise(30, 10, 'wigner', 1, 1, 50)
%% Run_2: sim_eType2_varyNoise(30, 50, 'wigner', 1, 1, 50)

% separate extraction + plotting functionality for the above. + Heatmaps

function [ ] =  sim_eType2_varyNoise(n, T, noise_model, p, scan_ID, nrExp)
disp('----> Start of sim_eType2_varyNoise() <------');
addpath(genpath('helpers'));
addpath(genpath('algos'));
close("all"); 

% Grid of noise values depending on the noise model
if strcmp(noise_model,'wigner') == 1
        noises = 0:1:10;  

elseif strcmp(noise_model,'outlier') == 1 
    noises = [0 : .05 : .5 0.6 0.7 0.8];  

else
    disp('Incorrect noise model...')
    return;
end

% labels for titles within figures, and filenames
label_nice = [ 'siD' int2str(scan_ID) ': ' noise_model ': n=' int2str(n) ', T=' int2str(T), ', p=' num2str(p) ' (nrExp=' int2str(nrExp ) ')'];
label      = [ 'scan_ID' int2str(scan_ID) '_'  noise_model  '_n' int2str(n)   '_T'  int2str(T)   '_p' num2str(p) '_nrExp' int2str(nrExp) ];

disp(label);
fsData  = [ 'DATA/DATA_'   int2str(scan_ID) '/' label ];     disp(fsData);
fsPlots = [ 'PLOTS/PLOTS_' int2str(scan_ID) '/' label ];     disp(fsPlots);

doWork = 1;      % = 0 skip (preload from file);  =1 do the work
allow_preload = 1;
MANY_AVG=[];  MANY_STD=[];

if doWork == 1 
    if allow_preload ==1  && exist(fsData, 'file')
        disp('Allow_preload = 1  and file exists! Just pre-load!');
        load(fsData);
    else
        disp('Allow_preload = 0 or file does not exist. Do work:');
        i=0;
        tic
        rng(0, 'twister'); % Initialize seed to 0 
        
        for noise = noises
            i = i+1;  disp(noise);
            
            % Performance of each algorithm (RMSE, correlation etc) computed for the optimal 
            % reg. parameter.
            
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
plot_big_picture = 0;
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


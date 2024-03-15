%%  eType1:  fix n, noise, noise_model, p, scan_ID, (and nrExp).  Vary T

%% Run_1:   sim_eType1_varyT(30, 'wigner', 10,  1,  1, 3)  
%% Run_2:   sim_eType1_varyT(30, 'wigner', 10,  1,  1, 3)  
%% Run_3:   sim_eType1_varyT(30, 'wigner', 2,   1,  1, 3);


% sim_eType1_varyT(30, 'wigner', 10,  1,  1,  3)

function [ ] =  sim_eType1_varyT(n, noise_model, noise, p, scan_ID, nrExp)
disp('----> Start of sim_eType1_varyT() <------');
addpath(genpath('helpers'));
addpath(genpath('algos'));

if strcmp(noise_model,'wigner') == 1
   %% Run_1: T_vect = 10:5:50;
   %% Run_2:
    T_vect = 10:10:100;
elseif strcmp(noise_model,'OutliersER') == 1  ||  strcmp( tipNoise, 'ERO') == 1
    % to set 
end
T_vect

% scan_ID = 1;  % create a folder for each experimental setup (smoothness level)

label_nice = [ 'siD' int2str(scan_ID) ': ' noise_model ': n=' int2str(n) ', noise=' int2str(noise), ', p=' num2str(p) ' (nrExp=' int2str(nrExp ) ')'];
label      = [ 'scan_ID' int2str(scan_ID) '_'  noise_model  '_n' int2str(n)   '_noise'  num2str(noise)   '_p' num2str(p) '_nrExp' int2str(nrExp) ];

% label = regexprep(label, '\.', 'p');  % disp(label);
disp(label);
fsData     = [ 'DATA/DATA_'   int2str(scan_ID) '/' label ];     disp(fsData);
fsPlots = [ 'PLOTS/PLOTS_' int2str(scan_ID) '/' label ];     disp(fsPlots);


doWork = 1;       % = 0 skip (preload from file);  =1 do the work
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
        for iT = T_vect
            i = i+1;  disp(iT);
            [avg_metrics , std_metrics] = run_MonteCarlo(n, iT, noise_model, noise, p, scan_ID, nrExp);
            MANY_AVG(:,:,i) = avg_metrics;
            MANY_STD(:,:,i) = std_metrics;
        end
   
        toc
        save(fsData, 'MANY_AVG', 'MANY_STD','n','T_vect','noise_model','noise', 'p', 'scan_ID', 'nrExp');
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
        plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, T_vect, 'T (time)', indivPlotBool)
    end
end


%% Multi-plot figure:
plot_big_picture = 1;
if  plot_big_picture == 1
    indivPlotBool = 0;
    figure(8)
    for indMetric=1:7
        subplot(2,4, indMetric);
        plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, T_vect, 'T (time)', indivPlotBool)
    end
end


disp([' ------>>   n=' int2str(n) ' ; T = ---VARY--- ;  noiseModel=' noise_model ...
    '; noise' num2str(noise)  '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)  ' ; nrExp=' int2str(nrExp)]);

disp('----> End of sim_eType1_varyT() <------');
end





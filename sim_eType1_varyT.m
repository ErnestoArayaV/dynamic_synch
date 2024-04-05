%-------------------------------------------------------------------------------------------
%%  eType1:  fix n, noise, noise_model, p, scan_ID, (and nrExp).  Vary T
%
%% Inputs:
% n : size of the graph at each time point
% noise: sigma for Wigner model and 1 - eta for outliers model 
% noise_model: {Wigner, outlier} 
% p: Graph sparsity (it should be 1 in Wigner model)
% scan_ID: 1,2 and 3 (set Quadratic smoothness of the ground truth). E.g., scan_ID = 1
% means ST = 1/T, see the code for other values.
%
%% Description: 
% Performance of each algorithm (RMSE, correlation etc) calculated for different values of T. 
% The results are averaged over nrExp MC runs. In each MC run, we find the optimal 
% reg. parameter (lambda or tau) by searching over a grid, and choosing the grid point by 
% a Data Fidelity criterion.
%
%% Output: 
%
% The .mat file is saved in the DATA_{scan_Id} folder. The plots are saved
% in the PLOTS_{scanId} folder.
%
%% Example
%
%% Run_1:   sim_eType1_varyT(30, 'wigner', 3,  1,  1, 25)  
%% Run_2:   sim_eType1_varyT(30, 'wigner', 3,  1,  2, 25)   
%% Run_3:   sim_eType1_varyT(30, 'outlier', 0.2, 0.2, 1, 25);
%
%------------------------------------------------------------------------------------------

function [ ] =  sim_eType1_varyT(n, noise_model, noise, p, scan_ID, nrExp)


disp('----> Start of sim_eType1_varyT() <------');
addpath(genpath('helpers'));
addpath(genpath('algos'));

% Grid of time points
T_vect = 10:10:100; 

%% set to 0 if we want to disable any single algo
ALGO.run_spectral = 1;
ALGO.run_ppm = 0;
ALGO.run_GTRS = 1;       
ALGO.run_LTRS_GS = 1;  
ALGO.run_LTRS_GMD = 1;  

%% Set PPM related parameters
if ALGO.run_ppm == 1
   
   %% Set scale for lambda for PPM
   ALGO.lam_ppm_scale = 1;
   
   %% number of ppm iterations. 
    ALGO.num_iter_ppm = 10; 

    %% PPM initializer -- set to 'SPEC', 'GTRS', 'LTRS-GS', 'LTRS-GMD'
    ALGO.ppm_initializer = 'LTRS-GS';
end

%% Set scale for lambda for GTRS 
if ALGO.run_GTRS == 1 
   ALGO.lam_gtrs_scale = 10;
end

%-----------------------------------

% labels for titles within figures, and filenames
label_nice = [ 'siD' int2str(scan_ID) ': ' noise_model ': n=' int2str(n) ', noise=' num2str(noise), ', p=' num2str(p) ' (nrExp=' int2str(nrExp ) ')'];
label      = [ 'scan_ID' int2str(scan_ID) '_'  noise_model  '_n' int2str(n)   '_noise'  num2str(noise)   '_p' num2str(p) '_nrExp' int2str(nrExp) ];

disp(label);
fsData     = [ 'DATA/DATA_'   int2str(scan_ID) '/' label ];     disp(fsData);
fsPlots = [ 'PLOTS/PLOTS_' int2str(scan_ID) '/' label ];     disp(fsPlots);


doWork = 1;       % = 0 means skip (preload from file);  = 1 means do the work
allow_preload = 0;
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
        
        for iT = T_vect
            i = i+1;  disp(iT);
            
            % Performance of each algorithm (RMSE, correlation etc) computed for the optimal 
            % reg. parameter.
            [avg_metrics , std_metrics] = run_MonteCarlo(n, iT, noise_model, noise, p, scan_ID, nrExp, ALGO);
            MANY_AVG(:,:,i) = avg_metrics;
            MANY_STD(:,:,i) = std_metrics;
        end
   
        toc
        save(fsData, 'MANY_AVG', 'MANY_STD','n','T_vect','noise_model','noise', 'p', 'scan_ID', 'nrExp', 'ALGO');
        disp(['Saved all data to file: '  fsData ] ); 
    end
else
    try
        load(fsData);
    catch ME;
        disp(['File not found : '  fsData ] );
    end
end

%% metrics x algos x varying-parameter (T, noise level etc.)   (AVG):
MANY_AVG   

%% metrics x algos x varying-parameter (T, noise level etc.)   (STD):
MANY_STD;

%% Individual plots
plot_individual_figs = 1;
plot_error_bars = 0; % 0/1 for plotting error bars

if plot_individual_figs == 1
    indivPlotBool = 1;
    for indMetric=1:7
        plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, T_vect, 'T (time)', indivPlotBool, plot_error_bars, ALGO)
    end
end


%% Multi-plot figure:
plot_big_picture = 0;
plot_error_bars = 0; % 0/1 for plotting error bars

if  plot_big_picture == 1
    indivPlotBool = 0;
    figure(8)
    for indMetric=1:7
        subplot(2,4, indMetric);
        plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, T_vect, 'T (time)', indivPlotBool, plot_error_bars, ALGO)
    end
end


disp([' ------>>   n=' int2str(n) ' ; T = ---VARY--- ;  noiseModel=' noise_model ...
    '; noise' num2str(noise)  '; p=' num2str(p) '; scan_ID =' num2str(scan_ID)  ' ; nrExp=' int2str(nrExp)]);

disp('----> End of sim_eType1_varyT() <------');
end





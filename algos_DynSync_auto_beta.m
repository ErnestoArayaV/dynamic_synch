%-----------------------------------------------------------------------------------------------------
% algos_DynSync_auto_beta(data, gt, PARS)
%
%% Inputs:
% data: nT x N data matrix
% gt: nT x 1 vector of smooth ground truth signal
% PARS: main structure for storing simulation related data
%
%% Description: 
% for each algorithm, do a grid search over the respective regularization 
% parameters (lambda, tau etc) and select the best parameter value via a
% data fidelity criteria in the `stats_best_beta_by_algo ()' subroutine.
% 
%% Output:
% metrics75mtx: 7 x 5 matrix where first 6 rows are performance metrics (6 currently), and 
% last row contains optimal beta. 
% Each column corresponds to an algorithm (5 in total currently). 
% This matrix is computed for the best reg. parameter (via data fidelity criterion) for each algorithm
%
% Columns of metrics75mtx are in order: 
% [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd];
%
% Rows of metrics75mtx are ordered as: 
% [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT; optimal beta (via DataFi)]
%--------------------------------------------------------------------------------------------------------

function [ metrics75mtx ] = algos_DynSync_auto_beta(data, gt, PARS)

disp_metrics_flag = 0;  % turn on/off verbose.

% choice of the grid for searching for best reg. param (both lambda and
% tau)
beta_list = unique([0:1:floor(PARS.T^(1/2)) floor(linspace(floor(PARS.T^(1/2)),floor(PARS.T^(2/3)),5)) floor(linspace(floor(PARS.T^(2/3)), PARS.T, 5))]); 

i = 0; % initialize counter for grid

for beta_reg = beta_list
    i=i+1;
    disp([ 'beta_reg=' num2str(beta_reg) ]);
    
    %
    % For a candidate beta, run each algorithm (output is a Nr metrics x Nr algorithms matrix, 
    % each column corresponding to an algorithm)
    %
    % Currently, number of metrics = 6 and number of algorithms = 5.
    % metrics = [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ].
    % Rows of metrics are ordered as [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT ]
    %
    [ metrics ] = algos_DynSync_given_beta(beta_reg, data, gt, PARS);
    
    % Display performance metrics for each algorithm for the current beta
    if disp_metrics_flag == 1
        disp_nice_metrics(metrics);
    end
    
    %
    % Store the 6 x 5 performance matrix for the algorithms for the ith candidate
    % value of beta
    MTX_metrics(:,:,i) = metrics; 
end

%---------------------------------------------------------------------------------------
% Plot the performance metrics {correlation, rmse, data fidelity, smoothness} vs beta
% for each algorithm
%----------------------------------------------------------------------------------------

figure(1);  clf;  

% Plot correlation versus beta for each algorithm
corrMtx = squeeze(MTX_metrics(1, : , :))';
subplot(2,2,1);
plot_nice_auto_beta(corrMtx, '', 1, '', beta_list, PARS);

% Plot RMSE versus beta for each algorithm
subplot(2,2,2);
rmseMtx = squeeze(MTX_metrics(2, : , :))';
plot_nice_auto_beta(rmseMtx, '', 2 , '', beta_list, PARS);

% Plot data fidelity versus beta for each algorithm
subplot(2,2,3);
dafiMtx = squeeze(MTX_metrics(5, : , :))';
plot_nice_auto_beta(dafiMtx, '', 5 , '', beta_list, PARS);

% Plot smoothness of solution versus beta for each algorithm
subplot(2,2,4);
smotMtx = squeeze(MTX_metrics(6, : , :))';
plot_nice_auto_beta(smotMtx, '', 6 , '', beta_list, PARS);

%
% Return the performance metrics corresponding to the optimal beta for each
% algorithm. Size of metrics75mtx is (Nr. of metrics + 1) x Nr. of methods
% with the last row of metrics75mtx containing the optimal beta for each
% algorithm.
%
% Columns of metrics75mtx are in order: 
% [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ];
%
% Rows of metrics75mtx are ordered as: 
% [corr ; RMSE; corrKend; perc_flips; DAFI; SMOT; optimal beta (via DataFi)]
%
metrics75mtx = stats_best_beta_by_algo(MTX_metrics , beta_list);

end



%-----------------------------------------------------------------------------------------------------
% plot_nice_auto_beta(MTX2D, plotFolder, indStat , scan_ID, beta_list, PARS)
%
%% Inputs:
% scan_ID: this is not being used ?? Note that this corresponds to the type
% of smoothness (see run_instance.m file)
% beta_list: list of betas on the grid
% PARS: main structure for storing simulation related data
% indStat: index of the metric (1 - 6 currently, see inside code for details)
% plotFolder: path of folder where plot will be dumped
% MTX2D: Nr. of beta x Nr. of algorithms matrix. Each column contains
% the performance output for an algorithm for some metric.
%
%% Output
%
% For each algorithm, plot the performance metric output versus beta
%
%% Remark (HT): This function needs cleaning!!

function plot_nice_auto_beta(MTX2D, plotFolder, indStat , scan_ID, beta_list, PARS)

showtitle = 1;
log_scale = 0;
extraDesc = '';
% indStat = 1;
% figure(indStat); clf; 

label_orig = [ PARS.noise_model ': n=' int2str(PARS.n) ', T=' int2str(PARS.T), ];

PARS.myFont = 20; % 32;
PARS.myFontLegend = 20; % 32;
size(MTX2D) %  methods x noises (betas)

if     indStat == 1    
    ylab = 'Correlation Score';        fsStat = 'Corr';
elseif indStat == 2
    ylab = 'RMSE';                     fsStat = 'RMSE';
elseif indStat == 3
    ylab = 'Kendall Distance';         fsStat = 'Kendall';
elseif indStat == 4
    ylab = 'Percentage Upsets';        fsStat = 'Upsets';    
elseif indStat == 5
    ylab = 'Data Fidelity (DaFi)';     fsStat = 'DaFi';         
elseif indStat == 6
    ylab = 'Smoothness Term ';         fsStat = 'Smoothness';         
end

label_orig_tit = [ ylab ' --- ' label_orig];

% metodeIndex = [ 1 2 3 4 5];    % which methods to retain for plotting
metodeIndex = find([PARS.run_spectral PARS.run_ppm PARS.run_GTRS PARS.run_LTRS_GS  PARS.run_LTRS_GMD]);

% ALL % betas by algos
ALL = [beta_list' MTX2D];

% Recall the ordering from algos
%  metrics = [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ];

legList = {'Spectral', 'PPM',    'GTRS',    'LTRS-GS',    'LTRS-GMD' };
colMethods = {  '-g.', '-r.',  '-m.',  '-c.', '-b.'};  %,  '-m.' ,  '-k.'  ,  '-or', '-ob'                
linespec = { '-', '-',  '-',  '-', '-' };
markers = {'+','o','*','d','x'}; % ,'s','.','p','h'

cyan        = [0.2 0.8 0.8];
brown       = [0.2 0 0];
orange      = [1 0.5 0];
blue        = [0 0.5 1];
green       = [0 0.6 0.3];
red         = [1 0.2 0.2];
red         = [1 0 0];  %   1
burnedRed   = [0.6350, 0.0780, 0.1840];  %  2
cyan        = [0 1 1];  % 3
brown       = [0.2 0 0]; % 4
yellow      = [ 1 1 0]; 
orange      = [1 0.5 0]; % 5
green       = [ 0 1 0 ]; % 6
magenta     = [1, 0, 1]; % BTL 
colorspec   = {red; magenta; green; orange; blue}; % ; green; magenta; black; blue

% rowNames = {'aa', 'bb', 'RS','LS', 'SER' ,'GLM','RC'};

if log_scale == 1
    % ALL(:,2:end) = log10(ALL(:,2:end));
    ALL(:,2:end) = log(ALL(:,2:end));
end

yminn = min(min( ALL(:,2:end) )); 
ymaxx = max(max( ALL(:,2:end) )); 

for i = metodeIndex
    Plot_color = colorspec{i};
    plot(ALL(:,1),ALL(:,1+i), 'LineStyle', linespec{i},  'Marker', markers{i}, 'LineWidth', 3, 'MarkerSize',15,   'Color', Plot_color); hold on;
    if log_scale == 1
        myYlab= ['log(' ylab ')'];
    else
        myYlab= [ ylab ];
    end
    
end

% close all; bar(log(ALL(:,2:14))); hold on;
axis tight;
yl = ylim;

[yminn ymaxx];
height = ymaxx - yminn ;

if ~isempty(yminn)  
    yl(1) = yminn - height * 0.07;   disp('Clipped/Wider ymin');
end


if ~isempty(ymaxx)  
    yl(2) = ymaxx + height * 0.07;  disp('Clipped/Wider ymax');
end

% Set updated ylimits: 
ylim(yl);

xlabel('\beta');   ylabel(myYlab);    % axis tight;
set(gca,'FontSize',PARS.myFont);

plotLegend = 1;
if plotLegend == 1
    h_legend = legend(legList(metodeIndex),'Location','Best', 'NumColumns', 1); legend BOXOFF;
    set(h_legend,'FontSize',PARS.myFontLegend);
end

h_xlabel = get(gca,'XLabel');           h_ylabel = get(gca,'YLabel');
set(h_xlabel,'FontSize',PARS.myFont); set(h_ylabel,'FontSize',PARS.myFont);

if showtitle == 1
    title(label_orig_tit, 'FontSize',19);    
end

set(gcf,'PaperPositionMode','auto');

set(gca,'LooseInset',get(gca,'TightInset'));

plotFolder = [ plotFolder  '_'  fsStat ];
fs = [ plotFolder '' extraDesc ];

fs= regexprep(fs, '\.', 'p');       disp(fs);

return

% input('file name');
% saveas(1,fs,'epsc'); % saveas(1,fs,'fig');
% saveas(indStat,fs,'png');
% input('done');
% return

end



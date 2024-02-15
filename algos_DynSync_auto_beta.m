%do a grid search for the regularization hyperparameter beta_reg

function [ metrics75mtx, sols] = algos_DynSync_auto_beta(data, gt, PARS)

XO = 0;  % turn on/off verbose.

% rand('state', 123);
% addpath(genpath('helpers'));
% addpath(genpath('algos'));
% beta_reg 

i = 0;
beta_list = 0:1:floor(sqrt(PARS.T)) %0 : 1 : 10 %choice of the grid
for beta_reg = beta_list
    i=i+1;
    disp([ 'beta_reg=' num2str(beta_reg) ]);
    [ metrics ] = algos_DynSync_given_beta(beta_reg, data, gt, PARS);
    if XO == 1
        disp_nice_metrics(metrics);
    end
    MTX_metrics(:,:,i) = metrics;
    % input('Press ''Enter'' to continue...','s');
end

MTX_metrics;

figure(1);  clf;  

% {plot corr, rmse, dafi, smot} vs beta
corrMtx = squeeze(MTX_metrics(1, : , :))';
subplot(2,2,1);
plot_nice_auto_beta(corrMtx, '', 1, '', beta_list, PARS);

subplot(2,2,2);
rmseMtx = squeeze(MTX_metrics(2, : , :))';
plot_nice_auto_beta(rmseMtx, '', 2 , '', beta_list, PARS);

subplot(2,2,3);
dafiMtx = squeeze(MTX_metrics(5, : , :))';
plot_nice_auto_beta(dafiMtx, '', 5 , '', beta_list, PARS);

subplot(2,2,4);
smotMtx = squeeze(MTX_metrics(6, : , :))';
plot_nice_auto_beta(smotMtx, '', 6 , '', beta_list, PARS);

metrics75mtx = stats_best_beta_by_algo( MTX_metrics , beta_list);

% plot rmse vs beta
% rmse = MTX_metrics(2, : , :)
% plot(rmse);
end






function plot_nice_auto_beta(MTX2D, plotFolder, indStat , scan_ID, beta_list, PARS)

showtitle = 1;
log_scale = 0;
extraDesc= ''
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

metodeIndex = [ 1 2 3 4 5];    % which methods to retain for plotting

% [ yminn ymaxx ]

% ALL % noises by algos
ALL = [beta_list' MTX2D];
% input('---');

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
colorspec   = {red; magenta; green; orange; blue} % ; green; magenta; black; blue

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

[yminn ymaxx]
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

% V = axis();
% axis( [ 0 0.8 0 min(2,V(4)) ] );
% the_ticks = sort(unique(ARRAYCONS(1,6,:)));
% ticklab = sort(unique(ARRAYCONS(1,6,:)));
% set(gca,'XTick',the_ticks); set(gca,'XTickLabel',ticklab);

% myTitle = [ 'n=' int2str(n)   ';  p=' num2str(pG) ];

% myTitle = [ label_orig ' - beta selection step ' ];
% myTitle = regexprep(myTitle, '_', ': ');  disp(myTitle);
% myTitle = regexprep(myTitle, '_', '  ');
if showtitle == 1
    title(label_orig_tit, 'FontSize',19);    
end

% axis tight;

% input('see plot');

% figure(1); FigHandle = figure(1);
% set(FigHandle, 'Position', [100, 100, 750, 550]); set(gcf,'PaperPositionMode','auto');
% set(indStat, 'Position', [1000, 1000, 600, 500]);    set(gcf,'PaperPositionMode','auto');
% axesPosition = get(gcf, 'Position')
%if indStat == 2
%    set(indStat, 'Position', [ 2030        1378         794         637 ]);
%elseif indStat == 9
%    set(indStat, 'Position', [ 2832        1374         794         637]);    
%elseif indStat == 10
%    set(indStat, 'Position', [ 2832        590         794         637]);            
%end
set(gcf,'PaperPositionMode','auto');

% pos = [0.3 0.6 0.2 0.4]; % [left bottom width height]
% xlim([0.04  0.91])
set(gca,'LooseInset',get(gca,'TightInset'))

plotFolder = [ plotFolder  '_'  fsStat ];
fs = [ plotFolder '' extraDesc ];

fs= regexprep(fs, '\.', 'p');       disp(fs);

return

% input('file name');
% saveas(1,fs,'epsc'); % saveas(1,fs,'fig');
saveas(indStat,fs,'png');
% input('done');
return

end



function plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, xaxis_vect, xaxis_label, indivPlotBool, plot_error_bars, ALGO)

%% MANY_AVG: 3d Tensor capturing averages:  metrics x algos x VaryingDimension (AVG):
         % where the "VaryingDimension" may capture noiseLevels, timePoints, etc
%% MANY_STD: similar to MANY_AVG, but capturing the standard deviations (across the Monte Carlo runs)
%
%% fsPlots: file where the plot will be saved; it will have a suffix given by the metric label
        % eg final file will be called   fsPlots_{Corr,Corr, ...}.png 
%
%% label_nice: title for the figure
%
%% indMetric: the index of the metric we want to plot
%
%% xaxis_vect: x-axis vector of values (for eg, noises vector)
%
%% xaxis_label: label for the x-axis
%
%% indivPlotBool: 0/1 whether to create a (new) figure for each plot
%
%% plot_error_bars : 0/1 whether to plot error bars
%
%%  ALGO: structure containing algorithm related info (which algos are on/off, etc)

%% Example of how to call this function:
% plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, noises, '\gamma noise level',1 , 1, ALGO);
% plot_nice(MANY_AVG, MANY_STD, fsPlots, label_nice, indMetric, T_vect, 'T (time)', 1, 1, ALGO);

disp('----Generic function for plotting results-----');
disp(MANY_AVG);
size(MANY_AVG);   % metrics by algos by xaxis_vect
MTXSTATS = permute(MANY_AVG,[1 2 3]);
% MTXSTATS   %  algos -by- metrics -by- xaxis_vect 
size(MTXSTATS); 

showtitle = 1;
log_scale = 0;
plotLegend = 1;
extraDesc = '';
% indMetric = 1;
if indivPlotBool ==1
    figure(indMetric); clf;
end

PARS.myFont = 32;
PARS.myFontLegend = 32;
% format long

%    1     2       3        4         5       6      7
% 'corr', 'rmse', 'kend', 'pflip', 'dafi', 'smot', 'beta'
if indMetric == 1
    ylab = 'Correlation Score';        fsStatMetric = 'Corr';
elseif indMetric == 2
    ylab = 'RMSE';                     fsStatMetric = 'RMSE';  
elseif indMetric == 3
    ylab = 'Kendall Distance';         fsStatMetric = 'Kendall';    
elseif indMetric == 4
    ylab = 'Percentage Upsets';        fsStatMetric = 'PercUpsets';     
elseif indMetric == 5
    ylab = 'Data Fidelity (DaFi)';     fsStatMetric = 'DaFi';         
elseif indMetric == 6
    ylab = 'Smoothness (SMOT)';        fsStatMetric = 'SMOT';
elseif indMetric == 7
    ylab = 'Beta';                     fsStatMetric = 'Beta';    
end

%% which methods to retain for plotting 
%indexMethods = [1 2 3 4 5];  
indexMethods = find([ALGO.run_spectral ALGO.run_ppm ALGO.run_GTRS ALGO.run_LTRS_GS  ALGO.run_LTRS_GMD]);

yminn = [];
ymaxx = [];

MTXSTATS;  % algos 

ALL = squeeze(MTXSTATS(indMetric,:,:))';   % xaxis_vect by algos
MTX_STD_ALL =  squeeze(MANY_STD(indMetric,:,:))';
size(ALL);
size(MTX_STD_ALL);

noiseLevs = xaxis_vect';
size(noiseLevs);

ALL = [noiseLevs ALL];
MTX_STD_ALL = [noiseLevs MTX_STD_ALL];


% Recall the ordering from algos:
% metrics = [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ];
legList = {'Spectral', 'PPM',    'GTRS',    'LTRS-GS',    'GMD-LTRS' };
colMethods = {  '-g.', '-r.',  '-m.',  '-c.', '-b.'};  %,  '-m.' ,  '-k.'  ,  '-or', '-ob'  
linespec = { '-', '-',  '-',  '-', '-' };
markers = {'+','o','*','d','x'}; % ,'s','.','p','h'

% Clean up at the end once we decide on coloring scheme:
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
magenta = [1, 0, 1]; % BTL 
% violet = [0.4940, 0.1840, 0.5560];
% black = [0 0 0];
% blue   = [0 0 1];
% colorspec = {[0.9 0.9 0.9]; [0.8 0.8 0.8]; [0.6 0.6 0.6]; [0.4 0.4 0.4]; [0.2 0.2 0.2]};
% linespec = {'-', ':', '-.', '--'};
colorspec = {red; magenta; green; orange; blue}; % ; green; magenta; black; blue

if log_scale == 1
    % ALL(:,2:end) = log10(ALL(:,2:end));
    ALL(:,2:end) = log(ALL(:,2:end));
end

for i = indexMethods
    Plot_color = colorspec{i};
    plot(ALL(:,1),ALL(:,1+i), 'LineStyle', linespec{i},  'Marker', markers{i}, 'LineWidth', 3, 'MarkerSize',15,   'Color', Plot_color); hold on;
    if log_scale == 1
        myYlab= ['log(' ylab ')'];
    else
        myYlab= [ ylab ];
    end
end

axis tight;
yl = ylim;
yminn;
if ~isempty(yminn)  
    yl(1) = yminn;   disp('Clipped ymin');
end

ymaxx;
if ~isempty(ymaxx)  
    yl(2) = ymaxx;  disp('Clipped ymax');
end

ylim(yl);

%% deprecated library (though nice visual effects; check for substitute)
% hx = graph2d.constantline(ALL(:,1), 'LineStyle',':', 'Color','k','LineWidth',0.3);
% changedependvar(hx,'x');

xlabel( xaxis_label );  ylabel(myYlab);    % axis tight;
set(gca,'FontSize',PARS.myFont);


if plotLegend == 1
    h_legend = legend(legList(indexMethods),'Location','Best', 'NumColumns', 1); legend BOXOFF;
    set(h_legend,'FontSize',PARS.myFontLegend);
end


if plot_error_bars == 1
    hold on;
    for i = indexMethods
        err = MTX_STD_ALL(:,1+i);
        hold on;
        errorbar(ALL(:,1),ALL(:,1+i), err, 'both', 'o', "MarkerEdgeColor", "black");  % "MarkerFaceColor", "black" , [0.65 0.85 0.90]
    end
end


h_xlabel = get(gca,'XLabel');           h_ylabel = get(gca,'YLabel');
set(h_xlabel,'FontSize',PARS.myFont); set(h_ylabel,'FontSize',PARS.myFont);

myTitle = label_nice;  % (add other info when needed; eg log scale or other)
% myTitle = regexprep(myTitle, '_', ': ');  disp(myTitle);
if showtitle == 1
    title(myTitle, 'FontSize',22);
end


if indMetric == 2
    set(indMetric, 'Position', [ 2030        1378         794         637 ]);
elseif indMetric == 9
    set(indMetric, 'Position', [ 2832        1374         794         637]);    
elseif indMetric == 10
    set(indMetric, 'Position', [ 2832        590         794         637]);            
end

set(gcf,'PaperPositionMode','auto');
set(gca,'LooseInset',get(gca,'TightInset'));

% label
fileToSavePlot = [ fsPlots  '_' fsStatMetric  ];
fs = [ fileToSavePlot '' extraDesc ];
fs = regexprep(fs, '\.', 'p');       disp(fs);
% saveas(1,fs,'epsc');  % saveas(1,fs,'fig');
saveas(indMetric,fs,'png');
% input('done');
end



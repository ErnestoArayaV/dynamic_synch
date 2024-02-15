function plot_nice(MANY_AVG, MANY_STD, plotFolder, label_orig, scan_ID, noises)

disp('----plotResults-----');
MANY_AVG
size(MANY_AVG)   % metrics by algos by noises
% MTXSTATS = permute(MANY_AVG,[2 1 3])     
MTXSTATS = permute(MANY_AVG,[1 2 3]);    
% MTXSTATS   %  algos -by- metrics -by- noises 
size(MTXSTATS)

% MTX_STD = permute(MANY_STD,[2 1 3]) 

showtitle = 0
log_scale = 0
extraDesc= ''
indStat = 1;
figure(indStat); clf; 

PARS.myFont = 32;
PARS.myFontLegend = 32;
PARS.distribution = 'uniform'
withMC = 0;

% return
% format long
MTXSTATS;
size(MTXSTATS) %  18 methods (9+9) xxx 10 stats (1noise +9)  xxx 19 noises 


% OLD:
%  eta     KendTau    corrKend    nr_flips      tau       nrUpsets    NaN      time        corSc        RMSE  

% indStat = 2;   ylab = 'Kendall Distance';  fsStat = 'Kendall';
% indStat = 9;   ylab = 'Corr Score';        fsStat = 'CorrScore';
% indStat = 10;  ylab = 'RMSE';              fsStat = 'RMSE';  

%   1     2       3        4
%  corr; RMSE; corrKend; perc_flips 
% colNames = {'eta', 'corr', 'RMSE',  'KendTau', 'perc_flips'};

if indStat == 3
    ylab = 'Kendall Distance';         fsStat = 'Kendall';
elseif indStat == 1
    ylab = 'Correlation Score';        fsStat = 'Corr';
elseif indStat == 2
    ylab = 'RMSE';                     fsStat = 'RMSE';  
elseif indStat == 4
    ylab = 'Percentage Upsets';        fsStat = 'Upsets';     
elseif indStat == 5
    ylab = 'Data Fidelity (DaFi)';        fsStat = 'DaFi';         
elseif indStat == 6
    ylab = 'Smoothness (SMOT)';        fsStat = 'Smoothness';
end

 metodeIndex = [ 1 2 3 4 5]  % which methods to retain for plotting 

% if scan_ID == 1 ||  scan_ID == 2
%     if indStat == 10
%         metodeIndex = [ 1 2 3 4          8 9 10 11    ];
%     elseif indStat == 9 || indStat == 2
%         metodeIndex = [ 1 2 3 4    6 7        8 9 10 11     13 14   ];
%     end
% elseif scan_ID == 3 || scan_ID == 4 || scan_ID == 5
%     indStat = 9;  ylab = 'corSc';  fsStat = 'corSc';
%     metodeIndex = [ 1 2  ];  % 3 4 5 
%     size(MTXSTATS)
% end


yminn = [];
ymaxx = [];


%if scan_ID==4 &&  alpha == 1  && withMC == 0  && log_scale == 0
%    if indStat == 2;  ymaxx = 0.26; end 
%    if indStat == 9;  yminn = 0.7; end      
%    % if indStat == 10; ymaxx = 0.1; end 
%end

plotFolder = [ plotFolder  '_'  fsStat ];

%  OLD          
% colNames = 
%  {'eta','perc','corrKend','nr_flips',   'tau',    'nrUpsets','NaN',   'time','corSc','RMSE'};
%    1      2          3             4       5         6          7        8     9     10
%  eta: percSync corrKendSync  nr_flipsSync  tauSync  nrUpsets  rankSdp   tm   corSc  RMSE
%  ALL = squeeze(MTXSTATS(:,2,:))';
%  DirUndir = 'ABS';

MTXSTATS  % algos 

ALL = squeeze(MTXSTATS(indStat,:,:))'   % noises by algos
MTX_STD_ALL =  squeeze(MANY_STD(indStat,:,:))';
size(ALL)
size(MTX_STD_ALL)

noiseLevs = noises'
size(noiseLevs )

ALL = [noiseLevs ALL];
MTX_STD_ALL = [noiseLevs MTX_STD_ALL];

% If we want to leave out the 0 noise level (strange behaviour sometimes)
% ALL = ALL(2:end, :);   noiseLevs = noiseLevs(2:end);

% close all; figure(1);
% figure(1); clf;
% colMethods = {'-r.','--bx', '-k*','-.mo' , ':kd',':ms', '-c^'};
% nrMethods = size(ALL,2) - 1;

% nrMethods = nrMethods-1

% legList = {'SVD-proj','SVD-norm','RowSum', 'LS',  'SER',  'SER-GLM','RC'};
%legList     = {'SVD',  'SVD-N',  'RowSum',  'LS',  'SER',  'GLM',  'RC'};
%colMethods = {'-r.',   '-ro',     '--m.',  '-c.', '-b.',  '-m.',  '-k.'};

% color = jet(7);
%  metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd 


% Recall the ordering from algos
%  metrics = [ metrics_spectral  metrics_ppm  metrics_gtrs  metrics_ltrs_gs  metrics_ltrs_gmd ];
                                                                         % SpringRank         % PageRank   % SyncRank  
legList = {'Spectral', 'PPM',    'GTRS',    'LTRS-GS',    'LTRS-GMD' }
      %   'MC-SVD', 'MC-SVD-N', 'MC-RSUM', 'MC-LS', 'MC-SER', 'MC-SPR', 'MC-BTL', 'MC-PGR',  'MC-SYNC'
colMethods = {  '-g.', '-r.',  '-m.',  '-c.', '-b.'}  %,  '-m.' ,  '-k.'  ,  '-or', '-ob'  
                
linespec = { '-', '-',  '-',  '-', '-' }

         
markers = {'+','o','*','d','x'} % ,'s','.','p','h'

cyan        = [0.2 0.8 0.8];
brown       = [0.2 0 0];

orange      = [1 0.5 0];
blue        = [0 0.5 1];
green       = [0 0.6 0.3];
red         = [1 0.2 0.2];


% rowNames = {'SVD-proj', 'SVD-norm', 'RS','LS', 'SER' ,'GLM','RC'};

red         = [1 0 0];  %   1
burnedRed   = [0.6350, 0.0780, 0.1840];  %  2

cyan        = [0 1 1];  % 3
brown       = [0.2 0 0]; % 4
yellow      = [ 1 1 0]; 

orange      = [1 0.5 0]; % 5
green       = [ 0 1 0 ]; % 6

magenta = [1, 0, 1]; % BTL 
% violet = [0.4940, 0.1840, 0.5560]; %   PGR
% black = [0 0 0]; % PGR 
% blue   = [0 0 1];   % SYNC

   
% colorspec = {[0.9 0.9 0.9]; [0.8 0.8 0.8]; [0.6 0.6 0.6]; [0.4 0.4 0.4]; [0.2 0.2 0.2]};
% linespec = {'-', ':', '-.', '--'};

colorspec = {red; magenta; green; orange; blue} % ; green; magenta; black; blue

% colormap jet;
% cmap=colormap;


% metodeIndex = [     8 9 10 11    ];

% ALL = ALL( : , metodeIndex+1 );

% allNans = sum( isnan( ALL(:,2:end) ) );
% badPoz = find(allNans == size(ALL,1) );
% metodeIndex = setdiff(metodeIndex, badPoz );



if log_scale == 1
    % ALL(:,2:end) = log10(ALL(:,2:end));
    ALL(:,2:end) = log(ALL(:,2:end));
end

for i = metodeIndex
    % plot(ALL(:,1),ALL(:,1+i), colMethods{i}, 'LineWidth', 3, 'MarkerSize',15); hold on;
    % Plot_color=cmap(5*i,:);
    Plot_color = colorspec{i};
    plot(ALL(:,1),ALL(:,1+i), 'LineStyle', linespec{i},  'Marker', markers{i}, 'LineWidth', 3, 'MarkerSize',15,   'Color', Plot_color); hold on;
    if log_scale == 1
        myYlab= ['log(' ylab ')'];
    else
        myYlab= [ ylab ];
    end
    
    err = MTX_STD_ALL(:,1+i);
    errorbar(ALL(:,1),ALL(:,1+i), err, 'both', 'o', "MarkerEdgeColor", "black");  % "MarkerFaceColor", "black" , [0.65 0.85 0.90]  

    % plot(ALL(:,1), ALL(:,1+i), colMethods{i}, 'LineWidth', 3, 'MarkerSize',15); hold on;
    % legList{k} = [ methods{i} '-' eigClustMeth{j} ];    k = k+1;
end

% close all; bar(log(ALL(:,2:14))); hold on;

% 
% 
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


%% deprecated !! LOUT
% hx = graph2d.constantline(ALL(:,1), 'LineStyle',':', 'Color','k','LineWidth',0.3);
% changedependvar(hx,'x');

% = 1- \eta
xlabel('\gamma noise level ');  ylabel(myYlab);    % axis tight;
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

myTitle = [ label_orig ' - ' PARS.distribution ];
myTitle = regexprep(myTitle, '_', ': ');  disp(myTitle);
% myTitle = regexprep(myTitle, '_', '  ');
if showtitle == 1
    title(myTitle, 'FontSize',22);
end

% axis tight;

% input('see plot');
% return

% figure(1); FigHandle = figure(1);
% set(FigHandle, 'Position', [100, 100, 750, 550]); set(gcf,'PaperPositionMode','auto');

% set(indStat, 'Position', [1000, 1000, 600, 500]);    set(gcf,'PaperPositionMode','auto');



% axesPosition = get(gcf, 'Position')
% axesPosition =     
if indStat == 2
    set(indStat, 'Position', [ 2030        1378         794         637 ]);
elseif indStat == 9
    set(indStat, 'Position', [ 2832        1374         794         637]);    
elseif indStat == 10
    set(indStat, 'Position', [ 2832        590         794         637]);            
end
 set(gcf,'PaperPositionMode','auto');

 
% pos = [0.3 0.6 0.2 0.4]; % [left bottom width height]
% xlim([0.04  0.91])
set(gca,'LooseInset',get(gca,'TightInset'))


%% LOUT Sept 2018:  fs = [ plotFolder '/Errors_' label ];
fs = [ plotFolder '' extraDesc ];

if withMC == 1
    fs = [ fs '_MC' ];
end

fs= regexprep(fs, '\.', 'p');       disp(fs);
% input('file name');
% saveas(1,fs,'epsc'); % saveas(1,fs,'fig');
saveas(indStat,fs,'png');
% input('done');
return





figure(2); clf;
fsrank = [fs '_rankSDP'];
rkSDP = squeeze(MTXSTATS(:,7,:))';
rkSDP = rkSDP(:,7);
plot(ALL(:,1), rkSDP, '-k*', 'LineWidth', 3, 'MarkerSize',15)
axis tight;

hx = graph2d.constantline(ALL(:,1), 'LineStyle',':', 'Color','k','LineWidth',0.3);
changedependvar(hx,'x');

xlabel('\eta');  ylabel('average rank of the SDP');  axis tight;
set(gca,'FontSize',PARS.myFont);
h_xlabel = get(gca,'XLabel');           h_ylabel = get(gca,'YLabel');
set(h_xlabel,'FontSize',PARS.myFont); set(h_ylabel,'FontSize',PARS.myFont);


saveas(2,fsrank,'epsc'); saveas(2,fsrank,'fig');  saveas(2,fsrank,'png');

% input('done');
end



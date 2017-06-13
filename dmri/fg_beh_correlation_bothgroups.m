% fg_beh_correlation script for plotting both control and patient groups in
% the same figures


% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
p = getCuePaths;
dataDir = p.data;

% directory & filename of fg measures
method = 'conTrack';
fgMatStr = 'DAL_naccL_autoclean_cl1'; %'.mat' will be added to end

% which scale to correlate with fiber group measures?
scale = 'BIS';

% plot both groups
group = {'controls','patients'};

cols=getCueExpColors(numel(group)); % plotting colors for groups

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(p.figures, ['FG_' strrep(scale,'_','') '_corr'],fgMatStr);
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end

omit_subs = {
    'gm160909'
    'jb161004'
    };
    


%% load data

%%%%%%%%%%%% get fiber group measures & behavior scores
[fgMeasures,fgMLabels,scores,subjects,gi]=cellfun(@(x) loadFGBehVars(...
    fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),scale,x,omit_subs), ...
    group, 'uniformoutput',0);
fgMLabels=fgMLabels{1};

%% fig 1: plot correlations with fg measures

%%%%%%%%%%%%%%% params for figure 1
node = 'best'; % an integer specifying which node to plot, or 'best'
bestWhat = 'MD'; % which fg measure(s) to test for best
% node = 11;

fgPlotIdx = [1:4]; % index of which fg measures to include in corr plots
%%%%%%%%%%%%%%%

% if node is 'best', determine which node is best
if strcmp(node,'best') % find node with highest correlation with FA or MD
   [~,np]=cellfun(@(x,y) corr(x{strcmp(fgMLabels,bestWhat)},y), fgMeasures,scores,'uniformoutput',0);
    [minp,ri]=min(cell2mat(np)); [~,ci]=min(minp); node = ri(ci);
end

% get a string describing node(s)
if numel(node)>1
    nodeStr = sprintf('%d_%d',node(1),node(end));
else
    nodeStr = num2str(node);
end

% plot it
% figH = subplotCorr(figH,x,y,xlab,ylab,titleStr,col)
figH=setupFig;
 
 nP = numel(fgPlotIdx);

[nRow,nCol] = getNiceSPConfig(nP);

for i=1:nP
    
    axH=subplot(nRow,nCol,i);
    hold on
    titleStr = [];
    for j=1:numel(group)
        [axH,rpStr] = plotCorr(axH,scores{j},mean(fgMeasures{j}{i}(:,node),2),scale,fgMLabels(i),'',cols(j,:));
        tStr{j} = ['\fontsize{10}{\color[rgb]{' num2str(cols(j,:)) '}' rpStr '} ']; % title strings
    end
    
    % to write corr coefficients side by side: 
    title(axH,[tStr{:}])
    
    % to write them as 2 separate lines: 
%     title(axH,tStr)
    
    hold off
end

% super title 
suptitle([strrep(fgMatStr,'_',' ') ' node ' nodeStr])
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_fg_' strrep(scale,'_','') '_corr_node' nodeStr]))
end

% legend
lh=get(axH,'Children')
legend(axH,[lh(1) lh(3)],group,'Location','EastOutside','FontSize',12)
legend('boxoff')
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_fg_' strrep(scale,'_','') '_corr_node' nodeStr '_w_legend']))
end



%% fig 2: plot behavior-fg correlation as heatmap over trajectory of fg
% measures

%%%%%%%%%%%%%%% params for figure 2
fgMCorr = 'MD'; % fg measure to correlate with behavior & plot as color map
fgMPlot = 'FA'; % fg measure to plot as values along pathway node
%%%%%%%%%%%%%%%

% get correlation between fgMCorr & scores along pathway nodes
[r,p]=corr(scores,fgMeasures{find(strcmp(fgMCorr,fgMLabels))});

% plot nodes on x-axis, fgMPlot values on y-axis, and correlation vals in color
fig2=dti_plotCorr(fgMeasures{strcmp(fgMPlot,fgMLabels)},r,[min(r) max(r)],fgMPlot);
title([fgMCorr '-' scale ' correlation strength in color']);
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_' fgMPlot '_' fgMCorr '_' scale '_corr']))
end






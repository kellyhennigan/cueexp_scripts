% fg_beh_correlation script

% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
p = getCuePaths;
dataDir = p.data;


% which group(s) to plot?
group = {'controls'};


% directory & filename of fg measures
method = 'conTrack';
fgMatStr = 'DAR_naccR_autoclean_cl1'; %'.mat' will be added to end


% which scale to correlate with fiber group measures?
scale = 'BIS';


% include control variables? 
% covars = {'age','gender'};
% covars = {};


saveFigs =0;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(p.figures, ['FG_' strrep(scale,'_','') '_corr'],fgMatStr);


% subjects with 20% or greater bad movement TRs (bad movement threshold is
% euclidean norm of 4)
% omit_subs = {
%     'gm160909'
%     'jb161004'
%     };
%     
omit_subs = {
	'jr160507'
% 	'gm160909'
% 	'ld160918'
	'gm161101'
% 	'jn160403'
% 	'sr151031'
	};


%% load data & create out directory, if needed

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


%%%%%%%%%%%% get fiber group measures & behavior scores
[fgMeasures,fgMLabels,scores,subjects,gi]=loadFGBehVars(...
    fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),scale,group,omit_subs);

n = numel(subjects); 


%% fig 1: plot behavior-fg correlation as heatmap over trajectory of fg
% measures

%%%%%%%%%%%%%%% params for figure 1
fgMCorr = 'MD'; % fg measure to correlate with behavior & plot as color map
fgMPlot = 'FA'; % fg measure to plot as values along pathway node
%%%%%%%%%%%%%%%

% get correlation between fgMCorr & scores along pathway nodes
[r,p]=corr(scores,fgMeasures{find(strcmp(fgMCorr,fgMLabels))});

% plot nodes on x-axis, fgMPlot values on y-axis, and correlation vals in color
fig1=dti_plotCorr(fgMeasures{strcmp(fgMPlot,fgMLabels)},r,[min(r) max(r)],fgMPlot);
title([fgMCorr '-' scale ' correlation strength in color']);
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_' fgMPlot '_' fgMCorr '_' scale '_corr']))
end



%% fig 2: plot correlations with fg measures

%%%%%%%%%%%%%%% params for figure 1
node = 'best'; % an integer specifying which node to plot, or 'best'
bestWhat = 'MD'; % which fg measure(s) to test for best
% node = 11;

fgPlotIdx = [1:4]; % index of which fg measures to include in corr plots
%%%%%%%%%%%%%%%

% include control variables? If so, regress out effect of control vars from
% fgMeasures and scores
if exist('covars','var') && ~isempty(covars)
    
   % design matrix w/control vars and a vector of ones for intercept
   X = [ones(n,1),cell2mat(cellfun(@(x) getCueData(subjects,x), covars, 'uniformoutput',0))];
   
   % regress control variables out of scores and fgMeasures
   scores = glm_fmri_fit(scores,X,[],'err_ts');
   fgMeasures = cellfun(@(y) glm_fmri_fit(y,X,[],'err_ts'), fgMeasures,'uniformoutput',0);
   
   cvStr = '_wCVs';
   
else
    
    cvStr = '';
   
end

% if node is 'best', determine which node is best
if strcmp(node,'best') % find node with highest correlation 
    [r,p]=corr(fgMeasures{strcmp(bestWhat,fgMLabels)},scores);
    [~,node] = min(p);
end

% get a string describing node(s)
if numel(node)>1
    nodeStr = sprintf('%d_%d',node(1),node(end));
else
    nodeStr = num2str(node);
end

% plot it
fig1 = subplotCorr([],scores,cellfun(@(x) mean(x(:,node),2), fgMeasures(fgPlotIdx),'uniformoutput',0),...
    scale,fgMLabels(fgPlotIdx),'rp');
suptitle([strrep(fgMatStr,'_',' ') ' node ' nodeStr])
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_fg_' strrep(scale,'_','') '_corr_node' nodeStr cvStr]))
end



nSubs = numel(subjects);








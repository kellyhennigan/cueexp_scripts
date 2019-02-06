% fg_beh_correlation script

% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
pa = getCuePaths;
dataDir = pa.data; figDir = pa.figures;


% which group(s) to plot?
group = {'controls'};
% group = {'nonrelapsers'};
% group = {'all'};
%  group = {'patients'};

% directory & filename of fg measures
% method = 'conTrack';
method = 'mrtrix_fa';

% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
fgMatStr = 'DALR_naccLR_aboveAC_dil2_autoclean'; %'.mat' will be added to end
fgStr=fgMatStr;

% which scale to correlate with fiber group measures?
scale = 'BIS'
% scale = 'years_of_use';
% scale = 'nacc_nvlout_betas';


% include control variables? 
% covars = {'age'};
% covars = {'age'};
% covars = {'dwimotion'};
covars = {};

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(figDir, ['FG_' strrep(scale,'_','') '_corr'],method);


omit_subs={''};
% omit_subs={'as160129'};
% omit_subs={'nd150921','dd170610','li160927'};
% omit_subs={'nd150921','dd170610'};
% for mrtrix data:

% for cue data:
% omit_subs = [omit_subs;{'ie151020';'bb160402';'ps160508';'am160914'}]
 
% for cue data patients: 
% omit_subs = [omit_subs;{'as160317';
%     'rt160420';
%     'ms170424';
%     'hp170601';
%     'cs170816'}];

%% load data & create out directory, if needed

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


%%%%%%%%%%%% get fiber group measures & behavior scores
fgMFile=fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']);
[fgMeasures,fgMLabels,scores,subjects,gi]=loadFGBehVars(...
    fgMFile,scale,group,omit_subs);



% midi betas:
% scale = 'gvnant';
% scores = loadRoiTimeCourses(['/Users/kelly/cueexp/data/results_midi_afni/roi_betas/nacc_desai/' scale '.csv'],subjects);
% scores5 = loadRoiTimeCourses('gain5.csv',subjects,4);
% scores0 = loadRoiTimeCourses('gain0.csv',subjects,4);
% scores=scores5-scores0;

% cue betas: 
% scale = 'vta_drug_betas';
% scores = loadRoiTimeCourses('/Users/kelly/cueexp/data/results_cue_afni/roi_betas/VTA/drugs.csv',subjects);


n = numel(subjects); 


%% fig 1: plot behavior-fg correlation as heatmap over trajectory of fg
% measures

% %%%%%%%%%%%%%% params for figure 1
% fgMCorr = 'MD'; % fg measure to correlate with behavior & plot as color map
% fgMPlot = 'FA'; % fg measure to plot as values along pathway node
% %%%%%%%%%%%%%%%

% % get correlation between fgMCorr & scores along pathway nodes
% [r,p]=corr(scores,fgMeasures{find(strcmp(fgMCorr,fgMLabels))});
% 
% % plot nodes on x-axis, fgMPlot values on y-axis, and correlation vals in color
% fig1=dti_plotCorr(fgMeasures{strcmp(fgMPlot,fgMLabels)},r,[min(r) max(r)],fgMPlot);
% title([fgMCorr '-' strrep(scale,'_',' ') ' correlation strength in color']);
% if saveFigs
%     print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_' fgMPlot 'trajectory_' fgMCorr '_' scale '_corr']))
% end



%% fig 2: plot correlations with fg measures

%%%%%%%%%%%%%%% params for figure 1
% node = 'best'; % an integer specifying which node to plot, or 'best'
% bestWhat = 'MD'; % which fg measure(s) to test for best
node = [26:75];

fgPlotIdx = [1:2]; % index of which fg measures to include in corr plots
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
   
   %%% note: determine adjusted p-values with: 
%     p = r2p(r,N-(2+numel(covars))
   
else
    
    cvStr = '';
   
end

% get a string describing node(s)
if numel(node)>1 && ~ischar(node)
    nodeStr = sprintf('%d_%d',node(1),node(end));
else
    nodeStr = num2str(node);
end


% if node is 'best', determine which node is best
if strcmp(node,'best') % find node with highest correlation 
    [r,p]=corr(fgMeasures{strcmp(bestWhat,fgMLabels)},scores);
    [~,node] = min(p);
end


% plot it
fig2 = subplotCorr([],scores,cellfun(@(x) mean(x(:,node),2), fgMeasures(fgPlotIdx),'uniformoutput',0),...
    strrep(scale,'_',''),fgMLabels(fgPlotIdx),'rp');
suptitle([strrep(fgStr,'_',' ')])
% suptitle(fgStr)
if saveFigs
    outName = [fgMatStr '_' group{:} '_node' nodeStr cvStr];
    print(gcf,'-dpng','-r300',fullfile(outDir,outName))
end

%%%% NOTE: if control variables are included, the p-values need to be 
% adjusted to account for the difference in degrees of freedom!! (1 less
% degree of freedom per covariate)

nSubs = numel(subjects);







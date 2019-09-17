% fg_beh_correlation script

% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
pa = getCuePaths;
dataDir = pa.data; figDir = pa.figures_dti;


% which group(s) to plot?
% group = {'controls'};
% group = {'nonrelapsers'};
% group = {'all'};
 group = {'patients'};

% directory & filename of fg measures
% method = 'conTrack';
method = 'mrtrix_fa';

% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
% fgMatStr = 'DALR_naccLR_belowAC2_autoclean'; %'.mat' will be added to end
% fgMatStr = 'DALR_naccLR_belowAC_autoclean'; %'.mat' will be added to end
fgMatStr = 'DALR_naccLR_belowAC_autoclean'; %'.mat' will be added to end

fgStr=fgMatStr;

titleStr = 'inferior NAcc tract';

% which scale to correlate with fiber group measures?
% scale = 'discount_rate'
scale = 'years_of_use';
% scale = 'nacc_nvlout_betas';
% scale = 'age';


% include control variables?
covars = {'age','dwimotion'};
% covars = {'age'};
% covars = {'dwimotion'};
% covars = {'dwimotion'};

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(figDir, ['FG_' strrep(scale,'_','') '_corr']);


omit_subs = {'kj180621','kc190225','mm190226'};
% omit_subs={'ps151001'};
% omit_subs={'ac160415'};
% omit_subs={''};

%% load data & create out directory, if needed

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


%%%%%%%%%%%% get fiber group measures & behavior scores
fgMFile=fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']);
[fgMeasures,fgMLabels,scores,subjects,gi,SF]=loadFGBehVars(...
    fgMFile,scale,group,omit_subs);

% scores=log(scores)

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


%% covars:

if ~notDefined('covars')
    cvs=cell2mat(cellfun(@(x) getCueData(subjects,x), covars, 'uniformoutput',0));
    cvStr = ['_wCV_' covars{:}];
else
    cvStr = '';
end


%% fig 1: plot behavior-fg correlation as heatmap over trajectory of fg
% measures
% 
% %%%%%%%%%%%%%% params for figure 1
% fgMCorr = 'MD'; % fg measure to correlate with behavior & plot as color map
% fgMPlot = 'MD'; % fg measure to plot as values along pathway node
% %%%%%%%%%%%%%%%
% 
% % get correlation between fgMCorr & scores along pathway nodes
% if ~notDefined('covars')
%     [r,p]=partialcorr(scores,fgMeasures{find(strcmp(fgMCorr,fgMLabels))},cvs);
% else
%     [r,p]=corr(scores,fgMeasures{find(strcmp(fgMCorr,fgMLabels))});
% end
% 
% % plot nodes on x-axis, fgMPlot values on y-axis, and correlation vals in color
% % crange=[min(r) max(r)];
% crange=[0 .5];
% fig1=dti_plotCorr(fgMeasures{strcmp(fgMPlot,fgMLabels)},r,crange,fgMPlot);
% title([fgMCorr '-' strrep(scale,'_',' ') ' correlation strength in color']);
% if saveFigs
%     print(gcf,'-dpng','-r300',fullfile(outDir,[group{:} '_' fgMPlot 'trajectory_' fgMCorr '_' scale '_corr' cvStr]))
% end
% 


%% fig 2: plot correlations with fg measures

%%%%%%%%%%%%%%% params for figure 1
node=26:75; % middle 50% of tract


% get a string describing node(s)
if isequal(26:75,node)
    nodeStr = 'mid50';
elseif numel(node)>1
    nodeStr = sprintf('%d_%d',node(1),node(end));
else
    nodeStr = num2str(node);
end

% node=41:90;

% THIS ASSUMES THE MEASURES ARE STORED IN THIS ORDER
fa = mean(fgMeasures{1}(:,node),2);
md = mean(fgMeasures{2}(:,node),2);
rd = mean(fgMeasures{3}(:,node),2);
ad = mean(fgMeasures{4}(:,node),2);

% include control variables? If so, regress out effect of control vars from
% fgMeasures and scores
if ~notDefined('covars')
    
    [rfa,pfa]=partialcorr(fa,scores,cvs);
    [rmd,pmd]=partialcorr(1-md,scores,cvs);
    [rrd,prd]=partialcorr(rd,scores,cvs);
    [rad,pad]=partialcorr(ad,scores,cvs);
    
else
    
    [rfa,pfa]=corr(fa,scores);
    [rmd,pmd]=corr(1-md,scores);
    [rrd,prd]=corr(rd,scores);
    [rad,pad]=corr(ad,scores);
    
end

% strings of corr coefficients and p values for plots
corrStr{1} = sprintf('r=%.2f, p=%.3f',rfa,pfa);
corrStr{2} = sprintf('r=%.2f, p=%.3f',rmd,pmd);
corrStr{3} = sprintf('r=%.2f, p=%.3f',rrd,prd);
corrStr{4} = sprintf('r=%.2f, p=%.3f',rad,pad);

% plot it
fig = subplotCorr([],scores,{fa,1-md,rd,ad},scale,{'FA','1-MD','RD','AD'},corrStr);
ti=suptitle(titleStr);
set(ti,'FontSize',18)

if saveFigs
    outName = [fgMatStr '_' group{:} cvStr nodeStr];
    print(gcf,'-dpng','-r300',fullfile(outDir,outName))
end

%%%% NOTE: if control variables are included, the p-values need to be
% adjusted to account for the difference in degrees of freedom!! (1 less
% degree of freedom per covariate)

% nSubs = numel(subjects);


% fa=mean(fgMeasures{1}(:,26:75),2)
% md=mean(fgMeasures{2}(:,26:75),2)




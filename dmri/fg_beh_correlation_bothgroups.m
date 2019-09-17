% fg_beh_correlation script for plotting both control and patient groups in
% the same figures


% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
p = getCuePaths;
dataDir = p.data;
figDir=p.figures_dti;

% plot both groups
group = {'controls','patients'};
% group = {'nonrelapsers','relapsers'};


% directory & filename of fg measures
method = 'mrtrix_fa';


fgMatStr = 'DALR_naccLR_belowAC_autoclean'; %'.mat' will be added to end

titleStr = 'NAcc pathway (inferior)';


% which scale to correlate with fiber group measures?
scale = 'BIS';

% include control variables? 
 covars = {'age','dwimotion'};
% covars = {};
% covars = {'dwimotion'};
% covars = '';

cols=getCueExpColors(group); % plotting colors for groups
cols(1,:)=[0 0 0];

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(p.figures_dti, ['FG_' strrep(scale,'_','') '_corr'],fgMatStr);

omit_subs = {'kj180621','kc190225','mm190226'};
    
plotLeg=1;

%% do it

if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


%% fg loop

%%%%%%%%%%%% get fiber group measures & behavior scores
[fgMeasures,fgMLabels,scores,subjects]=cellfun(@(x) loadFGBehVars(...
    fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),scale,x,omit_subs), ...
    group, 'uniformoutput',0);
fgMLabels=fgMLabels{1};


%% fig 1: plot correlations with fg measures

node = 26:75; % nodes to average over

fgPlotIdx = [1:4]; % index of which fg measures to include in corr plots
%%%%%%%%%%%%%%%

%% this is messy but gets the job done...

if exist('covars','var') && ~isempty(covars)

    
    % have to put regress out covariates from fgMeasures & scores across ALL subjects
[all_fgMeasures,~,all_scores,all_subjects,gi]=loadFGBehVars(...
    fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),scale,'all',omit_subs);


%    % design matrix w/covariates and a vector of ones for intercept
   X = [ones(numel(all_subjects),1),cell2mat(cellfun(@(x) zscore(getCueData(all_subjects,x)), covars, 'uniformoutput',0))];

%    % regress covariates out of scores and fgMeasures
   all_scores = glm_fmri_fit(all_scores,X,[],'err_ts');
   all_fgMeasures = cellfun(@(y) glm_fmri_fit(y,X,[],'err_ts'), all_fgMeasures,'uniformoutput',0);
   
   % now replace fgMeasures and scores with those that have covariates
   % regressed out
   scores{1}=all_scores(gi==0); scores{2}=all_scores(gi>0);
   for j=1:numel(all_fgMeasures)
       fgMeasures{1}{j}=all_fgMeasures{j}(gi==0,:);
       fgMeasures{2}{j}=all_fgMeasures{j}(gi>0,:);
   end
   
    cvStr = ['_wCV_' covars{:}];
   
else
    
    cvStr = '';
   
end


% plot it
% figH = subplotCorr(figH,x,y,xlab,ylab,titleStr,col)
figH=setupFig;
 
 nP = numel(fgPlotIdx);

[nRow,nCol] = getNiceSPConfig(nP);

for i=1:nP
    
    axH=subplot(nRow,nCol,i);
    hold on
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
suptitle(titleStr)
if saveFigs
    outName = [fgMatStr '_bothgroups' cvStr]; 
    print(figH,fullfile(outDir,outName),'-depsc')
    
%     print(figH,'-dpng','-r300',fullfile(outDir,[group{:} '_fg_' strrep(scale,'_','') '_corr_node' nodeStr]))
end

% legend
if plotLeg
lh=get(axH,'Children')
legend(axH,[lh(3) lh(1)],group,'Location','EastOutside','FontSize',12)
legend('boxoff')
legStr='_w_leg';
else
    legStr='';
end
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[outName '_w_leg']))
end



clear all
close all

% get experiment-specific paths and cd to main data directory
pa = getCuePaths;
dataDir = pa.data; figDir = pa.figures;

% which group(s) to plot?
% group = {'controls','relapsers','nonrelapsers'};
group = {'controls','patients'};

% directory & filename of fg measures
method = 'conTrack';

fgMatStr = 'DALR_naccLR_autoclean_cl1'; %'.mat' will be added to end

saveFigs = 1;   % 1 to save figs to outDir otherwise 0

outDir = fullfile(figDir,fgMatStr,[group{:} '_comparisons']);

% include control variables? 
% covars = {'age','gender'};
covars = {'age'};
% covars = {};

omit_subs = {
    'jr160507'
    % 	'gm160909'
    'ld160918'
    'gm161101'
    'cg160715'
    % 	'jn160403'
    % 	'sr151031'
    };

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end



%% load data

%%%%%%%%%%%% get fiber group measures & behavior scores
[fgMeasures,fgMLabels,~,subjects,gi,SF]=loadFGBehVars(...
    fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),'','all',omit_subs);

% ADD LINES HERE TO UPDATE GI IF STRCMP(GROUP)=='relapsers' or
% 'nonrelapsers'; e.g.,
% if strcmp(group, 'relapsers')
% ri=getCueData(subjects,'relapse')
% gi(ri==1) = 2;
% end

%% control variables? (covariates?)


% include control variables? If so, regress out effect of control vars from
% fgMeasures and scores
if exist('covars','var') && ~isempty(covars)
    
   % design matrix w/control vars and a vector of ones for intercept
   X = [ones(numel(subjects),1),cell2mat(cellfun(@(x) getCueData(subjects,x), covars, 'uniformoutput',0))];
   
   % regress control variables out of fgMeasures
   fgMeasures = cellfun(@(y) glm_fmri_fit(y,X,[],'err_ts'), fgMeasures,'uniformoutput',0);
   
   cvStr = ['_wCV' covars{:}];
   
else
    
    cvStr = '';
   
end


x = 1:size(fgMeasures{1},2); % # of nodes

%% get stats 


for j=1:numel(fgMLabels)

[p,tab]=anova1(mean(fgMeasures{j},2),gi,'off'); % get stats
F=tab{strcmp(tab(:,1),'Groups'),strcmp(tab(1,:),'F')}; % F stat 
df_g = tab{strcmp(tab(:,1),'Groups'),strcmp(tab(1,:),'df')}; % group
df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
     
anova_res = sprintf('F(%d,%d) = %.1f; p = %.3f\n',df_g,df_e,F,p);
          
%% plot it


% get separate cell array of each groups' fgMeasure (FA, or MD, etc)
for g=1:numel(group)
    thisFgM{g} = fgMeasures{j}(gi==g-1,:);
end

cols = reshape(getCueExpColors(numel(group),'cell'),size(thisFgM,1),[]);
pvals=[];
lineLabels=group;
xlab = 'fg nodes';
ylab = fgMLabels{j};

figtitle = [strrep(fgMatStr,'_',' ') ' ' fgMLabels{j} '; ' anova_res];
savePath = fullfile(outDir,[fgMLabels{j} cvStr '.png']);
plotToScreen=1;

[fig,leg]=plotNiceLines(x,cellfun(@nanmean, thisFgM,'uniformoutput',0),...
    cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), thisFgM,'uniformoutput',0),...
    cols,pvals,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen);


end % fgMLabels



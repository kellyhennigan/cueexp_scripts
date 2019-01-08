
clear all
close all

p=getCuePaths();
figDir=p.figures;

cd ~/skew32

omit_subs={};
% omit_subs={'rb082212','pw060713'};
% omit_subs={'ec081912','rb082212'};


T=readtable('askew_fa50tcfcbeh_n32_150305.csv');
T(ismember(T.subject_code,omit_subs),:)=[];
subjects=T.subject_code;  
scale='bis';
scores=T.bis;
age=T.age;
method = 'josiah';

% 
% d=readtable('contrack_vta_nacc_tp10023-Sep-2014_16h07m21s.csv');
% 
% fgMatStr = 'lh';
% % fgMatStr = 'rh';
% % fgname = 'scoredFG_mesolimbic_vta_4mm_rh_nacc_aseg_fd_top500_clean';
% 
% fgMLabels{1}='FA'; fgMLabels{2}='MD'; fgMLabels{3}='RD'; fgMLabels{4}='AD';
% 
% mdi=find(strcmp(table2array(d(:,3)),'md') & cell2mat(cellfun(@(x) ~isempty(strfind(x,fgMatStr)),table2array(d(:,2)),'uniformoutput',0)));
%   fai=find(strcmp(table2array(d(:,3)),'fa') & cell2mat(cellfun(@(x) ~isempty(strfind(x,fgMatStr)),table2array(d(:,2)),'uniformoutput',0)));
% rdi=find(strcmp(table2array(d(:,3)),'rd') & cell2mat(cellfun(@(x) ~isempty(strfind(x,fgMatStr)),table2array(d(:,2)),'uniformoutput',0)));
%   adi=find(strcmp(table2array(d(:,3)),'ad') & cell2mat(cellfun(@(x) ~isempty(strfind(x,fgMatStr)),table2array(d(:,2)),'uniformoutput',0)));
% 
%   
% for i=1:numel(subjects)
%     si=find(ismember(d.Var1,subjects{i})); % subject row index
%     thismdi=si(ismember(si,mdi));
%     thisfai=si(ismember(si,fai));
%     thisrdi=si(ismember(si,rdi));
%     thisadi=si(ismember(si,adi));
%     if numel(thismdi)~=1 || numel(thisfai)~=1
%     error('hold up something is wrong')
% end
% fgMeasures{1}(i,:)=table2array(d(thisfai,4:end)); % fa
% fgMeasures{2}(i,:)=table2array(d(thismdi,4:end)); % md
% fgMeasures{3}(i,:)=table2array(d(thisrdi,4:end)); % md
% fgMeasures{4}(i,:)=table2array(d(thisadi,4:end)); % md
% 
% end


T=readtable('lrMFB_FA.csv');
fa=table2array(T(2

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(figDir, ['FG_' strrep(scale,'_','') '_corr'],method,fgMatStr);



%% load data & create out directory, if needed

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


n = numel(subjects); 


%% fig 1: plot behavior-fg correlation as heatmap over trajectory of fg
% measures

%%%%%%%%%%%%% params for figure 1
fgMCorr = 'MD'; % fg measure to correlate with behavior & plot as color map
fgMPlot = 'FA'; % fg measure to plot as values along pathway node
%%%%%%%%%%%%%%%

% get correlation between fgMCorr & scores along pathway nodes
[r,p]=corr(scores,fgMeasures{find(strcmp(fgMCorr,fgMLabels))});

% plot nodes on x-axis, fgMPlot values on y-axis, and correlation vals in color
fig1=dti_plotCorr(fgMeasures{strcmp(fgMPlot,fgMLabels)},r,[min(r) max(r)],fgMPlot);
title([fgMCorr '-' strrep(scale,'_',' ') ' correlation strength in color']);
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,[fgMPlot 'trajectory_' fgMCorr '_' scale '_corr']))
end



%% fig 2: plot correlations with fg measures

%%%%%%%%%%%%%%% params for figure 1
node = 'best'; % an integer specifying which node to plot, or 'best'
bestWhat = 'FA'; % which fg measure(s) to test for best
% node = [34:66];

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
suptitle([strrep(fgMatStr,'_',' ') ' node ' nodeStr])
if saveFigs
    print(gcf,'-dpng','-r300',fullfile(outDir,['node' nodeStr cvStr]))
end


nSubs = numel(subjects);








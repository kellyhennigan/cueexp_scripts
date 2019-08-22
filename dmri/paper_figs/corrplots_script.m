% script to generate correlation plots for MFB writeup

% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
pa = getCuePaths;
dataDir = pa.data; 
figDir = pa.figures_dti;


% which group(s) to plot?
group = {'patients'};


% directory & filename of fg measures
method = 'mrtrix_fa';

fgMatStrs = {'DALR_naccLR_belowAC_autoclean';...
    'DAL_naccL_belowAC_autoclean';...
    'DAR_naccR_belowAC_autoclean';...
    'DALR_naccLR_aboveAC_autoclean';...
    'DAL_naccL_aboveAC_autoclean';...
    'DAR_naccR_aboveAC_autoclean'};

% % 
% titleStrs = {'Inferior NAcc tract';...
%     'Superior NAcc tract';...
%     'Caudate tract';...
%     'Putamen tract'};

% fgMatStrs = {'DALR_naccLR_belowAC_dil2_autoclean';
%     'DAL_naccL_belowAC_dil2_autoclean';
%     'DAR_naccR_belowAC_dil2_autoclean'};
% 
% % 
% titleStrs = {'Inferior NAcc tract';
%     'Left inferior NAcc tract';
%     'Right inferior NAcc tract'};
    


% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
% 
% fgMatStrs = {'DAL_naccL_belowAC_dil2_autoclean';...
%     'DAR_naccR_belowAC_dil2_autoclean'};
% fgMatStrs = {'DAR_naccR_belowAC_autoclean'};

% titleStrs = {'inferior NAcc tract'};
titleStrs=fgMatStrs;

% which scale to correlate with fiber group measures?
scale = 'BIS'
% scale = 'years_of_use';
% scale = 'nacc_nvlout_betas';


% include control variables?
% covars = {};
% covars = {'age'};
% covars = {'dwimotion'};
 covars = {'age','dwimotion'};

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(figDir, ['FG_' strrep(scale,'_','') '_corr']);

omit_subs={'kj180621'};



%% load data & create out directory, if needed

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


%% fiber group loop

% for f=1
for f=1:numel(fgMatStrs)
    
    fgMatStr = fgMatStrs{f};
    titleStr = titleStrs{f};
    
    
    %%%%%%%%%%%% get fiber group measures & behavior scores
    fgMFile=fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']);
    [fgMeasures,fgMLabels,scores,subjects,gi]=loadFGBehVars(...
        fgMFile,scale,group,omit_subs);
    
    
    n = numel(subjects);
    
    
    %% figure: plot correlations with fg measures
    
    %%%%%%%%%%%%%%%
    node=26:75; % middle 50% of tract
% node=65;
% node=43:72;

% get a string describing node(s)
if isequal(26:75,node)
    nodeStr = 'mid50';
elseif numel(node)>1
    nodeStr = sprintf('%d_%d',node(1),node(end));
else
    nodeStr = num2str(node);
end

    
    % THIS ASSUMES THE MEASURES ARE STORED IN THIS ORDER
    fa = mean(fgMeasures{1}(:,node),2);
    md = mean(fgMeasures{2}(:,node),2);
    rd = mean(fgMeasures{3}(:,node),2);
    ad = mean(fgMeasures{4}(:,node),2);
    
    % include control variables? If so, regress out effect of control vars from
    % fgMeasures and scores
    if exist('covars','var') && ~isempty(covars)
        
        cvs=cell2mat(cellfun(@(x) getCueData(subjects,x), covars, 'uniformoutput',0));
        
        [rfa,pfa]=partialcorr(fa,scores,cvs);
        [rmd,pmd]=partialcorr(md,scores,cvs);
        [rrd,prd]=partialcorr(rd,scores,cvs);
        [rad,pad]=partialcorr(ad,scores,cvs);
        
        cvStr = ['_wCV_' covars{:}];
        
        
    else
        
        [rfa,pfa]=corr(fa,scores);
        [rmd,pmd]=corr(md,scores);
        [rrd,prd]=corr(rd,scores);
        [rad,pad]=corr(ad,scores);
        
        cvStr = '';
        
    end
    
    % strings of corr coefficients and p values for plots
    corrStr{1} = sprintf('r=%.2f, p=%.3f',rfa,pfa);
    corrStr{2} = sprintf('r=%.2f, p=%.3f',rmd,pmd);
    corrStr{3} = sprintf('r=%.2f, p=%.3f',rrd,prd);
    corrStr{4} = sprintf('r=%.2f, p=%.3f',rad,pad);
    
    % plot it
    fig{f} = subplotCorr([],{fa,1-md,rd,ad},{scores},{'FA','1-MD','RD','AD'},scale,corrStr);
    ti=suptitle(strrep(titleStr,'_',' '));
    set(ti,'FontSize',18)
    
    if saveFigs
        outName = [fgMatStr '_' group{:} cvStr '_' nodeStr];
        print(fig{f},fullfile(outDir,outName),'-depsc')
    end
    
    
    
end % fiber group loop




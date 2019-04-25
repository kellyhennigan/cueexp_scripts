% script to generate correlation plots for MFB writeup

% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
pa = getCuePaths;
dataDir = pa.data; 
figDir = pa.figures_dti;


% which group(s) to plot?
group = {'controls'};


% directory & filename of fg measures
method = 'mrtrix_fa';

% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
% fgMatStrs = {'DALR_naccLR_belowAC_dil2_autoclean';...
%     'DALR_naccLR_aboveAC_dil2_autoclean';...
%     'DALR_caudateLR_dil2_autoclean';...
%     'DALR_putamenLR_dil2_autoclean'};
% 
% 
% titleStrs = {'NAcc pathway (inferior)';...
%     'NAcc pathway (superior)';...
%     'Caudate pathway';...
%     'Putamen pathway'};
% fgMatStrs = {'DAL_naccL_belowAC_dil2_autoclean';...
%     'DAR_naccR_belowAC_dil2_autoclean'};
fgMatStrs = {'DAL_naccL_belowAC_dil2_autoclean'};


titleStrs = {'left inferior MFB'};


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

omit_subs={};



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
    
    % THIS ASSUMES THE MEASURES ARE STORED IN THIS ORDER
    fa = mean(fgMeasures{1}(:,26:75),2);
    md = mean(fgMeasures{2}(:,26:75),2);
    rd = mean(fgMeasures{3}(:,26:75),2);
    ad = mean(fgMeasures{4}(:,26:75),2);
    
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
    fig{f} = subplotCorr([],scores,{fa,1-md,rd,ad},scale,{'FA','1-MD','RD','AD'},corrStr);
    ti=suptitle(titleStr);
    set(ti,'FontSize',18)
    
    if saveFigs
        outName = [fgMatStr '_' group{:} cvStr];
        print(fig{f},fullfile(outDir,outName),'-depsc')
    end
    
    
    
end % fiber group loop




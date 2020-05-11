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

% fgMatStrs = {'DALR_naccLR_belowAC_autoclean'};

% fgMatStrs = {'DALR_naccLR_belowAC_autoclean';
%     'DALR_naccLR_aboveAC_autoclean';
%     'DALR_caudateLR_autoclean';
%     'DALR_putamenLR_autoclean';
%     };
%

fgMatStrs = {'DALR_naccLR_belowAC_autoclean';
    'DALR_naccLR_aboveAC_autoclean';
    'DALR_caudateLR_autoclean';
    'DALR_putamenLR_autoclean';
    'DAL_naccL_belowAC_autoclean';
    'DAL_naccL_aboveAC_autoclean';
    'DAL_caudateL_autoclean';
    'DAL_putamenL_autoclean';
    'DAR_naccR_belowAC_autoclean';
    'DAR_naccR_aboveAC_autoclean';
    'DAR_caudateR_autoclean';
    'DAR_putamenR_autoclean'};


% titleStrs = {'inferior NAcc tract'};
titleStrs=fgMatStrs;

% which scale to correlate with fiber group measures?
% scale = 'BIS_nonplan';
% scale='discount_rate';
% scale = 'years_of_use';
% scale = 'nacc_nvlout_betas';
scale='BIS';

% include control variables?
% covars = {};
% covars = {'age'};
% covars = {'dwimotion'};
covars = {'age','dwimotion'};

saveFigs =1;   % 1 to save figs to outDir otherwise 0
outDir = fullfile(figDir, 'PAPERFIG_bisfgcorr',[group{:}]);

omit_subs={''};



%% load data & create out directory, if needed

% create dir for saving out figs, if desired
if saveFigs
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end


%% fiber group loop

f=1;
for f=1:numel(fgMatStrs)
    
    fgMatStr = fgMatStrs{f};
    titleStr = titleStrs{f};
    
    
    %%%%%%%%%%%% get fiber group measures & behavior scores
    fgMFile=fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']);
    [fgMeasures,fgMLabels,scores,subjects,gi]=loadFGBehVars(...
        fgMFile,scale,group,omit_subs);
    
    %     scores=log(scores);
    
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
    md = mean(fgMeasures{2}(:,node),2); imd = 1-md;
    rd = mean(fgMeasures{3}(:,node),2);
    ad = mean(fgMeasures{4}(:,node),2);
    
    % include control variables? If so, regress out effect of control vars from
    % fgMeasures and scores
    if exist('covars','var') && ~isempty(covars)
        
        cvs=cell2mat(cellfun(@(x) getCueData(subjects,x), covars, 'uniformoutput',0));
        
        [rfa,pfa]=partialcorr(fa,scores,cvs);
        [rimd,pimd]=partialcorr(imd,scores,cvs);
        [rrd,prd]=partialcorr(rd,scores,cvs);
        [rad,pad]=partialcorr(ad,scores,cvs);
        
        cvStr = ['_wCV_' covars{:}];
        
        % regress out covariates for plotting correlation
        fa = glm_fmri_fit(fa,[ones(numel(subjects),1) cvs],[],'err_ts');
        imd = glm_fmri_fit(imd,[ones(numel(subjects),1) cvs],[],'err_ts');
        rd = glm_fmri_fit(rd,[ones(numel(subjects),1) cvs],[],'err_ts');
        ad = glm_fmri_fit(ad,[ones(numel(subjects),1) cvs],[],'err_ts');
        scores = glm_fmri_fit(scores,[ones(numel(subjects),1) cvs],[],'err_ts');
        
        
    else
        
        [rfa,pfa]=corr(fa,scores);
        [rimd,pimd]=corr(imd,scores);
        [rrd,prd]=corr(rd,scores);
        [rad,pad]=corr(ad,scores);
        
        cvStr = '';
        
    end
    
    % strings of corr coefficients and p values for plots
    corrStr{1} = sprintf('r=%.2f, p=%.3f',rfa,pfa);
    corrStr{2} = sprintf('r=%.2f, p=%.3f',rimd,pimd);
    corrStr{3} = sprintf('r=%.2f, p=%.3f',rrd,prd);
    corrStr{4} = sprintf('r=%.2f, p=%.3f',rad,pad);
    
    
    %% plot it
    
    x={fa,imd,rd,ad};
    y=scores;
    xlab={'FA','1-MD','RD','AD'};
    ylab=scale;
    col = [0 0 0]; % black dots and line
    fSize=14;
    
    [nRow,nCol] = getNiceSPConfig(numel(x));
    
    % set up fig
    figH=setupFig;
    
    for fi=1:numel(x)
        
        axH=subplot(nRow,nCol,fi);
        [axH,rpStr] = plotCorr(axH,x{fi},y,xlab{fi},ylab,corrStr{fi},col,[],[],fSize);
        %
        
        if ~isempty(cvStr)
            
        if strcmp(group,'controls')
            %     % FA xlim
            if strcmpi(xlab{fi},'FA')
                xlim([-.1 .16])
                set(gca,'XTick',[-.1:.1:.15])
            end
            
            %     % MD
            if strcmpi(xlab{fi},'1-MD')
                xlim([-.1 .1])
                set(gca,'XTick',[-.1:.1:.1])
            end
            
        elseif strcmp(group,'patients')
            %     % FA xlim
            if strcmpi(xlab{fi},'FA')
                xlim([-.2 .2])
                set(gca,'XTick',[-.2:.2:.2])
            end
            
            %     % MD
            if strcmpi(xlab{fi},'1-MD')
                xlim([-.22 .2])
                set(gca,'XTick',[-.2:.2:.2])
            end
        end
        
        end
    
    end
    
    % adjust fig size so that plots are square-shaped
    pos=get(figH,'Position');
    crr=nCol./nRow; %  column to row ratio
    newpos=[pos(1), pos(2), pos(3).*crr, pos(4)]
    set(figH,'Position',newpos)
    %     ss = get(0,'Screensize'); % screen size
    %     set(fig,'Position',[ss(3)-800 ss(4)-420 800 420]) % make figure 800 x 420 pixels
    
    % title
    ti=suptitle(strrep(titleStr,'_',' '));
    set(ti,'FontSize',12)
    
    if saveFigs
          outName = [fgMatStr '_' cvStr '_' nodeStr];
                print(figH,fullfile(outDir,outName),'-depsc')
%         print(figH,fullfile(outDir,outName),'-dpdf')
    end
    
    
    
end % fiber group loop




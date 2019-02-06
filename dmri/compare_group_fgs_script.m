% plot roi time courses by subject

% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;
outDir = [p.figures '/dti/group_diffs'];


% directory & filename of fg measures
method = 'mrtrix_fa';


fgMatStrs = {'DALR_naccLR_belowAC_dil2_autoclean';
    'DALR_naccLR_aboveAC_dil2_autoclean';
    'DALR_naccLR_dil2_autoclean';
    'DALR_putamenLR_dil2_autoclean'};
    'DALR_caudateLR_dil2_autoclean';

% fgMatStrs = {'DALR_caudateLR_dil2_autoclean'};

covars = {};

% corresponding labels for saving out
fgMatLabels = strrep(fgMatStrs,'_dil2_autoclean','');

% plot groups
group = {'controls','patients'};
groupStr = '_bygroup';

% group = {'controls','relapsers','nonrelapsers'};
% groupStr = '_byrelapse';


cols=cellfun(@(x) getCueExpColors(x), group, 'uniformoutput',0); % plotting colors for groups

omit_subs = {'as170730'}; % as170730 is too old for this sample

% fgMPlots = {'FA','MD','RD','AD'}; % fg measure to plot as values along pathway node
fgMPlots={'FA','MD'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end


j=1;
for j=1:numel(fgMatStrs)
    
    fgMatStr=fgMatStrs{j};
    fgMatLabel=fgMatLabels{j};
    
    
    %%%%%%%%%%%% get fiber group measures
    [fgMeasures,fgMLabels,~,subjects,gi]=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),'','all',omit_subs);
    nNodes = size(fgMeasures{1},2);
    
    %%%%%%%%%%%% hack so that epiphany patients are in the same
    %%%%%%%%%%%% patient group as VA patients
    gi(gi>0)=1;
    % ADD LINES HERE TO UPDATE GI IF STRCMP(GROUP)=='relapsers' or
    % 'nonrelapsers'; e.g.,
    % if strcmp(group, 'relapsers')
    % ri=getCueData(subjects,'relapse')
    % gi(ri==1) = 2;
    % end
    
    
    %%%%%%%%%%%%% control variables/covariates?
    
    
    % include control variables? If so, regress out effect of control vars from
    % fgMeasures
    if exist('covars','var') && ~isempty(covars)
        
        % design matrix w/control vars and a vector of ones for intercept
        X = [ones(numel(subjects),1),cell2mat(cellfun(@(x) getCueData(subjects,x), covars, 'uniformoutput',0))];
        
        % regress control variables out of fgMeasures
        fgMeasures = cellfun(@(y) glm_fmri_fit(y,X,[],'err_ts'), fgMeasures,'uniformoutput',0);
        
        cvStr = ['_wCV_' covars{:}];
        
    else
        
        cvStr = '';
        
    end
    
    
    %%%%%%%%%%% loop through diff measures to plot
    k=1;
    for k=1:numel(fgMPlots)
        
        fgMPlot=fgMPlots{k};
        
        % get desired diff measure to plot
        thisfgm=fgMeasures{strcmp(fgMPlot,fgMLabels)};
        
        % get stats for mid 50% of the pathway
        mid50 = mean(thisfgm(:,round(nNodes./4)+1:round(nNodes./4).*3),2);
        %           thisp=getPValsGroup(mid50); % one-way ANOVA
        [thisp,tab]=anova1(mid50,gi,'off'); % get stats
        F=tab{strcmp(tab(:,1),'Groups'),strcmp(tab(1,:),'F')}; % F stat
        df_g = tab{strcmp(tab(:,1),'Groups'),strcmp(tab(1,:),'df')}; % group
        df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
        anova_res = sprintf('F(%d,%d) = %.1f; p = %.3f\n',df_g,df_e,F,thisp);
        
        % only plot p-value for mid 50% comparison
        p=nan(1,nNodes);
        p(round(nNodes./2)) = thisp;
        
        
        % get cell for each group's diff measure
        for g=1:numel(unique(gi))
            groupfgm{g} = thisfgm(gi==g-1,:);
            n(g)=numel(gi(gi==g-1));
        end
        
        
        mean_fg = cellfun(@mean, groupfgm,'uniformoutput',0);
        se_fg = cellfun(@(x) std(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        %         mean_fg = cellfun(@nanmean, groupfgm,'uniformoutput',0);
        %         se_fg = cellfun(@(x) nanstd(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        
        
        %%%%%%%%%% plotting params
        xlab = 'fiber group nodes';
        ylab = fgMPlot;
        figtitle = [strrep(fgMatLabel,'_',' ') ' by group; ' strrep(cvStr,'_',' ') anova_res];
        savePath = fullfile(outDir,[fgMatLabel '_' fgMPlot groupStr cvStr]);
        plotToScreen=1;
        lineLabels=strcat(group,repmat({' n='},1,numel(group)),cellfun(@(x) num2str(size(x,1)), groupfgm, 'uniformoutput',0));
        %         cols = {[0 0 1];[1 0 0] }';
        
        
        %%%%%%%%%%% finally, plot the thing!
        [fig,leg]=plotNiceLines(1:nNodes,mean_fg,se_fg,cols,p,lineLabels,...
            xlab,ylab,figtitle,savePath,plotToScreen);
        
        % print(gcf,'-dpng','-r300',[fgMPlot '_bygroup']);
        
    end % fg measures (fgMPlots)
    
end % fiber groups (fgMatStrs)






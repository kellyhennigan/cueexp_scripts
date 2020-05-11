% plot roi time courses by subject

% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;


% directory & filename of fg measures
method = 'mrtrix_fa';

targets={'putamen'};

fgMatStrs = {'DALR_%sLR_autoclean'};

% targets={'nacc';
%     'nacc';
%     'caudate';
%     'putamen'};
% 
% fgMatStrs = {'DALR_%sLR_belowAC_autoclean';
%     'DALR_%sLR_aboveAC_autoclean';
%     'DALR_%sLR_autoclean';
%     'DALR_%sLR_autoclean'};

% fgMatStrs = {'DAL_%sL_belowAC_autoclean';
%     'DAL_%sL_aboveAC_autoclean';
%     'DAL_%sL_autoclean';
%     'DAL_%sL_autoclean'};

% % %
% targets={
%     'caudate';
%     'putamen'};
%
% fgMatStrs = {
%     'DALR_%sLR_autoclean';
%     'DALR_%sLR_autoclean'};
%

% fgMatStrs = {'DAL_%sL_dil2_autoclean';
%     'DAR_%sR_dil2_autoclean';
%     'DAL_%sL_dil2_autoclean';
%     'DAR_%sR_dil2_autoclean'};
% covars = {'age'};
% covars={'age','dwimotion'};
covars={};

% corresponding labels for saving out
fgMatLabels = strrep(fgMatStrs,'_autoclean','');

% plot groups
% group = {'controls','patients'};
% groupStr = 'bygroup';
% lspec = {'-','--'};

% group = {'controls'};
% groupStr = 'controls';
% lspec = {'-'};

% group = {'patients'};
% groupStr = 'patients';
% lspec = {'-'};

% % group = {'controls','relapsers','nonrelapsers'};
% % groupStr = 'byrelapsewcontrols';
% % lspec = {'-','--'};

group = {'nonrelapsers','relapsers'};
groupStr = 'byrelapse';
lspec = {'-','--'};

cols=cellfun(@(x,y) getDTIColors(x,y), targets,fgMatStrs, 'uniformoutput',0); % plotting colors for groups

omit_subs = {''};

% fgMPlots = {'FA','MD','RD','AD'}; % fg measure to plot as values along pathway node
fgMPlots={'FA'};

doStats=0;

outDir = [p.figures_dti '/PAPERFIG_fgm_trajectories/' groupStr];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end


j=1;
for j=1:numel(fgMatStrs)
    
    fgMatStr=sprintf(fgMatStrs{j},targets{j});
    fgMatLabel=sprintf(fgMatLabels{j},targets{j});
    
    % load fg measures
    [fgMeasures,fgMLabels,~,subjects]=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),'',group{1},omit_subs);
    gi=ones(numel(subjects),1);
    for g=2:numel(group)
        [groupFgM,~,~,groupsubs]=loadFGBehVars(...
            fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),'',group{g},omit_subs);
        fgMeasures{1}=[fgMeasures{1};groupFgM{1}];
        fgMeasures{2}=[fgMeasures{2};groupFgM{2}];
        fgMeasures{3}=[fgMeasures{3};groupFgM{3}];
        fgMeasures{4}=[fgMeasures{4};groupFgM{4}];
        gi=[gi;ones(numel(groupsubs),1).*g];
        subjects=[subjects;groupsubs];
    end
    
    nNodes = size(fgMeasures{1},2);
    
    
    
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
        
        % if measure is MD, make this inverse MD
        if strcmp(fgMPlot,'MD')
            fgMPlot = '1-MD';
            thisfgm=1-thisfgm;
        end
        
        % average across mid 50% of the pathway and test for group diffs
        p=nan(1,nNodes);
        if doStats
            mid50 = mean(thisfgm(:,round(nNodes./4)+1:round(nNodes./4).*3),2);
            
            groupindices=unique(gi);
            
            % if there's 2 groups, do a ttest. Otherwise do a one-way anova
            if numel(groupindices)==2
                [h,thisp,~,stats]=ttest2(mid50(gi==groupindices(1)),mid50(gi==groupindices(2)))
                test_res = sprintf('t(%d) = %.3f; p = %.3f\n',stats.df,stats.tstat,thisp);
            else
                %           thisp=getPValsGroup(mid50); % one-way ANOVA
                [thisp,tab]=anova1(mid50,gi,'off'); % get stats
                F=tab{strcmp(tab(:,1),'Groups'),strcmp(tab(1,:),'F')}; % F stat
                df_g = tab{strcmp(tab(:,1),'Groups'),strcmp(tab(1,:),'df')}; % group
                df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
                test_res = sprintf('F(%d,%d) = %.1f; p = %.3f\n',df_g,df_e,F,thisp);
            end
            
            % only plot p-value for mid 50% comparison
            %             p(round(nNodes./2)) = thisp;
        end
        
        
        % get cell for each group's diff measure
        for g=1:numel(unique(gi))
            groupfgm{g} = thisfgm(gi==g,:);
            n(g)=numel(gi(gi==g));
        end
        
        
        mean_fg = cellfun(@mean, groupfgm,'uniformoutput',0);
        se_fg = cellfun(@(x) std(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        %         mean_fg = cellfun(@nanmean, groupfgm,'uniformoutput',0);
        %         se_fg = cellfun(@(x) nanstd(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        
        
        %%%%%%%%%% plotting params
        xlab = 'tract node location (midbrain to striatum)';
        
        ylab = fgMPlot;
        
        cols=repmat({getDTIColors(targets{j},fgMatStr)},size(group)); % plot groups as same color
        if doStats
            figtitle = [strrep(fgMatLabel,'_',' ') ' ' strrep(groupStr,'_',' ') '; ' strrep(cvStr,'_',' ') test_res];
        else
            figtitle = [strrep(fgMatLabel,'_',' ') ' ' strrep(groupStr,'_',' ') ];
        end
        savePath = fullfile(outDir,[fgMatLabel '_' fgMPlot '_' cvStr]);
        plotToScreen=1;
        lineLabels=strcat(group,repmat({' n='},1,numel(group)),cellfun(@(x) num2str(size(x,1)), groupfgm, 'uniformoutput',0));
        %         cols = {[0 0 1];[1 0 0] }';
        
        %         xlab='';
        %         ylab='';
        %         figtitle='';
        %
        %%%%%%%%%%% finally, plot the thing!
        [fig,leg]=plotNiceLines(1:nNodes,mean_fg,se_fg,cols,p,lineLabels,...
            xlab,ylab,figtitle,[],plotToScreen,lspec);
        hold on
        
        % get same y-axis for all fiber groups for FA w/no covars
        if isempty(cvStr)
            
            pos=get(fig,'Position')
            newpos=[pos(1), pos(2), pos(3)./2, pos(4)./2]; % reduce the figure size to be more in line with publication size
            set(fig,'Position',newpos)
            %         set(gca,'FontSize',30)
            set(gca,'XTick',[])
            title('')
            xlabel('')
            ylabel('')
            
            legend HIDE
        end
        
        if  strcmp(fgMPlot,'FA')
            ylim([.44 .62])
            set(gca,'YTick',[0:.05:.6])
        end
        
        if  strcmp(fgMPlot,'1-MD')
            ylim([.38 .56])
            set(gca,'YTick',[0:.1:.6])
        end
        yl=ylim
        plot([26 26],[yl(1) yl(2)],'--','color',[.3 .3 .3],'linewidth',2)
        plot([75 75],[yl(1) yl(2)],'--','color',[.3 .3 .3],'linewidth',2)
        ylim(yl)
        
        print(gcf,'-dpng','-r300',savePath);
        
    end % fg measures (fgMPlots)
    
end % fiber groups (fgMatStrs)


% plot roi time courses by subject

% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;
outDir = [p.figures_dti '/fgm_trajectories/bygroup'];


% directory & filename of fg measures
method = 'mrtrix_fa';


% targets={'nacc'};
% 
% fgMatStrs = {'mpfc8mmL_%sL_autoclean'};
% 

% targets={'nacc';
%     'nacc';
%     'caudate';
%     'putamen'};
% 
% fgMatStrs = {'DALR_%sLR_belowAC_autoclean';
%     'DALR_%sLR_aboveAC_autoclean';
%     'DALR_%sLR_autoclean';
%     'DALR_%sLR_autoclean'};

% targets={'nacc'};
% 
fgMatStrs = {'sginsLR_%sLR_autoclean23';
    'sginsL_%sL_autoclean23';
    'sginsR_%sR_autoclean23'};

targets={'vlpfc';'vlpfc';'vlpfc'};

% fgMatStrs = {'PauliAtlasDALR_%sLR_belowAC_autoclean'};


 covars={'age','dwimotion','gender'};
% covars={'age','dwimotion','bis'};
% covars={};

% corresponding labels for saving out
fgMatLabels = strrep(fgMatStrs,'_autoclean','');

% % plot groups
group = {'controls','patients'};
groupStr = '_bydiagnosis';
lspec = {'-','--'};
% 
% group = {'controls'};
% groupStr = 'controls';
% lspec = {'-'};

% group = {'controls','relapsers','nonrelapsers'};
% groupStr = '_byrelapse';
% lspec = {'-','--'};

% group = {'relapsers','nonrelapsers'};
% groupStr = '_byrelapse';
% lspec = {'-','--'};

cols=cellfun(@(x,y) getDTIColors(x,y), targets,fgMatStrs, 'uniformoutput',0); % plotting colors for groups

omit_subs = {''};

fgMPlots = {'FA','MD'}; % fg measure to plot as values along pathway node
% fgMPlots={'AD'};

doStats=1;
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
    
    
    %%%%%%%%%%%% get fiber group measures
    [fgMeasures,fgMLabels,~,subjects,gi]=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']),'',[group{:}],omit_subs);
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
            groupfgm{g} = thisfgm(gi==g-1,:);
            n(g)=numel(gi(gi==g-1));
        end
        
        
        mean_fg = cellfun(@mean, groupfgm,'uniformoutput',0);
        se_fg = cellfun(@(x) std(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        %         mean_fg = cellfun(@nanmean, groupfgm,'uniformoutput',0);
        %         se_fg = cellfun(@(x) nanstd(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        
        
        %%%%%%%%%% plotting params
                xlab = 'tract node location';
        
        ylab = fgMPlot;

        cols=repmat({getDTIColors(targets{j},fgMatStr)},size(group)); % plot groups as same color
        if doStats
            figtitle = [strrep(fgMatLabel,'_',' ') ' ' strrep(groupStr,'_',' ') '; ' strrep(cvStr,'_',' ') test_res];
        else
            figtitle = [strrep(fgMatLabel,'_',' ') ' ' strrep(groupStr,'_',' ') ];
        end
        savePath = fullfile(outDir,[fgMatLabel '_' fgMPlot groupStr cvStr]);
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
        pos=get(fig,'Position')
  
%         newpos=[pos(1), pos(2), pos(3)./2, pos(4)./2]; % reduce the figure size to be more in line with publication size
%         set(fig,'Position',newpos)
% 
% %         set(gca,'FontSize',30)
%         set(gca,'XTick',[])
%         set(gca,'YTick',[0:.05:.6])
%         
%         
        % get same y-axis for all fiber groups for FA w/no covars
        %         if isempty(cvStr) && strcmp(fgMPlot,'FA')
        %             ylim([.2 .62])
        %             set(gca,'YTick',[.2:.2:.6])
        %         end
%         ylim([.18 .35])
        
        yl=ylim
        plot([26 26],[yl(1) yl(2)],'--','color',[.3 .3 .3],'linewidth',2)
        plot([75 75],[yl(1) yl(2)],'--','color',[.3 .3 .3],'linewidth',2)
        ylim(yl)
%         legend HIDE
        print(gcf,'-dpng','-r300',savePath);
        
    end % fg measures (fgMPlots)
    
end % fiber groups (fgMatStrs)



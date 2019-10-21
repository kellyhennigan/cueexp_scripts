% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
task = 'mid';
p = getCuePaths();
dataDir = p.data;
% figDir = '/Users/kelly/cueexp/paper_figs_tables_stats/timecourses/figs';
% figDir='/Users/kelly/cueexp/writeup/SUBMISSION_JAMA/revisions/FIGURES/fig3';

% tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_woOutliers' ];
% tcDir = ['timecourses_' task '_afni_woOutliers' ];
tcDir = ['timecourses_' task '_afni' ];


tcPath = fullfile(dataDir,tcDir);


% which roi to process?
roiName = 'VTA';

figDir = ['/Users/kelly/cueexp/timecourses_mid_afni/' roiName]


nTRs = 8; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10

% omitSubs = {'cd171130','ab171208','kk180117','rl180205','jc180212','ct180224','rm180316','cm180506','sh180518','rm180525','dl180602','ap180613','jj180618','lh180622','dr180715'}; % any subjects to omit?
omitSubs = {''};

plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures

numberFigs = 1; % 1 to number the figs' outnames (useful for viewing in Preview)

% outDir_suffix = '_age_match';
% outDir_suffix = '_nr16';
outDir_suffix = '';

plotColorSet = 'color'; % 'grayscale' or 'color'

plotErr = 'bar'; % 'bar' or 'shaded'

plotToScreen=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get task specific conditions/groups to plot

% plotGroups & plotStims should be cell arrays specifying
% the desired groups and stims to plot in figures. plotStimStrs gives a
% string that describes the stim in a given plot. Each row of the cell
% array should have info for a single figure, e.g.:

% % % plotGroups = {'controls';
% % %     'controls patients'};
% % %
% % % plotStims = {'alcohol drugs food neutral';
% % %     'drugs'};

% would be for making 2 figures: the 1st would plot alc, drugs, etc. for
% just the controls and the 2nd would plot drugs for controls vs patients.

[plotGroups,plotStims,plotStimStrs]=getTCPlotSpec(task);

plotGroups = {'controls'};
plotStims={'gain0 gain1 gain5'};

% plotStims = {'drugs'};
plotStimStrs = plotStims;

% plotGroups = {'relapsers non-relapsers'};
% plotStims = {'drugs'};
% plotStimStrs = plotStims;
%
nFigs = numel(plotStimStrs); % number of figures to be made

%% get ROI time courses


inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI


%% define time courses to plot

for f=1
% for f=[1 3 6]
%     for f = 1:nFigs
    
    % get the plot name and stims & groups to plot for this figure
    groups = splitstring(plotGroups{f});
    stims = splitstring(plotStims{f});
    stimStr = plotStimStrs{f};
    
    tc = {}; % time course cell array
    
    for g=1:numel(groups)
        
        % get subject IDs for this group
        subjects = getCueSubjects(task,groups{g});
        subjects(ismember(subjects,omitSubs))=[];  % omit subjects?
        n(g) = numel(subjects); % n subjects for this group
        
        for c = 1:numel(stims)
            
            % if there's a minus sign, assume desired plot is stim1-stim2
            if strfind(stims{c},'-')
                stim1 = stims{c}(1:strfind(stims{c},'-')-1);
                stim2 = stims{c}(strfind(stims{c},'-')+1:end);
                tc1=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),subjects,1:nTRs);
                tc2=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),subjects,1:nTRs);
                tc{g,c}=tc1-tc2;
            else
                stimFile = fullfile(inDir,[stims{c} '.csv']);
                tc{g,c}=loadRoiTimeCourses(stimFile,subjects,1:nTRs);
            end
            
        end % stims
        
    end % groups
    
    
    % make sure all the time courses are loaded
    if any(cellfun(@isempty, tc))
        tc
        error('\hold up - time courses for at least one stim/group weren''t loaded.')
    end
    
    mean_tc = cellfun(@nanmean, tc,'uniformoutput',0);
    se_tc = cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), tc,'uniformoutput',0);
    
    %  upsample time courses
    if (useSpline)
        t_orig = t;
        t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
        mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
        se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
    end
    
    
    %% set up all plotting params
    
    % fig title
    figtitle = [strrep(roiName,'_',' ') ' response to ' stimStr ' in ' groups{1} ' (n=' num2str(n(1)) ')'];
    if numel(groups)>1
        for g=2:numel(groups)
            figtitle = [figtitle ', ' groups{g} ' (n=' num2str(n(g)) ')'];
        end
    end
    
    % x and y labels
    %         xlab = 'time (s) relative to trial onset';
    xlab = 'time (s)';
    ylab = '%\Delta BOLD';
    
    
    % labels for each line plot (goes in the legend)
    lineLabels = cell(numel(groups),numel(stims));
    if numel(stims)>1
        lineLabels = repmat(stims,numel(groups),1); lineLabels = strrep(lineLabels,'_',' ');
    end
    if numel(groups)>1
        for g=1:numel(groups)
            lineLabels(g,:) = cellfun(@(x) [x groups{g} ], lineLabels(g,:), 'uniformoutput',0);
            lineLabels(g,:)=strrep(lineLabels(g,:),'_',' ');
        end
    end
    
    
    % line colors & line specs
    cols = reshape(getCueExpColors(lineLabels,'cell',plotColorSet),size(tc,1),[]);
    lspec = reshape(getCueLineSpec(lineLabels),size(tc,1),[]);
    
    %%%%%%%%%% color drug lines red
%     if f==6
%         cols{1}=[170 170 170]./255; % light gray
%     end
     %%%%%%%%%% for patient vs control drugs, have both lines red w/controls dotted line
    if f==6
        cols{1}=cols{2};
        lspec{1}='--';
    end
   
    
    % get stats, if plotting
    p=[];
    if plotStats
        if numel(groups)>1
            p = getPValsGroup(tc); % one-way ANOVA
        else
            p = getPValsRepMeas(tc); % repeated measures ANOVA
        end
    end
    
    
    % filepath, if saving
    savePath = [];
    if saveFig
        % nomenclature: roiName_stimStr_groupStr
        outDir = fullfile(figDir,[roiName outDir_suffix]);
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        if numel(groups)==1
            outName = [roiName '_' stimStr '_' groups{1}];
        else
            outName = [roiName '_' stimStr '_bygroup'];
        end
        if numberFigs==1
            outName = [num2str(f) ' ' outName];
        end
        savePath = fullfile(outDir,outName);
    end
    
    
    %% finally, plot the thing!
    
    fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);
    
    switch plotErr
        case 'bar'
            [fig,leg]=plotNiceLinesEBar(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,[],plotToScreen,lspec);
        case 'shaded'
            [fig,leg]=plotNiceLines(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,[],plotToScreen,lspec);
    end
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  EXTRA FORMATTING HAPPENS HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%% ROI specific y params
    % get y-axis params that are roi specific
    if strcmpi(roiName,'mpfc')
        
        if any(strcmp(groups,'relapsers_3months'))
            YL = [-.23 .21]; % YL is ylim
            YT = -.2:.05:.2; % YT determines YTicks
        else
            YL = [-.22 .17]; % YL is ylim
            YT = -.2:.05:.2; % YT determines YTicks
        end
        
    elseif strcmpi(roiName,'nacc_desai')
        
        if any(strcmp(groups,'relapsers_3months'))
            YL = [-.16 .16]; % YL is ylim
            YT = -.15:.05:.15; % YT determines YTicks
        else
            YL = [-.13 .11]; % YL is ylim
            YT = -.1:.05:.1; % YT determines YTicks
        end
        
    elseif strcmpi(roiName,'vta')
        
        if any(strcmp(groups,'relapsers_3months'))
            YL = [-.17 .21]; % YL is ylim
            YT = -.15:.05:.2; % YT determines YTicks
        else
            YL = [-.15 .15]; % YL is ylim
            YT = -.15:.05:.15; % YT determines YTicks
        end
        
    elseif strcmpi(roiName,'ins_desai')
        
        if any(strcmp(groups,'relapsers_3months'))
            YL = [-.16 .23]; % YL is ylim
            YT = -.2:.05:.2; % YT determines YTicks
        else
            YL = [-.1 .14]; % YL is ylim
            YT = -.1:.05:.1; % YT determines YTicks
        end
        
    end
    
    
    %%%%%%% manually change y axis here:
    if ~notDefined('YT')
        set(gca,'YTick',YT)
    end
    
    if ~notDefined('YL')
        ylim([YL(1) YL(2)])
    end
    
    
    %%%%%%% grayed out rectangles
    yl = ylim;
    
    gxs = [5 13]; % x-axis limits for graying out
    
    % vertices
    v = [t(1) yl(1);
        t(1) yl(2);
        gxs(1) yl(2);
        gxs(1) yl(1);
        gxs(2) yl(1);
        gxs(2) yl(2);
        t(end) yl(2);
        t(end) yl(1)];
    
    patch('Faces',[1:4;5:8],'Vertices',v,'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5)
    
    
    %%%%%%% make lines thicker
    lw=4;
    ch=get(gca,'Children');
    set(ch(:),'LineWidth',lw)
    
    
    % ylim
    ylim([yl(1) yl(2)])
    
    % xlim and xtick
    xlim([t(1) t(end)])
    set(gca,'xtick',t)
    
    
    %%%%%%%%%% save a version that has the title and outside legend
    set(leg,'Location','EastOutside')
    print(gcf,'-dpng','-r300',[savePath '_leg']);
%       print(gcf,'-depsc','-r300',[savePath '_leg']);
%     saveas(gcf,[savePath '_leg'],'pdf');
    
    % title and legend off
    legend(gca,'off')
    title('')
    
    %%%%%%%%%% change font sizes
    fsize = 26;
    set(gca,'fontName','Helvetica','fontSize',fsize)
    %         title('NAc response to drugs-neutral trials','fontName','Helvetica','fontSize',fsize)
    
    % xlabel
    xlabel(xlab,'fontName','Helvetica','FontSize',fsize)
    %       xlabel([],'fontName','Helvetica','FontSize',fsize)
    %        xticklabels('')
    
    % y label
    ylabel([],'fontName','Helvetica','FontSize',fsize)
    
    
    % re-save fig
%     print(gcf,'-dpng','-r300',savePath);
saveas(gcf,savePath,'pdf');
%       print(gcf,'-depsc','-r300',savePath);
    
    fprintf('done.\n\n')
    
    
end % figures



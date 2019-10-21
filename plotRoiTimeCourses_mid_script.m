% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
task = whichCueTask();

p = getCuePaths();

dataDir = p.data;
figDir = p.figures;

% tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_woOutliers' ];
% tcDir = ['timecourses_' task '_afni_woOutliers' ];
tcDir = ['timecourses_' task '_afni' ];


tcPath = fullfile(dataDir,tcDir);


% which rois to process?
roiNames = whichRois(tcPath);


nTRs = 8; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10

% omitSubs = {'zl150930','ps151001','aa151010','al151016','jv151030',...
%     'kl160122','ss160205','bp160213','cs160214','yl160507','li160927',...
%     'gm161101'};
omitSubs = {''}; % any subjects to omit?

plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures

numberFigs = 1; % 1 to number the figs' outnames (useful for viewing in Preview)

% outDir_suffix = '_age_match';
% outDir_suffix = '_nr16';
outDir_suffix = '';

plotColorSet = 'color'; % 'grayscale' or 'color'

plotErr = 'bar'; % 'bar' or 'shaded'

plotToScreen=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
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

% [plotGroups,plotStims,plotStimStrs]=getTCPlotSpec(task);

plotGroups = {'controls'; 'controls'};
plotStims={'gain0 gain5'};

% plotStims = {'drugs'};
plotStimStrs = plotStims;
%
nFigs = numel(plotStimStrs); % number of figures to be made

%% get ROI time courses

% r=1;
for r = 1:numel(roiNames)
    
    roiName = roiNames{r};
    
    inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI
    
    
    %% define time courses to plot
    
    for f = 1:nFigs
%         for f = 11:nFigs
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
        se_tc = cellfun(@(x) nanstd(x)./sqrt(size(x,1)), tc,'uniformoutput',0);
        
        %  upsample time courses
        if (useSpline)
            t_orig = t;
            t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
            mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
            se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
        end
        
        
        %% set up all plotting params
        
        % fig title
        figtitle = [strrep(roiName,'_',' ') ' response to ' stimStr ' in ' strrep(groups{1},'_',' ') ' (n=' num2str(n(1)) ')'];
        if numel(groups)>1
            for g=2:numel(groups)
                figtitle = [figtitle ', ' strrep(groups{g},'_',' ') ' (n=' num2str(n(g)) ')'];
            end
        end
        
        % x and y labels
        xlab = 'time (s)';
        ylab = '%\Delta BOLD';
        
        
        % labels for each line plot (goes in the legend)
        lineLabels = cell(numel(groups),numel(stims));
        if numel(stims)>1
            lineLabels = repmat(stims,numel(groups),1); lineLabels = strrep(lineLabels,'_',' ');
        end
        if numel(groups)>1
            for g=1:numel(groups)
                lineLabels(g,:) = cellfun(@(x) [x strrep(groups{g},'_',' ') ], lineLabels(g,:), 'uniformoutput',0);
            end
        end
        
        
        % line colors & line specs
        cols = reshape(getCueExpColors_old(numel(tc),'cell'),size(tc,1),[]);
%         lspec = reshape(getCueLineSpec(lineLabels),size(tc,1),[]);
        cols{1}=[1 0 0];
        cols{end}=[0.1490    0.5451    0.8235];
        

        
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
            outDir = fullfile(figDir,tcDir,[roiName outDir_suffix]);
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
%                 [fig,leg]=plotNiceLinesEBar(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen,lspec);   
                 [fig,leg]=plotNiceLinesEBar(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen);   
            case 'shaded'
                [fig,leg]=plotNiceLines(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen,lspec);
        end
        
    
    %%%%%%%%%% change font sizes
    fsize = 26;
    set(gca,'fontName','Helvetica','fontSize',fsize)
    print(gcf,'-dpng','-r300',savePath);
    
             % title and legend off
    legend(gca,'off')
    title('')
   print(gcf,'-dpng','-r300',[savePath '_noleg']);
        
   fprintf('done.\n\n');
        
        
    end % figures
    
end % roiNames



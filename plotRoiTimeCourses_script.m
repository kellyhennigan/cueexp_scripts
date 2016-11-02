% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
[p,task,subjects,gi]=whichCueSubjects();
dataDir = p.data;
figDir = p.figures;

% filepath to pre-processed functional data where %s is subject then task
if isempty(strfind(dataDir,'claudia'))
    groupStr = '';
else
    groupStr = 'alc';
end


% rois to potentially process
allRoiNames = {'nacc','acing','dlpfc','caudate','ins','LC','mpfc','VTA','SN',...
    'naccL','naccR','insR','insL'};

% allRoiNames = {'amygL','amygR','ifgL','ifgR','mfgL','mfgR','sfgL','sfgR'};

disp(allRoiNames');
fprintf('\nwhich ROIs to process? \n');
roiNames = input('enter roi name(s), or hit return for all ROIs above: ','s');

if isempty(roiNames)
    roiNames = allRoiNames;
else
    roiNames = splitstring(roiNames);
end


% tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_afni_woOutliers' ];
tcDir = ['timecourses_' task '_afni' ];

nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10

% omitSubs = {'cm160510','zm160627'}; % any subjects to omit?
omitSubs = {''}; % any subjects to omit?

plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures

numberFigs = 1; % 1 to number the figs' outnames (useful for viewing in Preview)



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

[plotGroups,plotStims,plotStimStrs]=getTCPlotSpec(task,groupStr);

% plotGroups = {'relapsers non-relapsers controls'};
% plotStims = {'drugs-neutral'};
% plotStimStrs = plotStims;

nFigs = numel(plotStimStrs); % number of figures to be made

%% get ROI time courses

r=1;
for r = 1:numel(roiNames)
    
    roiName = roiNames{r};
    
    inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI
    
    
    %% define time courses to plot
    
    f=1
    for f = 1:nFigs
        
        % get the plot name and stims & groups to plot for this figure
        groups = splitstring(plotGroups{f});
        stims = splitstring(plotStims{f});
        stimStr = plotStimStrs{f};
        
        tc = {}; % time course cell array
        subjects = {};
        
        g=1;
        for g=1:numel(groups)
            
            for c = 1:numel(stims)
                
                % if there's a minus sign, assume desired plot is stim1-stim2
                if strfind(stims{c},'-')
                    stim1 = stims{c}(1:strfind(stims{c},'-')-1);
                    stim2 = stims{c}(strfind(stims{c},'-')+1:end);
                    [tc1,subjects{g,c}]=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),groups{g},nTRs);
                    [tc2,~]=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),groups{g},nTRs);
                    tc{g,c}=tc1-tc2;
                else
                    stimFile = fullfile(inDir,[stims{c} '.csv']);
                    [tc{g,c},subjects{g,c}]=loadRoiTimeCourses(stimFile,groups{g},nTRs);
                end
                
            end % stims
            
            
            % omit subjects?
            if any(ismember(subjects{g,1},omitSubs))
                omit_idx=find(ismember(subjects{g,1},omitSubs));
                for i = 1:size(subjects(g,:),2)
                    subjects{g,i}(omit_idx)=[];
                    tc{g,i}(omit_idx,:)=[];
                end
            end
            
            n(g) = size(tc{g,1},1); % n subjects for this group
            
        end % groups
    
    % make sure all the time courses are loaded
    if any(cellfun(@isempty, tc))
        tc
        error('\hold up - time courses for at least one stim/group weren''t loaded.')
    end
    
    
    mean_tc = cellfun(@nanmean, tc,'uniformoutput',0);
    se_tc = cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), tc,'uniformoutput',0);
    
    if (useSpline) %  upsample time courses
        t_orig = t;
        t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
        mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
        se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
    end
    
    
    %% set up all plotting params
    
    % fig title
    figtitle = [roiName ' response to ' stimStr ' in ' groups{1} ' (n=' num2str(n(1)) ')'];
    if numel(groups)>1
        for g=2:numel(groups)
            figtitle = [figtitle ', ' groups{g} ' (n=' num2str(n(g)) ')'];
        end
    end
    
    % x and y labels
    xlab = 'time (in seconds) relative to trial onset';
    ylab = '%\Delta BOLD';
    
    
    % labels for each line plot (goes in the legend)
    pLabels = cell(numel(groups),numel(stims));
    if numel(stims)>1
        pLabels = repmat(stims,numel(groups),1); pLabels = strrep(pLabels,'_',' ');
    end
    if numel(groups)>1
        for g=1:numel(groups)
            pLabels(g,:) = cellfun(@(x) [x ' ' groups{g} ], pLabels(g,:), 'uniformoutput',0);
        end
    end
    
    
    % line colors
    cols = reshape(getCueExpColors(numel(tc),'cell'),size(tc,1),[]);
    
    
    % get stats, if plotting
    p=[];
    if plotStats
        if numel(groups)>1
            p = getPValsGroup(tc); % one-way ANOVA
        else
            p = getPValsRepMeas(tc); % repeated measures ANOVA
        end
    end
    
    
    % filename, if saving
    savePath = [];
    if saveFig
        % nomenclature: roiName_stimStr_groupStr
        outDir = fullfile(figDir,tcDir,roiName);
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
    
    [fig,leg]=plotNiceLines(t,mean_tc,se_tc,cols,p,pLabels,xlab,ylab,figtitle,savePath,0);
    
    fprintf('done.\n\n')
    
    
end % figures

end %roiNames

%         fsize = 26;
%         set(gca,'fontName','Arial','fontSize',fsize)
%         title('NAc response to drugs-neutral trials','fontName','Arial','fontSize',fsize)
%         xlabel(xlab,'fontName','Arial','FontSize',fsize)
%         ylabel(ylab,'fontName','Arial','FontSize',fsize)
%         
%      set(leg,'String',{'relapsers (n=8)','non-relapsers (n=12)','controls (n=33)'})
%         set(gca,'XTick',[0:2:18])
%         xlim([4 18])
%         ylim([-.2 .51])
%         set(leg,'Location','EastOutside')
%         print(gcf,'-dpng','-r300',savePath);
%         



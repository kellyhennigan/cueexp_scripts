% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.


clear all
close all

% probably shouldn't have to edit these too much...
p = getCuePaths;
dataDir = p.data;
figDir = p.figures;

nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%

task = 'cue'; % must be either 'cue','mid', or 'midi'


% rois to potentially process
allRoiNames = {'nacc','acing','dlpfc','caudate','ins','LC','mpfc','VTA','SN',...
    'naccL','naccR','insR','insL'};
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

plotStats = 1;

saveFig = 1;

% break into relapse vs non-relapse
% relapse_idx = [ 0 1 1 1 0 0 1 1 0 0 1 0 0 0 nan nan];

relapse_idx=[0 1 1 1 0 0 1 1 0 0 0 1 0 0 0 nan 0];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get task specific conditions/groups to plot

% [plotGroups,plotStims,plotStimStrs]=getTCPlotSpec(task);

% plotGroups & plotStims should be cell arrays specifying
% the desired groups and stims to plot in figures. Each row of the cell
% array should have info for a single figure, e.g.:

% % % plotGroups = {'controls';
% % %     'controls patients'};
% % %
% % % plotStims = {'alcohol drugs food neutral';
% % %     'drugs'};

% would be for making 2 figures: the 1st would plot alc, drugs, etc. for
% just the controls and the 2nd would plot drugs for controls vs patients.


% plotStims = {'alcohol';'drugs';'food';'neutral'};
plotStims = {'drugs-neutral'};

plotStimStrs = plotStims;


nFigs = numel(plotStimStrs); % number of figures to be made

subjects = getCueSubjects(task,1);
[relapse_idx,time2relapse]=getCueRelapseData(subjects);

%% get ROI time courses

r=1;
for r = 1:numel(roiNames)
    
    roiName = roiNames{r};
    
    inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI
    
    
    %% define time courses to plot
    
    f=1
    for f = 1:nFigs
        
        % get the stims & stim strings for plotting in this figure
        stims = splitstring(plotStims{f});
        stimStr = plotStimStrs{f};
        
        tc = {}; % time course cell array
        subjects = {};
        
        for c = 1:numel(stims)
            
            % if there's a minus sign, assume desired plot is stim1-stim2
            if strfind(stims{c},'-')
                stim1 = stims{c}(1:strfind(stims{c},'-')-1);
                stim2 = stims{c}(strfind(stims{c},'-')+1:end);
                [tc1,subjects{1,c}]=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),'patients',1:nTRs);
                [tc2,~]=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),'patients',1:nTRs);
                tc{1,c}=tc1-tc2;
            else
                stimFile = fullfile(inDir,[stims{c} '.csv']);
                [tc{1,c},subjects{1,c}]=loadRoiTimeCourses(stimFile,'patients',1:nTRs);
            end
            
            % now put time courses of relapsers in 2nd row of cells & only
            % non-relapsers in the first row
            tc{2,c} = tc{1,c}(relapse_idx==1,:);
            tc{1,c}=tc{1,c}(relapse_idx==0,:);
            
            subjects{2,c} = subjects{1,c}(relapse_idx==1);
            subjects{1,c} = subjects{1,c}(relapse_idx==0);
            
        end % stims
        
        % make sure all the time courses are loaded
        if any(cellfun(@isempty, tc))
            tc
            error('\hold up - time courses for at least one stim/group weren''t loaded.')
        end
        
        n(1) = size(tc{1,1},1); % n non-relapsers
        n(2) = size(tc{2,1},1); % n relapsers
        
        
        mean_tc = cellfun(@nanmean, tc,'uniformoutput',0);
        se_tc = cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), tc,'uniformoutput',0);
        
        if (useSpline) %  upsample time courses
            t_orig = t;
            t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
            mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
            se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
        end
        
        
        %% get plot params
        
        % fig title
        figtitle = [roiName ' response to ' stimStr ' in non-relapsers '...
            '(n=' num2str(n(1)) ') vs relapsers (n=' num2str(n(2)) ') '];
        
        % x and y labels
        xlab = 'time (in seconds) relative to cue onset';
        ylab = '%\Delta BOLD';
        
        pLabels = {'non-relapsers','relapsers'}; % labels for each line plot

        % line colors
        cols = reshape(getCueExpColors(numel(tc),'cell'),size(tc,1),[]);
        
        
        % get stats, if plotting
        p=[];
        if plotStats
            p = getPValsGroup(tc); % one-way ANOVA
        end
        
        % filename, if saving
        savePath = [];
        if saveFig
            outDir = fullfile(figDir,tcDir,roiName);
            if ~exist(outDir,'dir')
                mkdir(outDir)
            end
            % nomenclature: roiName_stimStr_groupStr
            outName = [roiName '_' stimStr '_byrelapse'];
            savePath = fullfile(outDir,outName);
        end
        
        %% finally, plot the thing!
        
        fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);
        
        [fig,leg]=plotNiceLines(t,mean_tc,se_tc,cols,p,pLabels,xlab,ylab,figtitle,savePath);
%         fsize = 26;
%         set(gca,'fontName','Arial','fontSize',fsize)
%         title('NAcc response to drugs-neutral trials','fontName','Arial','fontSize',fsize)
%         xlabel(xlab,'fontName','Arial','FontSize',fsize)
%         ylabel(ylab,'fontName','Arial','FontSize',fsize)
%         
%         set(leg,'String',{'non-relapsers (n=10)','relapsers (n=6)'})
%         set(gca,'XTick',[0:2:18])
%         xlim([0 18])
%         print(gcf,'-dpng','-r600',savePath);
%         
%         
        fprintf('done.\n\n')
        
        
        
    end % figures
    
end %roiNames


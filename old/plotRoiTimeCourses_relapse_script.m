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

task = 'cue'; % must be either 'cue','mid', or 'midi'

% tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_afni_woOutliers' ];
tcDir = ['timecourses_' task '_afni' ];

tcPath = fullfile(dataDir,tcDir);


plotGroups = {'patients'};

subjects = getCueSubjects(task,plotGroups);

% plotStims = {'alcohol';'drugs';'food';'neutral'};
plotStims = {'drugs'};

plotStimStrs = plotStims;

nFigs = numel(plotStimStrs); % number of figures to be made


[relapse_idx,time2relapse]=getCueRelapseData(subjects);

%%%%%%%%%%%%%%%%%%%%%%%%%%%



% which rois to process?
a=dir([tcPath '/*']);
while strcmp(a(1).name(1),'.')
    a(1)=[];
end
allRoiNames = cellfun(@(x) strrep(x,'_func.nii',''), {a(:).name},'uniformoutput',0);
disp(allRoiNames');
fprintf('\nwhich ROIs to process? \n');
roiNames = input('enter roi name(s), or hit return for all ROIs above: ','s');
if isempty(roiNames)
    roiNames = allRoiNames;
else
    roiNames = splitstring(roiNames);
end



nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10

plotStats = 1;

saveFig = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            
            c=1;
            for c = 1:numel(stims)
                
                % if there's a minus sign, assume desired plot is stim1-stim2
                if strfind(stims{c},'-')
                    stim1 = stims{c}(1:strfind(stims{c},'-')-1);
                    stim2 = stims{c}(strfind(stims{c},'-')+1:end);
                    tc1=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),getCueSubjects(task,groups{g}),1:nTRs);
                    tc2=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),getCueSubjects(task,groups{g}),1:nTRs);
                    tc{g,c}=tc1-tc2;
                else
                    stimFile = fullfile(inDir,[stims{c} '.csv']);
                    tc{g,c}=loadRoiTimeCourses(stimFile,getCueSubjects(task,groups{g}),1:nTRs);
                end
                
                % now put time courses of relapsers in 2nd row of cells & only
                % non-relapsers in the first row
                tc{2,c} = tc{1,c}(relapse_idx==1,:);
                tc{1,c}=tc{1,c}(relapse_idx==0,:);
                
                subjects{2,c} = subjects{1,c}(relapse_idx==1);
                subjects{1,c} = subjects{1,c}(relapse_idx==0);
                
            end % stims
            
        end % groups
        
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


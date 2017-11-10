% plot roi time courses as bars

% load roi time courses (or FIR betas), average over some of them, and
% plot the average as bars with standard error.

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


stims = {'drugs','food','neutral'};

groups = {'controls','patients'};

    
% t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
% xt = t; %  xticks on the plotted x axis
TRs = [4 7]; % 1x2 vector denoting the first and last TR to average over


plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get ROI time courses

r=1;
for r = 1:numel(roiNames)
    
    roiName = roiNames{r};
    
    inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI
    
    
    %% define time courses to plot
    
    % get stim responses
    d = {}; % cell array of data
    for c = 1:numel(stims)
        
        stimFile = fullfile(inDir,[stims{c} '.csv']);
        
        % load roi time courses
        for g = 1:numel(groups)
            
            tc=loadRoiTimeCourses(stimFile,getCueSubjects(task,groups{g}));
            
            % make sure all the time courses are loaded
            if isempty(tc)
                tc
                error('\hold up - time courses for at least one stim/group weren''t loaded.')
            end
            
            d{g}(:,c) = mean(tc(:,TRs(1):TRs(2)),2);
            
        end
    end
    
    
    %% plot
    
    ylab = '%\Delta BOLD';
    cols = getCueExpColors(numel(groups));
%     cols = [200 200 200; 50 50 50]./255;
    plotSig = 1;
    figtitle = sprintf('%s activity (TRs %d-%d)',strrep(roiName,'_',' '),TRs(1),TRs(2));
    
    % filename, if saving
    savePath = [];
    if saveFig
        % nomenclature: roiName_stimStr_groupStr
        outDir = fullfile(figDir,tcDir,roiName);
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        outName = [roiName '_stimXgroup_bar'];
        savePath = fullfile(outDir,outName);
    end
    
    
    %% finally, plot the thing!
    
    fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);
   
    [fig,leg] = plotNiceBars(d,ylab,stims,groups,cols,plotSig,figtitle,1,savePath,1)
   
    
    fprintf('done.\n\n')
    
    
    
end %roiNames


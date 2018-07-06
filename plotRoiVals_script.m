% script to plot ROI values in various ways


clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
% task = whichCueTask();
task = 'cue';

p = getCuePaths();

dataDir = p.data;
figDir = p.figures;

stims = {'drugs','food','neutral'};
%  stims = {'drugs'};
% stims = {'pa'};

groups = {'relapsers_3months','nonrelapsers_3months'};
groupStr = 'byrelapse';

% groups = {'controls','patients'};
% groupStr = 'bygroup';

% groups = {'controls'};
% groupStr = groups{1};



cols = getCueExpColors(groups); % colors for plotting

% roiNames = whichRois(inDir);
roiNames = {'PVT'};

saveOut = 1;

plotType = 'bar'; % options are: bar, hist, or points

dType = 'betas'; % either betas or timecourses

switch lower(dType)
    
    case 'betas'
        
        inDir = fullfile(dataDir,['results_' task '_afni'],'roi_betas'); % roi betas
%         inDir = fullfile(dataDir,['results_' task '_afni_pa'],'roi_betas'); % roi betas
        dName = 'betas'; % name of data type
        aveTRs = [];
        
        
    case 'timecourses'
        
        inDir =  fullfile(dataDir, ['timecourses_' task '_afni' ]); % timecourses
        aveTRs = [4 7]; % 1x2 vector denoting the first and last TR to average over
        dName = sprintf('aveTRs%d-%d',aveTRs(1),aveTRs(2)); % name of data type
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

for r=1:numel(roiNames)
    
    roi = roiNames{r};
    
    
    if saveOut
        outDir = fullfile(figDir,'roi_betas',task,roi);
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
    end
    
    %%%%%%%%% load data
    
    d = {};
    
    for g=1:numel(groups)
        
        for c=1:numel(stims)
            
            % if there's a minus sign, assume desired plot is stim1-stim2
                if strfind(stims{c},'-')
        
                    stimFile1 = fullfile(inDir,roi,[stims{c}(1:strfind(stims{c},'-')-1) '.csv']);
                    stimFile2 = fullfile(inDir,roi,[stims{c}(strfind(stims{c},'-')+1:end) '.csv']);
                    
                    % load roi data (stim1-stim2)
                    this_d=[loadRoiTimeCourses(stimFile1,getCueSubjects(task,groups{g}))-...
                        loadRoiTimeCourses(stimFile2,getCueSubjects(task,groups{g}))];
                 
               else  % just load stim data 
                    
                    stimFile = fullfile(inDir,roi,[stims{c} '.csv']);
                    
                    % load roi data
                    this_d=loadRoiTimeCourses(stimFile,getCueSubjects(task,groups{g}));
                    
                end
                
                % average over subset of TRs, if data is timecourse data
                if ~isempty(aveTRs)
                    this_d = mean(this_d(:,aveTRs(1):aveTRs(2)),2);
                end
                    
                d{g}(:,c) = this_d;
            
        end % stims
        
    end % groups
    
    
    %% now plot it
    
    switch lower(plotType)
        
        case 'bar'
            
            plotSig = [1 1];
            titleStr = [strrep(roi,'_',' ') ' response by group'];
            plotLeg = 1;
            plotToScreen=1;
            if saveOut
                %              savePath = fullfile(outDir, [dType '_' stims{:} '_' plotType]);
                savePath = fullfile(outDir, [dType '_' stims{:} '_' groupStr '_' plotType]);
            else
                savePath = [];
            end
            savePath
            
            [fig,leg] = plotNiceBars(d,dName,stims,strrep(groups,'_',' '),cols,plotSig,titleStr,plotLeg,savePath,plotToScreen);
            
        case 'hist'
            
            for c=1:numel(stims)
                
                titleStr = [strrep(roi,'_',' ') ' ' stims{c} ' ' dName]; % e.g., nacc food betas
                legStr = strrep(groups,'_',' ');
                stim_d = cellfun(@(x) x(:,c), d, 'uniformoutput',0);
                if saveOut
                    savePath = fullfile(outDir, [dType '_' stims{c} '_' groupStr '_' plotType]);
                else
                    savePath = [];
                end
                savePath
                
                hh = plotNiceNHist(stim_d,cols,titleStr,legStr,savePath);
                
            end
            
        case 'points'
            
            for c=1:numel(stims)
                x=[];
                stim_d = cellfun(@(x) x(:,c), d, 'uniformoutput',0);
                titleStr = [strrep(roi,'_',' ') ' ' stims{c} ' ' dName ' by group']; % e.g., nacc food betas
                xlab = '';
                ylab = [strrep(roi,'_',' ') ' ' stims{c} ' ' dName ];
                legStrs = strrep(groups,'_',' ');
                if saveOut
                    savePath = fullfile(outDir, [dType '_' stims{c} '_' groupStr '_' plotType]);
                else
                    savePath = [];
                end
                savePath
                
                fig = plotNicePoints(x,stim_d,cols,titleStr,xlab,ylab,legStrs,savePath)
            end % stims
            
    end
    
    
end

% [fig,leg]=plotNiceLines(x,y,se,cols,pvals,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen)
%
%

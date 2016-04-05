% script to save out roi time courses. This script does the following:

% load event onset files: each file should be a text file with a column
% vector of 0s and 1s to signify an event onset. Length of the vector should be
% equal to the # of acquired TRs.

% load roi binary mask files: volumes w/value of 1 signifying which voxels
% are in the roi mask; otherwise 0 values

% load pre-processed functional data & get averaged roi time courses

% get stim-locked time series based on event onset files

% plot each trial separately (this should be noisy but potentially useful
% for diagnosing movement, something weird, etc.)

% for each subject, for each roi, for each event type, get the average time
% course & save out in text file

% THIS SCRIPT IS DIFFERENT FROM 'SAVEROITIMECOURSES_SCRIPT" IN THAT IT
% IDENTIFIES OUTLIERS FROM A SUBJECT'S 'MOTION_CENSOR.1D' FILE, RATHER THAN
% ZSCORING THE TIME COURSES

%
clear all
close all


p = getCuePaths;
subjects = getCueSubjects();
% subjects = {'zl150930'};
subjects = subjects(2:end);

% p = getCuePaths_Claudia;
% subjects = getCueSubjects_Claudia();


dataDir = p.data;


% filepath to pre-processed functional data where %s is subject
funcFilePath = fullfile(dataDir, '%s/func_proc_mid/pp_mid_trunc_tlrc.nii');
% funcFilePath = fullfile(dataDir, '%s/func_proc_cue/fpsmtcue1_afni.nii');

% file path to file that says which volumes to censor due to head movement
censorFilePath = fullfile(dataDir, '%s/func_proc_mid/motion_censor_trunc.1D');


% outDir = fullfile(dataDir,'timecourses_afni');
outDir = fullfile(dataDir,'timecourses_mid_trunc');


% directory w/regressor time series (NOT convolved)
% regs cell array lists all the stim times to plot
stimDir =  fullfile(dataDir,'%s/regs');


% labels of stims to get time series for
stims =  {'loss0','loss1','loss5','gain0','gain1','gain5',...
    'losshit','lossmiss','gainhit','gainmiss'};


stimFiles =  {'loss0_trial_mid.1D','loss1_trial_mid.1D','loss5_trial_mid.1D',...
    'gain0_trial_mid.1D','gain1_trial_mid.1D','gain5_trial_mid.1D',...
    'losshits_trial_mid.1D','lossmiss_trial_mid.1D',...
    'gainhits_trial_mid.1D','gainmiss_trial_mid.1D'};


% roi directory
roiDir = fullfile(dataDir,'ROIs');

% labels of rois to get time series for
% roiNames = {'LC'};
roiNames = {'nacc','acing','dlpfc','mpfc','caudate','ins'};


% % corresponding roi file names (binary mask nifti file)
roiFiles = cellfun(@(x) [x '_func.nii'], roiNames,'UniformOutput',0);


nTRs = 12; % # of TRs to extract

saveOut = 1; % save out time courses to file?

TC = cell(numel(roiNames),numel(stims)); % out data cell array

omitOTs = 0; % omit trials with time points that deviate more than 3 SDs?
plotSingleTrials = 0; % save out plots of outlier trials?


%% do it

rois = cellfun(@(x) niftiRead(fullfile(roiDir,x)), roiFiles,'uniformoutput',0);

if omitOTs
    outDir = [outDir '_woOutliers'];
end

i=1; j=1; k=1;
for i=1:numel(subjects); % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
    % load subject's motion_censor.1D file that says which volumes to
    % censor due to motion
    censorVols = find(dlmread(sprintf(censorFilePath,subject))==0);
    
    % get roi time series
    roi_tcs = cellfun(@(x) roi_mean_ts(func.data,x.data), rois, 'uniformoutput',0);
    
    % zero pad the end of the time series for the case of the last trial
    roi_tcs = cellfun(@(x) [x;nan(nTRs,1)], roi_tcs, 'uniformoutput',0);
    
    % get stim onset times
    onsetTRs = cellfun(@(x) find(dlmread(fullfile(sprintf(stimDir,subject),x))), stimFiles, 'uniformoutput',0);
    
    for j=1:numel(rois)
        
        % this roi time series
        roi_tc= roi_tcs{j};
        
        
        for k=1:numel(stims)
            
            % this stim time series
            this_stim_tc = [];
            
            % set time courses to nan if there are no stim events
            if isempty(onsetTRs{k})
                TC{j,k}(i,:) = nan(1,nTRs);
                
                % otherwise, process stim event time courses
            else
                
                this_stim_TRs = repmat(onsetTRs{k},1,nTRs)+repmat(0:nTRs-1,numel(onsetTRs{k}),1);
                
                % single trial time courses for this stim
                this_stim_tc=roi_tc(this_stim_TRs);
                
                % identify & omit trials based on motion censor index
                [censor_idx,~]=find(ismember(this_stim_TRs,censorVols));
                censor_idx = unique(censor_idx);
                censored_tc = this_stim_tc(censor_idx,:);
                this_stim_tc(censor_idx,:) = [];
                
                % identify outlier trials
                [outlier_idx,~]=find(abs(zscore(this_stim_tc))>3);
                outlier_idx = unique(outlier_idx);
                outlier_tc = this_stim_tc(outlier_idx,:);
                if omitOTs
                    this_stim_tc(outlier_idx,:) = [];
                end
                
                % keep count of the # of censored & outlier trials
                nBadTrials{j}(i,k) = numel(outlier_idx)+numel(censor_idx);
                
                % plot single trials
                if plotSingleTrials
                    h = figure;
                    set(gcf, 'Visible', 'off');
                    hold on
                    set(gca,'fontName','Arial','fontSize',12)
                    % plot ok, censored, and outlier single trials
                    plot(this_stim_tc','linewidth',1.5,'color',[.15 .55 .82])
                    plot(censored_tc','linewidth',1.5,'color',[1 0 0])
                    plot(outlier_tc','linewidth',1.5,'color',[.65 0 .12])
                    xlabel('TR (from cue onset)')
                    ylabel('% BOLD change')
                    set(gca,'box','off');
                    set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
                    
                    title(gca,[subject ' ' stims{k}])
                    
                    % save out plot
                    thisOutDir = fullfile(outDir,roiNames{j},'single_trial_plots');
                    if ~exist(thisOutDir,'dir')
                        mkdir(thisOutDir);
                    end
                    outName = [subject '_' stims{k}];
                    print(gcf,'-dpng','-r600',fullfile(thisOutDir,outName));
                end
                
                TC{j,k}(i,:) = nanmean(this_stim_tc);
                
            end % isempty(onsetTRs)
            
        end % stims
        
    end % rois
    
end % subject loop


%%  save out time courses
%

if saveOut
    
    % WITH SUBJECT ID:
    for j=1:numel(rois)
        
        % roi specific directory
        thisOutDir = fullfile(outDir,roiNames{j});
        if ~exist(thisOutDir,'dir')
            mkdir(thisOutDir);
        end
        
        for k=1:numel(stims)
            T = table([subjects],[TC{j,k}]);
            writetable(T,fullfile(thisOutDir,[stims{k} '.csv']),'WriteVariableNames',0);
        end
    end
    
    % WITHOUT SUBJECT ID:
    % for j=1:numel(rois)
    %
    %     % roi specific directory
    %     thisOutDir = fullfile(outDir,rois{j});
    %     if ~exist(thisOutDir,'dir')
    %         mkdir(thisOutDir);
    %     end
    %
    %     for k=1:numel(stims)
    %         dlmwrite(fullfile(thisOutDir,[stims{k}]),TC{j,k});
    %     end
    % end
    
end






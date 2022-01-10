% script to save out roi time courses at the trial-by-trial level.
% This script does the following:

% loads roi binary mask files: volumes w/value of 1 signifying which voxels
% are in the roi mask; otherwise 0 values

% load pre-processed functional data & get averaged roi time courses

% get stim-locked time series based on stim file

% for each subject, for each roi, for each event type, get the time course
% for each trial & save out in text file

%%% saves out a big file that has the following columns:
% subjid gi rel trial tr trialtype outcome roi1_ts roi2_ts roiN_ts



clear all
close all


%%%%%%%%%%%%%%%%%%%  define experiment directories %%%%%%%%%%%%%%%%%%%%%%%%
[p,task,subjects,gi]=whichCueSubjects();

dataDir = p.data;

[subjects,gi]=getCueSubjects(task);

 afniStr = '_afni';
% afniStr = ''; % to use ants version

% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir, ['%s/func_proc/pp_' task '_tlrc' afniStr '.nii.gz']);


% file path to file that says which volumes to censor due to head movement
censorFilePath = fullfile(dataDir, ['%s/func_proc/' task '_censor.1D']);


rel_6months = getCueData(subjects,'relapse_6months');


% behavioral stim file
if strcmp(task,'cue')
    stimFilePath=fullfile(dataDir,'%s','behavior','cue_matrix.csv');
else
     stimFilePath=fullfile(dataDir,'%s','behavior',[task '_matrix_wEnd.csv']);
end
    
 
% names for trial types


%%%%%%%%%%%%%%%%%%%%%%%%%% ROI masks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% roi directory
roiDir = fullfile(mainDir,'ROIs_mni');

% get list of rois to potentially process
roiNames = {'anteriorinsula','anteriorinsulaL','anteriorinsulaR',...
    'mpfc','mpfcL','mpfcR',...
    'nacc','naccL','naccR'};

% roiNames = {'anteriorinsula','nacc','mpfc'};


% name of main dir to save out to
mainOutDir = fullfile(dataDir,['timecourses_mid_singletrial']);

%% this hasn't been implemented yet 
% omitOTs=0; % 1 to omit outliers, otherwise 0
% if omitOTs
%     outDir = [outDir '_woOutliers'];
% end


nTRs = 8; % # of TRs to extract
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot



%% do it

% list out the variables to include in the big file
subjid = {}; % column of subject ids
group_idx = []; % group index where 0=control, 1=VA patient, 2=epiphany patient
relapse_6months = [];
trial = []; % trial number
trial_onsetTR=[]; % onset TR for that trial
trialtype = []; %  1=-0, 2=-1, 3=-5, 4=+0, 5=+1, 6=+5
TR=[]; % TR # relative to trial onset
outcome=[]; %0=miss, 1=hit
roi_tc = []; % this will be a (nTrial.*nTR) x nROI matrix of timecourse values


% get roi masks
roiFiles = cellfun(@(x) [x '_func.nii.gz'], roiNames,'UniformOutput',0);
rois = cellfun(@(x) niftiRead(fullfile(roiDir,x)), roiFiles,'uniformoutput',0);



i=1; j=1; k=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
    % load subject's motion_censor.1D file that says which volumes to
    % censor due to motion
    censorVols = find(dlmread(sprintf(censorFilePath,subject))==0);
    
    % get roi time series
    for j=1:numel(rois)
        roi_ts(:,j)=roi_mean_ts(func.data,rois{j}.data);
    end
    
    % censor out any bad motion volumes
    roi_ts(censorVols,:)=nan;
    
    %%%%%% this isn't functional yet
    %     % set vols with abs(zscore > 4) to nan (assume this is due to
    %     % some non-bio noise)
    %     if omitOTs
    %         find(abs(zscore(temp(~isnan(temp))))>4)];
    %     end
    
    % load stimfile
    if strcmp(task,'cue')
           [thistrial,thisTR,thisStartTime,thisClock,thistrialonset,thistrialtype,thisCue_RT,thisChoice,thisChoice_Num,...
    thisChoice_Type,Choice_RT,ITI,Drift,Image_Names]=getCueTaskBehData(filepath,format)

    else
    [thistrial,thisTR,thistrialonset,thistrialtype,thistarget_ms,thisrt,thiscue_value,thishit,thistrial_gain,...
        thistotal,thisiti,thisdrift,thistotal_winpercentthis,binned_winpercent]=loadMidBehData(sprintf(stimFilePath,subject),'long');
    end
    
    % get trial onset TRs
    onsetTRs=find(thisTR==1);
    
    
    for k=1:numel(onsetTRs)
        
        thisonsetTR=onsetTRs(k); % onset TR for this trial
        
        thisroi_tc = roi_ts(thisonsetTR:thisonsetTR+nTRs-1,:);
        
        % fill out variables for big file
        subjid = [subjid; repmat(subjects(i),nTRs,1)];
        group_idx = [group_idx;repmat(gi(i),nTRs,1)];
        relapse_6months = [relapse_6months;repmat(rel_6months(i),nTRs,1)];
        trial = [trial;repmat(thistrial(thisonsetTR),nTRs,1)];
        TR=[TR;(1:nTRs)']; % TR # relative to trial onset
        trial_onsetTR=[trial_onsetTR;repmat(thisonsetTR,nTRs,1)]; % onset TR for that trial
        trialtype = [trialtype;repmat(thistrialtype(thisonsetTR),nTRs,1)]; %  1=-0, 2=-1, 3=-5, 4=+0, 5=+1, 6=+5
        outcome=[outcome;repmat(thishit(thisonsetTR),nTRs,1)]; %0=miss, 1=hit
        roi_tc = [roi_tc;thisroi_tc];
        
    end % onset TRs
    
end % subjects


%% % save out big csv file if desired


T1=table(subjid,group_idx,relapse_6months,trial,TR,trial_onsetTR,trialtype,outcome);

roiVarNames=cellfun(@(x) [x '_tc'], roiNames,'uniformoutput',0);
Troi_tc = array2table(roi_tc,'VariableNames',roiVarNames);

T=[T1 Troi_tc];

outPath = fullfile(mainOutDir,['singletrialdata_' datestr(now,'yymmdd') '.csv']);
writetable(T,outPath);



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

% [subjects,gi]=getCueSubjects(task);

 afniStr = '_afni';
% afniStr = ''; % to use ants version

% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir, ['%s/func_proc/pp_cue_tlrc' afniStr '.nii.gz']);


% file path to file that says which volumes to censor due to head movement
censorFilePath = fullfile(dataDir, ['%s/func_proc/cue_censor.1D']);


%%%%%%%%%%%%%%%%%%%%%%%%%% ROI masks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% roi directory
roiDir = fullfile(dataDir,'ROIs');

% get list of rois to potentially process
% roiNames = whichRois(roiDir,'_func.nii','_func.nii');
roiNames={'nacc_desai','naccL_desai','naccR_desai',...
    'ins_desai','insL_desai','insR_desai',...
    'mpfc','mpfcL','mpfcR',...
    'VTA','VTAL','VTAR'};

% name of main dir to save out to
mainOutDir = fullfile(dataDir,['cue_roi_ts']);


% set to 1 to censor TRs with bad motion, otherwise set to 0
censorTRs=1; 


%% do it


if ~exist(mainOutDir,'dir')
    mkdir(mainOutDir);
end


% get roi masks
roiFiles = cellfun(@(x) [x '_func.nii'], roiNames,'UniformOutput',0);
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
        
        roi_ts{j}(:,i)=roi_mean_ts(func.data,rois{j}.data);
        
        if censorTRs
            roi_ts{j}(censorVols,i)=nan;
        end
        
    end
    
end % subjects

    
%% % save out big csv file if desired

for j=1:numel(rois)
    
    T=array2table(roi_ts{j},'VariableNames',subjects');
    
    outStr = ['cue_' roiNames{j} '_ts'];
    if censorTRs
        outStr=[outStr '_wcensoredTRs'];
    end
    
    outPath = fullfile(mainOutDir,[outStr '_' datestr(now,'yymmdd') '.csv']);
    writetable(T,outPath);
    
end

  

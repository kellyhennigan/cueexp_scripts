% script to calculate functional connectivity between a seed roi and a
% voxelwise map

% this script takes an roi mask to define the seed roi values, and also
% allows specifiying nuisance regressors to regress out before calculating
% values for correlation


clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects(task);
% subjects = {'jh160702'};


% seed roi mask path
seedRoiName = 'Choi_ventralcaudateL';
seedRoiFilePath = fullfile(dataDir,'ROIs',[seedRoiName '_func.nii']);


% path to brain mask
maskFilePath = fullfile(dataDir,'templates','bmask.nii');


% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc_afni.nii.gz']);


% define file path to nuisance regressors - these will be regressed out
% before func connectivity is calculated
nuisance_designmat_file = fullfile(dataDir,'%s','func_proc',[task '_nuisance_regs.txt']);


% directory for saving out files
outDir = fullfile(dataDir,['results_' task '_funcconn'],seedRoiName);


% group names
groups = {'controls','patients'}; % order corresponding to gi=0, gi=1
% groups = {'nonrelapsers','relapsers'}; % order corresponding to ri=0, ri=1


% save out single subject results?
saveOutSingleSubjectVols = 0; % 1 for yes, 0 for no


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% which type of FC analysis: resting-state-style or event-related? %%%

% define stims as 'restingstate' to do resting state style func connectvity
stims = {'restingstate'};

% if event-related style is desired, use stims to define epochs of interest
% stims = {'drugs','food','neutral'};
% stimFilePath = fullfile(dataDir,'%s','regs','%s_cue_cue.1D');
% 
% 
% % index of which TR(s) to extract (TR1 is at trial onset, etc.)
% TRi = 5;
% TR = 2; % 2 sec TR
% ti = (TRi-1).*TR; % time at the indexed TR


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


% create out directory if it doesn't already exist
if ~exist(outDir,'dir')
    mkdir(outDir);
end

% load mask file
mask = niftiRead(maskFilePath); mask.data = double(mask.data);
dim = size(mask.data);

% load seed roi mask
seedRoi = niftiRead(seedRoiFilePath);


i=1; j=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
      % define seed roi time series
    seed_ts = roi_mean_ts(func.data,seedRoi.data);
  
    
        % load nuisance regressors
        X = readtable(sprintf(nuisance_designmat_file,subject));
        nuisance_regLabels = X.Properties.VariableNames;
        X = table2array(X);
        
        
        X = [X seed_ts];
        
               % reshape data so that each voxel's time series is a column
            voxD=reshape(func.data,prod(dim(1:3)),[])';
         
            B=glm_fmri_fit(voxD,X,'','B');
     
                  % collect all single subject maps in a cell array
        Z{j}(i,:) = B(end,:);
   
           
            outStr{j} = [stims{j} 'B']; % this will be string used on out files
        
    
    
end % subjects


%% now do ttest on subject r-to-Z transformed maps; afni-style volumes


%%%%%%%%%%%%% Z map for each stim
for j=1:numel(stims)
    
    % change all nan values to 0 (these are all outside of the mask)
    Z{j}(isnan(Z{j}))=0;
    
    outPath = fullfile(outDir,['Z' outStr{j} '.nii.gz']);
  
    out = glm_fmri_ttest3d(Z{j}(gi==0,:),Z{j}(gi==1,:),groups,mask,outPath);
    
end









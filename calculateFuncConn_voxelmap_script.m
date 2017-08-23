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
seedRoiName = 'Choi_ventralcaudateR';
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
% stims = {'restingstate'};

% if event-related style is desired, use stims to define epochs of interest
stims = {'drugs','food','neutral'};
stimFilePath = fullfile(dataDir,'%s','regs','%s_cue_cue.1D');


% index of which TR(s) to extract (TR1 is at trial onset, etc.)
% TRi = 4:7;
TRi=5;
TR = 2; % 2 sec TR
ti = (TRi-1).*TR; % time at the indexed TR


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
    
    
    % regress out variance from nuisance regressors (if desired)
    if ~isempty(nuisance_designmat_file)
        
        
        % load nuisance regressors
        X = readtable(sprintf(nuisance_designmat_file,subject));
        nuisance_regLabels = X.Properties.VariableNames;
        X = table2array(X);
        
        % regress nuisance variance out of voxel time series
        stats=glm_fmri_fit_vol(func.data,X,[],mask.data);
        func.data = stats.err_ts;
        
    end
    
    
    % define seed roi time series
    seed_ts = roi_mean_ts(func.data,seedRoi.data);
    
    
    
    %% do functional connectivity analysis
    
    for j = 1:numel(stims)
        
        %%%%%%%%%%%% FOR RESTING STATE FUNC CONNECTIVITY:
        % correlate seed time series with each voxel time series
        if strcmp(stims,'restingstate')
          
            
            seedD = seed_ts;  % seed data
            
            
            % reshape data so that each voxel's time series is a column
            voxD=reshape(func.data,prod(dim(1:3)),[])';
          
            
            outStr{j} = stims{j}; % this will be string used on out files
          
            
            %%%%%%%%%%%% FOR EVENT-RELATED FUNC CONNECTIVITY:
            % correlate activity btwn seed and & voxels during specific events
        else
            
            
            % get stim onset times
            onsetTRs = find(dlmread(sprintf(stimFilePath,subject,stims{j})));
            
            % get array of indices of which (desired) TRs correspond to this stim
            this_stim_TRs = repmat(onsetTRs,1,TRi(end))+repmat(0:TRi(end)-1,numel(onsetTRs),1);
            this_stim_TRs = this_stim_TRs(:,TRi);
            
            % single trial values for seed roi
            seedD=mean(seed_ts(this_stim_TRs),2);
            
            % 4d matrix with 3d volume of voxels and 4th dim is response for
            % each trial of stim(j)
            voxD=mean(reshape(func.data(:,:,:,this_stim_TRs),dim(1),dim(2),dim(3),numel(onsetTRs),[]),5);
            
            % reshape into a 2d matrix with each voxel's trial values in cols
            voxD=reshape(voxD,prod(dim(1:3)),[])';
            
            
            outStr{j} = [stims{j} '_TR' strrep(num2str(TRi),' ','')]; % this will be strig used on out files
            
           
            
        end % resting-state or event-related
        
        
        % correlate seed-voxel activity
        r = corr(seedD,voxD);
        
        % Fisher Z transform the corr coefficients
        thisZ =  .5.*log((1+r)./(1-r));
        
        % collect all single subject maps in a cell array
        Z{j}(i,:) = thisZ;
        
        
        % save out 1st level (single subject) results?
        if saveOutSingleSubjectVols
            
            % define a nifti file w/subjects' r-to-Z correlation for this stim
            ni = createNewNii(func,reshape(thisZ,dim(1),dim(2),dim(3)),fullfile(outDir,[subject '_' outStr{j}]));
            
            % save out nifti volume
            writeFileNifti(ni);
            
        end % saveOutSingleSubjectVols
        
        
    end % stims
    
    
end % subjects


%% now do ttest on subject r-to-Z transformed maps; afni-style volumes


%%%%%%%%%%%%% Z map for each stim
for j=1:numel(stims)
    
    % change all nan values to 0 (these are all outside of the mask)
    Z{j}(isnan(Z{j}))=0;
    
    outPath = fullfile(outDir,['Z' outStr{j} '.nii.gz']);
  
    out = glm_fmri_ttest3d(Z{j}(gi==0,:),Z{j}(gi==1,:),groups,mask,outPath);
    
end


%%%%%%%%%%%%% Z map for drugs-neutral
stim1 = 'drugs'; 
stim2 = 'neutral'; 
if any(strcmp(stims,stim1)) && any(strcmp(stims,stim2))
    Zdiff = Z{strcmp(stims,stim1)}-Z{strcmp(stims,stim2)};
    outPath = fullfile(outDir,['Z' stim1 '-' stim2 '_TR' strrep(num2str(TRi),' ','') '.nii.gz']);
    out = glm_fmri_ttest3d(Zdiff(gi==0,:),Zdiff(gi==1,:),groups,mask,outPath);
end

%%%%%%%%%%%%% Z map for food-neutral
stim1 = 'food';
stim2 = 'neutral';
if any(strcmp(stims,stim1)) && any(strcmp(stims,stim2))
    Zdiff = Z{strcmp(stims,stim1)}-Z{strcmp(stims,stim2)};
    outPath = fullfile(outDir,['Z' stim1 '-' stim2 '_TR' strrep(num2str(TRi),' ','') '.nii.gz']);
    out = glm_fmri_ttest3d(Zdiff(gi==0,:),Zdiff(gi==1,:),groups,mask,outPath);
end







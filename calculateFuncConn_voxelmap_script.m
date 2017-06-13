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
% subjects = {'tm160117'};

 afniStr = '_afni'; % '_afni' to use afni xform version, '' to use ants version
% afniStr = ''; % '_afni' to use afni xform version, '' to use ants version

% file path to onset time files (1st %s is subject and 2nd %s is stimNames)
stimFilePath = fullfile(dataDir,'%s','regs','%s_cue_cue.1D');
stims = {'drugs','food','neutral'};

% define file path to nuisance regressors
%nuisance_regfiles = '';
 nuisance_regfiles{1} = fullfile(dataDir,'%s','func_proc',[task '_csf' afniStr '.1D']);
nuisance_regidx{1} = 1; % column index for which vectors to use within each regfile

% seed roi mask path
seedRoiName = 'VTA';
seedRoiFilePath = fullfile(dataDir,'ROIs',[seedRoiName '_func.nii']);

% path to brain mask
maskFilePath = fullfile(dataDir,'templates','bmask.nii');

% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc' afniStr '.nii.gz']);

% index of which TR(s) to extract (TR1 is at trial onset, etc.)
TRi = 4:7;
TR = 2; % 2 sec TR
ti = (TRi-1).*TR; % time at the indexed TR

outDir = fullfile(dataDir,['results_' task afniStr '_FC_' seedRoiName]);
if ~isempty(nuisance_regfiles)
    outDir = [outDir '_wnr'];
end

groupNames = {'controls','patients'}; % order corresponding to gi=0, gi=1
% groupNames = {'nonrelapsers','relapsers'}; % order corresponding to ri=0, ri=1

saveOutSingleSubjectVols = 0; % 1 for yes, 0 for no


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


i=1; j=1; k=1;
for i=1:numel(subjects); % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
    
    % get seed roi time series
    seed_ts = roi_mean_ts(func.data,seedRoi.data);
    
    
    % get nuisance regressors
    if ~isempty(nuisance_regfiles)
        
        nregs=[];
        for n=1:numel(nuisance_regfiles)
            temp = dlmread(sprintf(nuisance_regfiles{n},subject));
            nregs = [nregs, temp(:,nuisance_regidx{n})];
        end
        
        % define design matrix w/intercept and nuisance regs
        X = [ones(size(seed_ts,1),1),nregs];
        
        % regress nuisance variance out of seed roi ts
        stats = glm_fmri_fit(seed_ts,X);
        nr_r2(i) = stats.Rsq; % keep track of variance explained by nuisance regs
        seed_ts = stats.err_ts;
        
        %  " " for all other voxel time series
        stats=glm_fmri_fit_vol(func.data,X,[],mask.data);
        func.data = stats.err_ts;
        
    end
    
    for k = 1:numel(stims)
        
        % get stim onset times
        onsetTRs = find(dlmread(sprintf(stimFilePath,subject,stims{k})));
        
        % get array of indices of which (desired) TRs correspond to this stim
        this_stim_TRs = repmat(onsetTRs,1,TRi(end))+repmat(0:TRi(end)-1,numel(onsetTRs),1);
        this_stim_TRs = this_stim_TRs(:,TRi);
        
        % single trial values for seed roi
        seed_betas=mean(seed_ts(this_stim_TRs),2);
        
        % 4d matrix with 3d volume of voxels and 4th dim is response for
        % each trial of stim(k)
        d=mean(reshape(func.data(:,:,:,this_stim_TRs),dim(1),dim(2),dim(3),numel(onsetTRs),[]),5);
        
        % reshape into a 2d matrix with each voxel's trial values in cols
        d2=reshape(d,prod(dim(1:3)),[])';
        
        % correlate per-trial seed-voxel activity
        r = corr(seed_betas,d2);
        
        % Fisher Z transform the corr coefficients
        thisZ =  .5.*log((1+r)./(1-r));
        
        % save out 1st level (single subject) results?
        if saveOutSingleSubjectVols
            
            % define a nifti file w/subjects' r-to-Z correlation for this stim
            ni = createNewNii(func,reshape(thisZ,dim(1),dim(2),dim(3)),fullfile(outDir,[subject '_' stims{k}]));
            
            % save out nifti volume
            writeFileNifti(ni);
            
        end
        
        Z{k}(i,:) = thisZ;
        
    end % stims
    
end % subjects


%% now do ttest on subject r-to-Z transformed maps; afni-style volumes


%%%%%%%%%%%%% T map for each stim
for j=1:numel(stims)
    
    % change all nan values to 0
    Z{j}(isnan(Z{j}))=0;
    
    [~,~,~,stats] = ttest2(Z{j}(gi==1,:),Z{j}(gi==0,:)); % unpaired ttest
    df = mode(stats.df);
    outPath = fullfile(outDir,['T_' stims{j} '.nii.gz']);
    descrip = [groupNames{2} ' vs ' groupNames{1} '; df(' num2str(df) ')'];
    
    % create T map nifti volume
    tvol = reshape(stats.tstat,dim(1),dim(2),dim(3));
    tvol = tvol.*double(mask.data); % mask voxels outside the brain
    ni = createNewNii(mask,tvol,outPath,descrip);
    
    % save out nifti volume
    writeFileNifti(ni);
    
    cmd = sprintf('3drefit -sublabel 0 %s -substatpar 0 fitt %d %s',...
        'patients_vs_controls',df,outPath);
    disp(cmd)
    system(cmd);
    
    
end % stims


%%%%%%%%%%%%% T map for drugs-neutral
ind = find(strcmp(stims,'drugs')); ind2 = find(strcmp(stims,'neutral'));
Zdn = Z{ind}-Z{ind2};

[~,~,~,stats1] = ttest(Zdn(gi==0,:)); % paired ttest group gi=0
df1 = mode(stats1.df);
[~,~,~,stats2] = ttest(Zdn(gi==1,:)); % " " for group gi=1
df2 = mode(stats2.df);
[~,~,~,stats3] = ttest2(Zdn(gi==1,:),Zdn(gi==0,:)); % unpaired ttest for patients vs controls
df3 = mode(stats3.df);
outPath = fullfile(outDir,'T_drugs-neutral.nii.gz');
descrip = ['vol1: ' groupNames{1} ', df(' num2str(df1) ');',...
    'vol2: ' groupNames{2} ', df(' num2str(df2) ');',...
    'vol3: ' groupNames{2} ' vs ' groupNames{1} ', df(' num2str(df3) ')'];

  
% create T map nifti volume
tvol1 = reshape(stats1.tstat,dim(1),dim(2),dim(3)); tvol1 = tvol1.*mask.data;
tvol2 = reshape(stats2.tstat,dim(1),dim(2),dim(3)); tvol2 = tvol2.*mask.data;
tvol3 = reshape(stats3.tstat,dim(1),dim(2),dim(3)); tvol3 = tvol3.*mask.data;

ni = createNewNii(mask,tvol1,tvol2,tvol3,outPath,descrip);

% save out nifti volume
writeFileNifti(ni);

cmd =sprintf(['3drefit -sublabel 0 %s -substatpar 0 fitt %d '...
    '-sublabel 1 %s -substatpar 1 fitt %d '...
    '-sublabel 2 %s -substatpar 2 fitt %d %s'],...
    'controls',df1,'patients',df2,'patients_vs_controls',df3,outPath);
disp(cmd);
system(cmd);




%%%%%%%%%%%%% T map for food-neutral
ind = find(strcmp(stims,'food')); ind2 = find(strcmp(stims,'neutral'));
Zfn = Z{ind}-Z{ind2};

[~,~,~,stats1] = ttest(Zfn(gi==0,:)); % paired ttest for controls
df1 = mode(stats1.df);
[~,~,~,stats2] = ttest(Zfn(gi==1,:)); % " " for patients
df2 = mode(stats2.df);
[~,~,~,stats3] = ttest2(Zfn(gi==1,:),Zfn(gi==0,:)); % unpaired ttest for patients vs controls
df3 = mode(stats3.df);
outPath = fullfile(outDir,'T_food-neutral.nii.gz');
descrip = ['vol1: ' groupNames{1} ', df(' num2str(df1) ');',...
    'vol2: ' groupNames{2} ', df(' num2str(df2) ');',...
    'vol3: ' groupNames{2} ' vs ' groupNames{1} ', df(' num2str(df3) ')'];

% create T map nifti volume
tvol1 = reshape(stats1.tstat,dim(1),dim(2),dim(3)); tvol1 = tvol1.*mask.data;
tvol2 = reshape(stats2.tstat,dim(1),dim(2),dim(3)); tvol2 = tvol2.*mask.data;
tvol3 = reshape(stats3.tstat,dim(1),dim(2),dim(3)); tvol3 = tvol3.*mask.data;

ni = createNewNii(mask,tvol1,tvol2,tvol3,outPath,descrip);

% save out nifti volume
writeFileNifti(ni);

cmd = sprintf(['3drefit -sublabel 0 %s -substatpar 0 fitt %d '...
    '-sublabel 1 %s -substatpar 1 fitt %d '...
    '-sublabel 2 %s -substatpar 2 fitt %d %s'],...
    'controls',df1,'patients',df2,'patients_vs_controls',df3,outPath);
disp(cmd);
system(cmd);




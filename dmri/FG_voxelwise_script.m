% script to do voxelwise survival analysis

% check out freesurfer matlab survival analysis package as well: 
% https://surfer.nmr.mgh.harvard.edu/fswiki/SurvivalAnalysis

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
task = 'dti';

p = getCuePaths();

dataDir = p.data;

% betaDir = fullfile(dataDir,'results_cue_afni');
% 
% stims = {'drugs','food','neutral'};
% 
% beta_fstr = '_glm+tlrc';

measure='fa';
diff_file = fullfile(dataDir,'%s','dti96trilin','bin',[measure '_tlrc.nii.gz']);

subjects = getCueSubjects('dti',0);

outDir = fullfile(dataDir,'fgMeasures','voxelwise_ns');
if ~exist(outDir,'dir')
    mkdir(outDir)
end

mask = niftiRead(fullfile(dataDir,'templates','mean_fa_tlrc_thresh.15_mask.nii.gz')); % brain mask

beh_measure='age'; % measure to correlate with brain measure

%% get maps

score = getCueData(subjects,beh_measure);
score = score-mean(score); % de-mean

X = [ones(numel(score),1) score]; % design matrix for regression

for i=1:numel(subjects)
    
    subject=subjects{i};
    ni = niftiRead(sprintf(diff_file,subject));

    y(:,:,:,i)=ni.data;
   
end

stats=glm_fmri_fit_vol(y,X,[],mask.data);
 
ni = createNewNii(mask,stats.tB(:,:,:,2),fullfile(outDir,[measure '_' beh_measure '_T']));
ni2 = createNewNii(mask,stats.pB(:,:,:,2),fullfile(outDir,[measure '_' beh_measure '_pT']));

% save out nifti volume
writeFileNifti(ni);
writeFileNifti(ni2);
      




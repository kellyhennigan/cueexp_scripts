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

subjects = getCueSubjects('dti',0);

outDir = fullfile(dataDir,'fgMeasures','voxelwise_tlrc');
if ~exist(outDir,'dir')
    mkdir(outDir)
end

diff_file = fullfile(outDir,['all_' measure '_controls.nii.gz']);

mask = niftiRead(fullfile(dataDir,'templates','mean_fa_tlrc_thresh.15_mask.nii.gz')); % brain mask

% beh_measure='age'; % measure to correlate with brain measure


%% get behavior/fmri measure to correlate with diffusion data

% mid betas:
scale = 'vta_gvnant_betas';
scores = loadRoiTimeCourses('/Users/kelly/cueexp/data/results_mid_afni/roi_betas/VTA/gvnant.csv',subjects);

omit_idx = find(isnan(scores));

scores(omit_idx)=[];

scores = scores-mean(scores); % de-mean

%% get maps

d=niftiRead(diff_file);
d.data(:,:,:,omit_idx)=[];


X = [ones(numel(scores),1) scores]; % design matrix for regression

y=d.data;

stats=glm_fmri_fit_vol(y,X,[],mask.data);
 
ni = createNewNii(mask,stats.tB(:,:,:,2),fullfile(outDir,[measure '_' scale '_T']));
ni2 = createNewNii(mask,stats.pB(:,:,:,2),fullfile(outDir,[measure '_' scale '_pT']));

% save out nifti volume
writeFileNifti(ni);
writeFileNifti(ni2);
      




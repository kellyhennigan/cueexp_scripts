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

outDir = fullfile(dataDir,'fgMeasures','voxelwise')
if ~exist(outDir,'dir')
    mkdir(outDir)
end

mask = niftiRead(fullfile(dataDir,'templates','bmask_dim1.nii')); % brain mask
dim = size(mask.data);

% mask = niftiRead(fullfile(dataDir,'ROIs','naccR_single_vox_func.nii')); % brain mask

%%  extract maps
%     

    for i=1:numel(subjects)
% 
subject=subjects{i};
ni = niftiRead(sprintf(diff_file,subject));
%         cmd = ['3dinfo -label2index ' stims{k} '#0_Coef ' subjects{i} beta_fstr]
%         [status,cmdout]=system(cmd);
%         si=strfind(cmdout,sprintf('\n')); % index number is between 2 line breaks
%         
%         outfile =  [outDir '/' subjects{i} '_' stims{k} '.nii']; % nifti filepath for saving out beta map
%         cmd = ['3dTcat ' subjects{i} beta_fstr '[' cmdout(si(1)+1:si(2)-1) '] -output ' outfile];
%         [status,cmdout]=system(cmd);
%         
%     end % subjects
%     
% end % stims


%% get maps

bis = getCueData(subjects,'BIS');

for i=1:numel(subjects)
    
    subject=subjects{i};
    ni = niftiRead(sprintf(diff_file,subject));

    X(i,:) = double(reshape(ni.data,1,[])); % all this subjects' voxels in the ith row
   
end

mask_idx=find(mask.data);

[r,p] = corr(bis,X);
r(mask_idx==0)=0; 
p(mask_idx==0)=0; 
 
ni = createNewNii(mask,reshape(r,dim(1),dim(2),dim(3)),fullfile(outDir,[measure '_BIS_corr']));
ni2 = createNewNii(mask,reshape(p,dim(1),dim(2),dim(3)),fullfile(outDir,[measure '_BIS_corr_p']));

% save out nifti volume
writeFileNifti(ni);
writeFileNifti(ni2);
      




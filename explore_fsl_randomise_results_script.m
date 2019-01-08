% explore fsl randomise results 

% idea here is to check the results from a single voxel to make sure I
% understand what the randomise command is doing...

clear all
close all


cd /Users/kelly/cueexp/data/mytbss/stats

md=niftiRead('all_MD_skeletonised.nii.gz'); % all subject's MD maps in 4D 
meanfa=niftiRead('mean_FA.nii.gz'); % 
fa_skeleton=niftiRead('mean_FA_skeleton.nii.gz'); %
t1=niftiRead('tbss_MD_tstat1.nii.gz'); % stat map for mean regressor
t2=niftiRead('tbss_MD_tstat2.nii.gz'); % stat map for mean regressor
X=dlmread('bisdesign');
contrasts=dlmread('biscontrasts');

coord = [12,-9,-10];

ijk = mrAnatXformCoords(meanfa.qto_ijk,coord);
i=ijk(1); j=ijk(2); k=ijk(3);

% confirm that ijk coord has the same mean fa value as seen in afni viewer
meanfa.data(i,j,k)

% yup! looks good

% now get MD values for that voxel:
mdvox = squeeze(md.data(i,j,k,:));


%% now fit the glm by hand and see if results match fsl's randomise command 

stats=glm_fmri_fit(mdvox,X);

t1.data(i,j,k)
t2.data(i,j,k)





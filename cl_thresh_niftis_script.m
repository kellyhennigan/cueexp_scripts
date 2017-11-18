% script to cluster threshold group beta maps


clear all
close all

% get cue exp file paths, task, and subjects
p=getCuePaths();
dataDir = p.data;

resDir = 'results_cue_afni/survival_analysis';

niFStrs = {'Zdrugs','Zfood','Zneutral'};


% vox_thresh = 2.5758; % Z value for p=.01
% vox_thresh = 2.8070; % Z value for p=.005
vox_thresh = 3.2905; % Z value for p=.01


cl_thresh = 10;
%%

cd(dataDir)
cd(resDir)


for i=1:numel(niFStrs)
    
    ni= niftiRead([niFStrs{i} '.nii.gz']);
    
    ni.data(abs(ni.data)<vox_thresh)=0;
    
    [C,ni]=nii_cluster(ni,cl_thresh);
    
    ni.fname = [niFStrs{i} '_p.001_clthresh.nii.gz'];
    
    writeFileNifti(ni)
    
end
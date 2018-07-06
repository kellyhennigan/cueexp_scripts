% script to regress out nuisance regressors and save out the err ts

clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects(task);
% subjects = {'jh160702'};

 afniStr = '_afni'; % '_afni' to use afni xform version, '' to use ants version
% afniStr = ''; % '_afni' to use afni xform version, '' to use ants version


% define file path to nuisance regressors
designmatFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc' afniStr '_nuisance_designmat.txt']);

% path to brain mask
maskFilePath = fullfile(dataDir,'templates','bmask.nii');


% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc' afniStr '.nii.gz']);

outFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc' afniStr '_nuisancereg_errts.nii.gz']);


%% do it

% load mask file
mask = niftiRead(maskFilePath); mask.data = double(mask.data);
dim = size(mask.data);



i=1; j=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
   
    % load pre-processed data
    X = table2array(readtable(sprintf(designmatFilePath,subject)));
    
    % regress nuisance variance out of voxel time series
    stats=glm_fmri_fit_vol(func.data,X,[],mask.data);
    
    out = func;
    out.fname = sprintf(outFilePath,subject);
    out.data = stats.err_ts;
    
   
   writeFileNifti(out);
   
end % subjects


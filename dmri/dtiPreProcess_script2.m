% dti pre-processing script 2
% --------------------------------
% usage: stuff to run after dtiPreProcess_script
% 
% does the following: 
% - loads DA roi .mat file to determine the most inferior coordinate and
%  makes a new brainmask clipping off voxels that are 2 or more coords more
%  inferior than the DA roi mask
% - makes a b_file from the bvecs and bvals file formatted for mrtrix
% processing
% - what else? 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all


% get experiment-specific paths & cd to main data dir
p = getSA2Paths; cd(p.data);


% define subjects to process
% subjects=getSA2Subjects;
% subjects = {'9','10','11','12'};
subjects = getSA2Subjects('dti');



%% do it

i = 1;
for i = 3:numel(subjects)
    
    subject = subjects{i};
    fprintf(['\nworking on subject ' subject '...\n']);
    p=getSA2Paths(subject);
    
    
     %% save out L and R DA ROI masks for fiber tracking & save in .mat format
     
     cd(p.ROIs);
     roiSplitLR('DA.nii.gz',1);
     roiNiftiToMat('DA.nii.gz',1); 
     roiNiftiToMat('DAL.nii.gz',1); roiNiftiToMat('DAR.nii.gz',1);
    
    %% clip brain mask according to most inferior slice of DA ROI mask to exclude the pons, etc.
    
    % define z-coord thresh as 3 less than most inferior DA ROI coord
    load('DA.mat')
    z_thresh = min(roi.coords(:,3))-3; 
    
    cd(fullfile(p.dti_proc, 'bin'));
    bm = niftiRead('brainMask.nii.gz');
    
    k_thresh = floor(mrAnatXformCoords(bm.qto_ijk,[0 0 z_thresh])); 
    k_thresh = k_thresh(3); % threshold coord in img space
    
    orig = bm;
    orig.fname = 'brainMaskOrig.nii.gz';
    writeFileNifti(orig);
    
    bm.data(:,:,1:k_thresh-1) = 0;
    writeFileNifti(bm);
    

    %% make b_file for mrtrix 
 
    cd(p.dti_proc);
    bval_file = dir('*aligned*.bvals');
    bvec_file = dir('*aligned*.bvecs');
    if numel(bval_file)==1 && numel(bvec_file)==1
        makeMrTrixGradFile(bval_file.name, bvec_file.name, 'bin/b_file');
    else
        error('either 0 or more than 1 file found for bvec/val files. Check the input directory before continuing.');
    end
    
    fprintf('done.\n\n');
    
end % subjects loop


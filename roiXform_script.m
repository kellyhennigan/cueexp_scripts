% script to transform ROIs defined in structural acpc space to functional
% space

% assumes the ROIs and functional data are in alignment, but just have 
% different voxel dimensions

clear all
close all


funcNii = niftiRead('/Users/Kelly/cueexp/data/zl150930/func_proc/cue_pp_tlrc.nii'); 
niiOut = funcNii;
niiOut.data = zeros(funcNii.dim(1:3));

% xform DA in structural native space to functional tlrc space
roiInDir =  '/Users/Kelly/cueexp/data/ROIs/apriori';
roiOutDir = roiInDir;
roiNames = {'acing','dlpfc','mpfc', 'caudate','ins','nacc8mm'};



for r=1:numel(roiNames)
    
    roiNii = niftiRead(fullfile(roiInDir,[roiNames{r} '.nii']));
    
        % get roi coords in img space
        [i j k]=ind2sub(size(roiNii.data),find(roiNii.data));

% xform coords to acpc space
acpc_coords = mrAnatXformCoords(roiNii.qto_xyz,[i j k]);

    % now xform to get img coords for functional data
    img_coords = round(mrAnatXformCoords(niiOut.qto_ijk,acpc_coords));

    % index for new roi coords
idx = sub2ind(size(niiOut.data),img_coords(:,1),img_coords(:,2),img_coords(:,3));

outRoiNii = niiOut;
outRoiNii.data(idx) = 1;
outRoiNii.fname = fullfile(roiOutDir,[roiNames{r} '_func.nii.gz']);
writeFileNifti(outRoiNii)

end


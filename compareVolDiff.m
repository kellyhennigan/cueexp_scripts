% script to compare differences in roi volume between controls and
% patients with stimulant use disorder


% get file paths for cue exp
p = getCuePaths;
dataDir = p.data; % main data dir

% get subject ids and group index; gi=0 for controls and gi=1 for patients
[subjects,gi]=getCueSubjects;

% roi of interest
roiName = input('name of roi to test:','s');

% determine
for i=1:numel(subjects)
    
    % L roi
    roiL = niftiRead(fullfile(dataDir,subjects{i},'ROIs',[roiName 'L.nii.gz']));
    roiL_vol(i,1) = numel(roiL.data(roiL.data==1));
    
    % R roi
    roiR = niftiRead(fullfile(dataDir,subjects{i},'ROIs',[roiName 'R.nii.gz']));
    roiR_vol(i,1) = numel(roiR.data(roiR.data==1));
  
    % L and R rois
    roi = niftiRead(fullfile(dataDir,subjects{i},'ROIs',[roiName '.nii.gz']));
    roi_vol(i,1) = numel(roi.data(roi.data==1));
  
end

[hL,pL]=ttest2(roiL_vol(gi==0),roiL_vol(gi==1))
[hR,pR]=ttest2(roiR_vol(gi==0),roiR_vol(gi==1))
[h,p]=ttest2(roi_vol(gi==0),roi_vol(gi==1))

mean(roiL_vol(gi==0))
mean(roiR_vol(gi==0))
mean(roi_vol(gi==0))




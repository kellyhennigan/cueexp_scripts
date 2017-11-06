% script for saving out roi betas

% this is basically to define the files, etc. to feed to the function,
% saveOutRoiBetas()



%% define variables:

clear all
close all

% get cue exp file paths, task, and subjects
[p,task,subjects,gi]=whichCueSubjects('stim');
dataDir = p.data;


bStr = 'pa_drugs'; % beta string (e.g., pa or pref)

% ROIs
% roiNames = {'VTA','ins_desai','mpfc','vstriatumR_clust','vstriatumL_clust','VTA_clust'};
roiDir = fullfile(dataDir,'ROIs');
roiNames = whichRois(roiDir,'_func.nii','_func.nii');


% directory that contains glm results of interest
% resultsDir = fullfile(dataDir,['results_' task '_afni']);
resultsDir = fullfile(dataDir,['results_' task '_afni_pa_cond']);


fileStr = 'glm_padrugs_B+tlrc.HEAD'; % string identifying files w/single subject beta maps

% volIdx = [16,17,18]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
% bNames = {'drugs','food','neutral'}; % bNames should correspond to volumes in index volIdx
volIdx = [19]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
bNames = {bStr}; % bNames should correspond to volumes in index volIdx

% out file path
outStrPath = fullfile(resultsDir,'roi_betas','%s','%s.csv'); %s is roiNames and bNames


%% do it

for j = 1:numel(roiNames)
    
    roiFilePath = fullfile(roiDir,[roiNames{j} '_func.nii']);
    
    for k = 1:numel(bNames)
        
        outFilePath = sprintf(outStrPath,roiNames{j},bNames{k});
        
        B = saveOutRoiBetas(roiFilePath,subjects,resultsDir,fileStr,volIdx(k),outFilePath);
        
    end % beta names
    
end % roiNames




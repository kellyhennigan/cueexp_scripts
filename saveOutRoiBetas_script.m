% script for saving out roi betas

% this is basically to define the files, etc. to feed to the function,
% saveOutRoiBetas()



%% define variables:

clear all
close all

% get cue exp file paths, task, and subjects
[p,task,subjects,gi]=whichCueSubjects('stim');
dataDir = p.data;


% ROIs
roiNames = {'nacc_desai','mpfc'};
roiStrPath = fullfile(dataDir,'ROIs','%s_func.nii'); %s is roiStrs

% directory that contains glm results of interest
resultsDir = fullfile(dataDir,['results_' task '_afni']);

fileStr = 'glm_B+tlrc.HEAD'; % string identifying files w/single subject beta maps

volIdx = [13,15]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
bNames = {'gvnant','gvnout'}; % bNames should correspond to volumes in index volIdx

% out file path
outStrPath = fullfile(resultsDir,'roi_betas','%s','%s.csv'); %s is roiNames and bNames


%% do it

for j = 1:numel(roiNames)
    
    roiFilePath = sprintf(roiStrPath,roiNames{j});
    
    for k = 1:numel(bNames)
        
        outFilePath = sprintf(outStrPath,roiNames{j},bNames{k});
        
        B = saveOutRoiBetas(roiFilePath,subjects,resultsDir,fileStr,volIdx(k),outFilePath);
        
    end % beta names
    
end % roiNames




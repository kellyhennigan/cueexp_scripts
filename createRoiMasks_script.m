%% script to create ROI mask nifti files using freesurfer's
% segmentation file

% for Freesurfer label values, see here: 
% http://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI/FreeSurferColorLUT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Striatum %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L and R NAcc - 26/58
% L and R Caudate - 11/50
% L and R Putamen - 12/51

% roiNames = {'nacc';
%     'caudate';
%     'putamen'};
% 

% labels = {26,58;
%     11,50;
%     12,51}; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Frontal Cortex %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L and R caudalanteriorcingulate - 1002/2002
% L and R caudalmiddlefrontal - 1003/2003
% L and R lateralorbitofrontal - 1012/2012
% L and R medialorbitofrontal - 1014/2014
% L and R parsopercularis - 1018/2018
% L and R parsorbitalis - 1019/2019
% L and R parstriangularis - 1020/2020
% L and R precentral - 1024/2024
% L and R rostralanteriorcingulate - 1026/2026
% L and R rostralmiddlefrontal - 1027/2027
% L and R superiorfrontal - 1028/2028
% L and R frontalpole - 1032/2032
% 
% roiNames = {'caudalanteriorcingulate';
%     'caudalmiddlefrontal';
%     'lateralorbitofrontal';
%     'medialorbitofrontal';
%     'parsopercularis';
%     'parsorbitalis';
%     'parstriangularis';
%     'precentral';
%     'rostralanteriorcingulate';
%     'rostralmiddlefrontal';
%     'superiorfrontal';
%     'frontalpole'};
% 
% labels = {1002,2002;
%     1003,2003;
%     1012,2012;
%     1014,2014;
%     1018,2018;
%     1019,2019;
%     1020,2020;
%     1024,2024;
%     1026,2026;
%     1027,2027;
%     1028,2028;
%     1032,2032};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Other structures of interest %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L and R amygdala - 18/54
% L and R hippocampus - 17/53
% L and R insula - 19/55;
% L and R ventral DC  - 28/60
% L and R thalamus (proper)  - 10/49

% roiNames = {'hippocampus';
%     'amygdala';
%     'insula';
%     'ventralDC'
%     'thalamus'};
%
% labels = {17,53;
%     18,54;
%     19,55;
%     28,60;
%     10,49};
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define base directory, subject folders, freesurfer labels, and ROI names

clear all
close all

[p,task,subjects,gi]=whichCueSubjects('stim','');
dataDir = p.data;

% path to freesurfer segmentation file; %s is subject id
segFilePath = fullfile(dataDir,'%s','t1','aparc+aseg.nii.gz');  % subject's aparc+aseg nii file

% %s is subject id
outDir = fullfile(dataDir,'%s','ROIs');

% roiNames & corresponding labels
roiNames = {'nacc';
    'caudate';
    'putamen'};


labels = {26,58;
    11,50;
    12,51}; 




%% Get to it

for i = 1:length(subjects)          % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    seg = niftiRead(sprintf(segFilePath,subject));
    
    % define this out dir if it doesn't already exist
    thisOutDir = sprintf(outDir,subject);
    if ~exist(thisOutDir,'dir')
        mkdir(thisOutDir)
    end
    
    for j = 1:numel(roiNames)
        
        % create & save out left ROI
        roiL = createNewNii(seg,[thisOutDir '/' roiNames{j} 'L']);
        roiL.data(seg.data == labels{j,1})=1; roiL.data = single(roiL.data);
        writeFileNifti(roiL);
        roiNiftiToMat(roiL,1);
        
        % " " right ROI
        roiR = createNewNii(seg,[thisOutDir '/' roiNames{j} 'R']);
        roiR.data(seg.data == labels{j,2})=1; roiR.data = single(roiR.data);
        writeFileNifti(roiR);
        roiNiftiToMat(roiR,1);
        
        %         now combine L & R and save out
        roi = createNewNii(seg,[thisOutDir '/' roiNames{j} ]);
        roi.data = roiL.data+roiR.data;
        if any(roi.data(:)>1)
            error(['hold up - L and R ' roiNames{j} ' have overlappling voxels, which shouldn''t happen...'])
        end
        writeFileNifti(roi);
        
    end % rois
     
     fprintf(['done with subject ' subject '.\n\n']);
    
end % subjects


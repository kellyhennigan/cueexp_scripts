
% base dir (one above subject directories)
p = getCuePaths;
dataDir = p.data; % main data dir

subjects = getCueSubjects;

roiNames = {'caudalanteriorcingulate';
    'caudalmiddlefrontal';
    'lateralorbitofrontal';
    'medialorbitofrontal';
    'parsopercularis';
    'parsorbitalis';
    'parstriangularis';
    'precentral';
    'rostralanteriorcingulate';
    'rostralmiddlefrontal';
    'superiorfrontal';
    'frontalpole'};
% 



for i=1:numel(subjects)
    
    cd(fullfile(dataDir,subjects{i},'ROIs'))
    
    roi = niftiRead([roiNames{1} '.nii.gz']);
    
    for j=2:numel(roiNames)
        temp = niftiRead([roiNames{j} '.nii.gz']);
        
        roi.data(find(temp.data==1))=1;
    end
    roi.fname = 'PFC.nii.gz';
    writeFileNifti(roi);
    cd(dataDir);
end

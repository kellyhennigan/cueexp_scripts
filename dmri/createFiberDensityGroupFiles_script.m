%% script to make fiber density maps

% this script:

% assumes createFiberDensityFiles_script has already been run. It takes the
% single subject output files from that script, combines the maps into a 4d
% nifti (along with a mean) and saves it out. 



%% define directories and file names, load files


clear all
close all

p=getCuePaths();
dataDir = p.data;

% list of subjects to include
subjects=getCueSubjects('dti');
% e.g., subjects={'sub001','sub002',etc};

% directory (relative to subject dir) that has fiber density files
inDir = fullfile(dataDir,'%s','fg_densities','mrtrix_fa');  %s is subject id

inNiiFileStrs = {'DAL_naccL_belowAC_autoclean_mni'};

% directory to save out group files
outDir = fullfile(dataDir,'fg_densities','mrtrix_fa');



%% get to it

for j=1:numel(inNiiFileStrs)
    
    % get file string and name of nifti file to process
    thisNiiStr=inNiiFileStrs{j};
    thisNii=[thisNiiStr,'.nii.gz'];
    
    % load subjects' nifti files & concatenate them
    niis=cellfun(@(x) niftiRead(fullfile(sprintf(inDir,x),thisNii)), subjects, 'uniformoutput',1);
    fdImgs ={niis(:).data};
    fdImgs=cell2mat(reshape(fdImgs,1,1,1,[])); % concat subjects in 4th dim
    
    % save out new nifti file of all subjects' data
    outNii=createNewNii(niis(1),fullfile(outDir,[thisNiiStr '_ALL.nii.gz']),fdImgs);
    writeFileNifti(outNii);
    
    % play nice in afni
    cmd = sprintf(['3drefit -view tlrc -space ' gspace ' ' outNii.fname]);
    system(cmd);
    
    % save out nifti file of the mean across subjects
    outNii.data=mean(outNii.data,4);
    outNii.fname=fullfile(outDir,[thisNiiStr '_MEAN.nii.gz']);
    writeFileNifti(outNii);
    
    % play nice in afni
    cmd = sprintf(['3drefit -view tlrc -space ' gspace ' ' outNii.fname]);
    system(cmd);
    
end % for fd densities nifti files


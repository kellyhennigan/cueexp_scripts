%% script to make fiber density maps

% this script:

% assumes createFiberDensityFiles_script has already been run. It takes the
% single subject output files from that script, combines the maps into a 4d
% nifti (along with a mean) and the center of mass coordinates into a 2D matrix and saves them
% out.



%% define directories and file names, load files


clear all
close all

p=getCuePaths();
dataDir = p.data;

% list of subjects to include
subjects=getCueSubjects('dti',0);
% subjects = {'tm160117','jh160702'};

% directory (relative to subject dir) that has fiber density files

method = 'mrtrix_fa';

inDir = fullfile(dataDir,'%s','fg_densities',method);  %s is subject id


% script will loop over these
% inNiiFileStrs = {
%     'DAL_caudateL_autoclean_DAendpts_tlrc';
%     'DAR_caudateR_autoclean_DAendpts_tlrc';
%     'DA_caudate_autoclean_DAendpts_tlrc';
%     'DAL_putamenL_autoclean_DAendpts_tlrc';
%     'DAR_putamenR_autoclean_DAendpts_tlrc';
%     'DA_putamen_autoclean_DAendpts_tlrc'
%     };
% inNiiFileStrs = {
%     'DAL_naccL_belowAC_dil2_autoclean_mni';
%     'DAR_naccR_belowAC_dil2_autoclean_mni';
%     'DA_nacc_belowAC_dil2_autoclean_mni';
%     'DAL_naccL_aboveAC_dil2_autoclean_mni';
%     'DAR_naccR_aboveAC_dil2_autoclean_mni';
%     'DALR_naccLR_aboveAC_dil2_autoclean_mni';
%     'DAL_caudateL_dil2_autoclean_mni';
%     'DAR_caudateR_dil2_autoclean_mni';
%     'DALR_caudateLR_dil2_autoclean_mni';
%     'DA_caudate_dil2_autoclean_mni';
%     'DAL_putamenL_dil2_autoclean_mni';
%     'DAR_putamenR_adil2_utoclean_mni';
%     'DA_putamen_autoclean_mni'
%     };
% 
% inNiiFileStrs = {
%     'DAL_naccL_belowAC_dil2_autoclean_mni';
%     'DAR_naccR_belowAC_dil2_autoclean_mni';
%     'DA_nacc_belowAC_dil2_autoclean_mni'};

inNiiFileStrs = {
    'DA_putamen_dil2_autoclean_mni'
    };



inCoMFiles={};
% inNiiFileStrs = {'DAL_naccL_belowAC_dil2_autoclean_tlrc';
%     'DAR_naccR_belowAC_dil2_autoclean_tlrc';
%     'DAL_naccL_aboveAC_dil2_autoclean_tlrc';
%     'DAR_naccR_aboveAC_dil2_autoclean_tlrc';
%     'DA_nacc_belowAC_dil2_autoclean_tlrc';
%     'DA_nacc_aboveAC_dil2_autoclean_tlrc'
%     };

% script will independently loop over these CoM files
% inCoMFiles = {'DAL_naccL_belowAC_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAR_naccR_belowAC_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAL_naccL_aboveAC_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAR_naccR_aboveAC_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAL_caudateL_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAR_caudateR_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAL_putamenL_dil2_autoclean_DAendpts_CoM_tlrc';
%     'DAR_putamenR_dil2_autoclean_DAendpts_CoM_tlrc'};
% inCoMFiles = {
%     'DAL_caudateL_autoclean_DAendpts_CoM_tlrc';
%     'DAR_caudateR_autoclean_DAendpts_CoM_tlrc';
%     'DAL_putamenL_autoclean_DAendpts_CoM_tlrc';
%     'DAR_putamenR_autoclean_DAendpts_CoM_tlrc'};


% directory to save out group files
outDir = fullfile(dataDir,'fg_densities',method);



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
    cmd = sprintf(['3drefit -view tlrc -space mni ' outNii.fname]);
    system(cmd);
    
    % save out nifti file of the mean across subjects
    outNii.data=mean(outNii.data,4);
    outNii.fname=fullfile(outDir,[thisNiiStr '_MEAN.nii.gz']);
    writeFileNifti(outNii);
    
    % play nice in afni
    cmd = sprintf(['3drefit -view tlrc -space mni ' outNii.fname]);
    system(cmd);
    
end % for fd densities nifti files



%% center of mass files
%
for j=1:numel(inCoMFiles)

    CoMfile = inCoMFiles{j};

    % load subjects' CoM files & concatenate the coords with subjects in rows
    CoMs=cellfun(@(x) dlmread(fullfile(sprintf(inDir,x),CoMfile)), subjects,'uniformoutput',0)
    CoMs=cell2mat(CoMs);

    % save out concatenated data w/subject ids
    T = table([subjects],CoMs);
    writetable(T,fullfile(outDir,[CoMfile '_ALL']),'WriteVariableNames',0);


end


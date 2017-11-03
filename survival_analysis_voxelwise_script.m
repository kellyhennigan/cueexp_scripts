% script to do voxelwise survival analysis

% check out freesurfer matlab survival analysis package as well: 
% https://surfer.nmr.mgh.harvard.edu/fswiki/SurvivalAnalysis

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
task = 'cue';

p = getCuePaths();

dataDir = p.data;

betaDir = fullfile(dataDir,'results_cue_afni');

stims = {'drugs','food','neutral'};

beta_fstr = '_glm+tlrc';

subjects = getCueSubjects('cue',1);

outDir = fullfile(betaDir,'survival_analysis');
if ~exist(outDir,'dir')
    mkdir(outDir)
end

mask = niftiRead(fullfile(dataDir,'templates','bmask.nii')); % brain mask
% mask = niftiRead(fullfile(dataDir,'ROIs','naccR_single_vox_func.nii')); % brain mask

%%  extract beta values of interest and save out as separate single volume nifti files
% 
% cd(betaDir)
% for k=1:numel(stims)
%     
%     for i=1:numel(subjects)
%         
%         cmd = ['3dinfo -label2index ' stims{k} '#0_Coef ' subjects{i} beta_fstr]
%         [status,cmdout]=system(cmd);
%         si=strfind(cmdout,sprintf('\n')); % index number is between 2 line breaks
%         
%         outfile =  [outDir '/' subjects{i} '_' stims{k} '.nii']; % nifti filepath for saving out beta map
%         cmd = ['3dTcat ' subjects{i} beta_fstr '[' cmdout(si(1)+1:si(2)-1) '] -output ' outfile];
%         [status,cmdout]=system(cmd);
%         
%     end % subjects
%     
% end % stims


%% get survival data

relapse = getCueData(subjects,'relapse');
obstime = getCueData(subjects,'observedtime');

% omit subjects without followup data from analysis
nanidx = find(isnan(relapse));
relapse(nanidx) = [];
obstime(nanidx) = [];
subjects(nanidx) = [];

censored = abs(relapse-1); % censored var is 1 for non-relapse, 0 for relapse

% k=1
for k=1:numel(stims)

for i=1:numel(subjects)
    
    bfile =  [outDir '/' subjects{i} '_' stims{k} '.nii']; % nifti filepath for saving out beta map
     ni = niftiRead(bfile);
     X(i,:) = double(reshape(ni.data,1,[])); % all this subjects' voxels in the ith row
   
end

fprintf(['\nworking on survival analysis for ' stims{k} ' betas...\n'])

% there's prob a better/faster way to do this...
Z = zeros(size(mask.data));

for vi = find(mask.data)'
    
    [b,logl,H,stats] = coxphfit(X(:,vi),obstime,'Censoring',censored);
    Z(vi) = stats.z;

end % voxels in brain mask

outPath = fullfile(outDir,['Z' stims{k} '.nii.gz']); % out filepath
Zni = createNewNii(mask,outPath,Z,['zscores for Cox regression on n=' num2str(numel(subjects)) ' patients']);     
     
writeFileNifti(Zni); % save out nifti volume
cmd = ['3drefit -fbuc -sublabel 0 CoxZ -substatpar 0 fizt ' outPath];
disp(cmd);
system(cmd);

fprintf(['done.\n\n'])

end % stims





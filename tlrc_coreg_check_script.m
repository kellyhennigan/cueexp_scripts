% script to gather up reference volumes & anatomy in group space to
% manually check coregistration


clear all
close all

% probably shouldn't have to edit these too much...
p = getCuePaths;
dataDir = p.data;

outDir = fullfile(dataDir, 'tlrc_coreg_check');


subjects = getCueSubjects;

tasks = {'cue','mid','midi'};

%% do it

cd(dataDir);
if ~exist(outDir,'dir')
    mkdir(outDir)
end

for s=1:numel(subjects)
    
    subject = subjects{s};
    fprintf(['\n\n working on subject, ' subject '...']);
    
    % anatomy
    fp = [subject '/func_proc/t1_tlrc.nii.gz'];
    if exist(fp,'file')
        copyfile(fp,[outDir '/' subject '_t1.nii.gz']);
    end
    
    % cue, mid, and midi ref vols
    
    for a = 1:numel(tasks)
        
        task = tasks{a};
        
        fp = [subject '/func_proc/refvol_' task '_tlrc.nii'];
        if exist(fp,'file')
            copyfile(fp,[outDir '/' subject '_refvol_' task '.nii']);
        end
        fp2 =  [subject '/func_proc/refvol_' task '_noCoreg_tlrc.nii'];
        if exist(fp2,'file')
            copyfile(fp2,[outDir '/' subject '_refvol_' task '_noCoreg.nii']);
        end
        
    end % tasks
    
    fprintf('done.\n')
    
end % subjects 
%% script to make fiber density maps

% this script:

% loads in fibers in subject's native (acpc-aligned) space,
% takes just the fiber endpoints from 1 or both ROIs,
% converts the fibers into a density map,
% transforms the density maps into standard space using ANTS xforms,
% normalizes each L and R map to have a max value=1,
% combines L and R sides
%



%% define directories and file names, load files


clear all
close all

p=getCuePaths();
dataDir = p.data;

subjects=getCueSubjects('dti',0);
% subjects = {'tm160117'};

% fibers directory relative to subject dir
inDir = 'fibers/mrtrix_fa';

seed = 'DA';
target = 'putamen';

LorR = ['L','R']; % if ['L','R'], script shold loop over l/r sides;

% string to identify fiber group files
fgStr = [seed '%s_' target '%s_dil2_autoclean']; % %s' are L or R

% outDir, relative to subject directory
outDir = 'fg_densities/mrtrix_fa';

% name for output fiber density nifti files
outStr = [seed '%s_' target '%s_dil2'];

% t1 file in dti/native space
t1File = 't1.nii.gz'; %s is subject id

% dt6.mat file
dt6File = 'dti96trilin/dt6.mat'; %s is subject id

% subject-specific xforms for native > tlrc space
xform_aff='t1/t12tlrc_xform_Affine.txt';
xform_warp='t1/t12tlrc_xform_Warp.nii.gz';
xform_invwarp='t1/t12tlrc_xform_InverseWarp.nii.gz';


% options
only_seed_endpts = 1; % create density maps of only seed endpoints?
only_endpts = 0; % create density maps of only seed/target endpoints?
smooth = 3; % 0 or empty to not smooth, otherwise this defines the smoothing kernel

saveOutGroupFiles=1; % 1 save out group files in standard space, otherwise 0
groupOutDir = fullfile(dataDir,'fg_densities/mrtrix_fa');


%% get to it

if smooth
    outStr = [outStr '_smooth' num2str(smooth)];
end

i=1;

groupVols = []; % array to hold subjects' fiber density aps in group space

for i=1:numel(subjects)
    
    subject = subjects{i};
    
    fprintf(['\n\n Working on subject ',subject,'...\n\n']);
    
    cd(fullfile(dataDir,subject));
    
    lr_idx=1; % counter for left/right side
    
    for lr=LorR
        
        %% load in fibers in subject's native (acpc-aligned) space
        
        fgFileName = [sprintf(fgStr,lr,lr) '.pdb'];
        fg = fgRead([sprintf(inDir,subject) '/' fgFileName]);
        
        % load seed and target rois
        roi1 = roiNiftiToMat(['ROIs/' seed lr '.nii.gz']);
        roi2 = roiNiftiToMat(['ROIs/' target lr '.nii.gz']);
        
        % reorient to make sure all fibers start in roi1 and end in roi2
        [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
        
        % to use just seed endpoints of fibers:
        if only_seed_endpts
            fg.fibers = cellfun(@(x) x(:,1), fg.fibers,'UniformOutput',0);
            %                 outStr = [outStr, '_' seed 'endpts'];
        end
        
        %% convert the fibers into a density map
        
        % make out directory if it doesn't already exist
        if ~exist(outDir, 'dir')
            mkdir(outDir)
        end
        
        
        % load dt6.mat and t1 images
        %     dt = dtiLoadDt6(dt6File);
        t1 = niftiRead(t1File);
        
        % make fiber density maps
        %fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
        fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,only_endpts);
        
        % Smooth the image?
        if smooth
            fd = smooth3(fd, 'gaussian', smooth);
        end
        
        % save out new fiber density file
        outName=sprintf(outStr,lr,lr);
        outFilePath = fullfile(outDir,outName);
        nii=createNewNii(t1,fd,outFilePath,'fiber density');
        writeFileNifti(nii);
        
        % xform to standard space
        nsFilePath=[outFilePath '.nii.gz']; % native space file path
        ssFilePath=[outFilePath '_tlrc.nii.gz']; % standard space file path
        ssNii=xformANTs(nsFilePath,ssFilePath,xform_aff,xform_warp);
        ssNii.data=ssNii.data./max(ssNii.data(:)); % normalize so that the max value is 1
        writeFileNifti(ssNii);
        
        % save out center of mass coords
        imgCoM = centerofmass(nii.data);
        CoM = mrAnatXformCoords(nii.qto_xyz,imgCoM);
        comFilePath = fullfile(outDir,[outName '_CoM']);
        dlmwrite(comFilePath,CoM);
        
        % convert center of mass coords to standard space
        CoMtlrc = xformCoordsANTs(comFilePath,xform_aff,xform_invwarp);
        groupCoMs{lr_idx}(i,:)=CoMtlrc; % keep track of everyones CoM coords in tlrc space
        
        lr_idx=lr_idx+1; % counter for left right side
        
    end % LorR
    
    % mergeLR
    niiL = fullfile(outDir,[sprintf(outStr,'L','L') '_tlrc.nii.gz']);
    niiR = fullfile(outDir,[sprintf(outStr,'R','R') '_tlrc.nii.gz']);
    niiLR = fullfile(outDir,[strrep(outStr,'%s','') '_tlrc.nii.gz']);
    niiLR = mergeNiis({niiL,niiR},niiLR,1);
    groupVols(:,:,:,i)=niiLR.data;
    
    
end % subjects


%% save out group files

if saveOutGroupFiles
    if ~exist(groupOutDir, 'dir')
        mkdir(groupOutDir)
    end
    
    % save out nifti file w/everyones fiber density map & the group average
    groupNii = niiLR;
    groupNii.fname = fullfile(groupOutDir,[strrep(outStr,'%s','') '_ALL.nii.gz']);
    groupNii.data=groupVols;
    writeFileNifti(groupNii);
    cmd = sprintf(['3drefit -view tlrc -space tlrc ' groupNii.fname]);    
    system(cmd);

    groupNii.fname = fullfile(groupOutDir,[strrep(outStr,'%s','') '_MEAN.nii.gz']);
    groupNii.data=mean(groupNii.data,4);
    writeFileNifti(groupNii);
    cmd = sprintf(['3drefit -view tlrc -space tlrc ' groupNii.fname]);    
    system(cmd);

    
    % save out L & R center of mass coords in tlrc space
    T = table([subjects],[groupCoMs{1}]);
    outNameL=fullfile(groupOutDir,[sprintf(outStr,'L','L') '_CoM_tlrc']);
    writetable(T,outNameL,'WriteVariableNames',0);
    
    T = table([subjects],[groupCoMs{2}]);
    outNameR=fullfile(groupOutDir,[sprintf(outStr,'R','R') '_CoM_tlrc']);
    writetable(T,outNameR,'WriteVariableNames',0);
   
    
    
end



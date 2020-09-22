%% Make fiber density maps

% saves out niftis with values that represent whether fibers go through
% that voxel and if so, how many. Scaled to have a max value of 1.

%
% NOTE: if mergeLR=1, this script first saves out the L and R fiber density
% maps, then xforms them to group space and normalizes them so that they
% each have a max value of 1, then combines L and R sides.




%% define directories and file names, load files


clear all
close all

p=getCuePaths();
dataDir = p.data;
% e.g., dataDir='/Users/span/lvta/cueexp/data'

subjects=getCueSubjects('dti');
% e.g., subjects={'sub001','sub002',etc};


seeds = {'DA'};

targets = {'nacc'}; 

% string to identify fiber files 
fgFileStrs = {'%s%s_%s%s_autoclean'}; 


% string to include on outfile?
outNameStr = '';


% t1 file in dti/native space
t1File = fullfile(dataDir,'%s','t1.nii.gz'); %s is subject id


% define fg_densities directory (directory to save out file to)
fdDir = fullfile(dataDir,'%s','fg_densities','mrtrix_fa');  %s is subject id


% subject-specific xforms for native > mni space
xform_aff=fullfile(dataDir,'%s','t1','t12mni_xform_Affine.txt');
xform_warp=fullfile(dataDir,'%s','t1','t12mni_xform_Warp.nii.gz');


% options
smooth = 0; % 0 or empty to not smooth, otherwise this defines the smoothing kernel

LorR = ['L','R']; % if ['L','R'], script shold loop over l/r sides;
mergeLR = 1; % 1 to merge l/r sides; otherwise 0. Merges AFTER xform to standard space



%% get to it

cd(dataDir);

i=1;
for i=1:numel(subjects)

    subject = subjects{i};

    fprintf(['\n\n Working on subject ',subject,'...\n\n']);


    % define fg_densities directory; create if necessary
    thisFdDir = sprintf(fdDir,subject);
    if (~exist(thisFdDir, 'dir'))
        mkdir(thisFdDir)
    end


    % load t1 volume
    t1 = niftiRead(sprintf(t1File,subject));

    j=1;
    for j=1:numel(seeds)

        seed = seeds{j};
        target = targets{j};
        fgFileStr=fgFileStrs{j};

        lrFileNames = {};

        for lr=LorR
            
            % fill in the name of this fiber group, e.g.: "mpfcL_naccL_autoclean"
            thisFgStr = sprintf(fgFileStr,seed,lr,target,lr);  
            
            roi1 = roiNiftiToMat(fullfile(dataDir,subject,['ROIs/' seed lr '.nii.gz']));

            roi2 = roiNiftiToMat(fullfile(dataDir,subject,['ROIs/' target lr '.nii.gz']));

            % load fiber group
            fg = fgRead(fullfile(dataDir,subject,'fibers','mrtrix_fa',[thisFgStr '.pdb']));

            % reorient to make sure all fibers start in roi1 and end in roi2
            [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);

            % define out name for fiber density file
            outName = [thisFgStr outNameStr];
        
            % make fiber density maps
            %fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
            fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,0);

            % save new fiber density file
            outPath = fullfile(thisFdDir,outName);
            nii=createNewNii(t1,fd,outPath,'fiber density');
            writeFileNifti(nii);

            % xform to standard space?
            inFile=[outPath '.nii.gz'];
            outFile=[outPath '_mni.nii.gz'];
            outNii=xformANTs(inFile,outFile,sprintf(xform_aff,subject),sprintf(xform_warp,subject));

            % Smooth the image?
            if smooth
                outNii.data = smooth3(outNii.data, 'gaussian', smooth);
            end

            % scale to have max value of 1 in group space
            outNii.data=outNii.data./max(outNii.data(:));

            % save out fiber density file in group space
            writeFileNifti(outNii);

            if mergeLR
                lrFileNames{end+1}=outNii.fname;
            end

            clear imgCoM CoM nii fd fg

        end % lr

        if mergeLR
            outPathLR = fullfile(thisFdDir,[strrep(strrep(outName,'R',''),'L','') '_mni.nii.gz']);
            niiLR=mergeNiis({lrFileNames{1},lrFileNames{2}},outPathLR);
            writeFileNifti(niiLR);
        end

    end % targets

    fprintf(['done with subject ' subjects{i} '.\n\n']);


end % subjects







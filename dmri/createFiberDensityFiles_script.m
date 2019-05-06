%% Make fiber density maps

% assumes all filberfiles have fibers oriented to start in the DA ROI and
% end in the target ROI

% saves out niftis that contain a count of the number of fibers in each
% voxel

%
% NOTE: this script first saves out the L and R fiber density maps, then
% xforms them to tlrc space and normalizes them so that they each have a
% max value of 1, combines L and R sides. Also saves out center of mass
% coords for tlrc space.



%% define directories and file names, load files


clear all
close all

p=getCuePaths();
dataDir = p.data;

[subjects,gi]=getCueSubjects('dti',0);
% subjects=subjects(26:end);
% subjects = {'jh160702'};


method = 'mrtrix_fa';
% method = 'conTrack';


seed = 'DA';
% targets = {'caudate','putamen'};
% targets = {'nacc','nacc','caudate','putamen'};
% targets = {'nacc','nacc'};
targets = {'nacc'};

% string to identify fiber group files (must correspond to targets cell array)
% fgFileStrs = {'belowAC_dil2_autoclean',...
%     'aboveAC_dil2_autoclean',...
%     'dil2_autoclean',...
%     'dil2_autoclean'};
% fgFileStrs = {'autoclean',...
%     'autoclean'};
fgFileStrs = {'belowAC_dil2_autoclean'};

% files are named [target fgFileStr '.pdb']


% string to include on outfile?
outNameStr = '';


% t1 file in dti/native space
t1File = fullfile(dataDir,'%s','t1.nii.gz'); %s is subject id


% define fg_densities directory
fdDir = fullfile(dataDir,'%s','fg_densities',method);  %s is subject id


% dt6.mat file
dt6File = fullfile(dataDir,'%s','dti96trilin','dt6.mat');


% subject-specific xforms for native > tlrc space
xform_aff=fullfile(dataDir,'%s','t1','t12tlrc_xform_Affine.txt');
xform_warp=fullfile(dataDir,'%s','t1','t12tlrc_xform_Warp.nii.gz');
xform_aff2=fullfile(dataDir,'templates','tlrc2mni_xform_Affine.txt');
xform_warp2=fullfile(dataDir,'templates','tlrc2mni_xform_Warp.nii.gz');


% options
only_seed_endpts = 0; % create density maps of only seed endpoints?
only_endpts = 0; % create density maps of only seed/target endpoints?
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
    
    
    % load dt6.mat and t1 images
    dt = dtiLoadDt6(sprintf(dt6File,subject));
    t1 = niftiRead(sprintf(t1File,subject));
    
    j=1;
    for j=1:numel(targets)
        
        target = targets{j};
        fgFileStr=fgFileStrs{j};
        
        lrFileNames = {};
        
        for lr=LorR
            
            roi1 = roiNiftiToMat(fullfile(dataDir,subject,['ROIs/' seed lr '.nii.gz']));
            
            roi2 = roiNiftiToMat(fullfile(dataDir,subject,['ROIs/' target lr '.nii.gz']));
            
            % load fiber group
            fg = fgRead(fullfile(dataDir,subject,'fibers',method,[seed lr '_' target lr '_' fgFileStr '.pdb']));
            
            % reorient to make sure all fibers start in roi1 and end in roi2
            [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
            
            % define out name for fiber density file
            outName = fg.name;
            
            % to use just seed endpoints of fibers:
            if only_seed_endpts
                fg.fibers = cellfun(@(x) x(:,1), fg.fibers,'UniformOutput',0);
                outName = [outName, '_' seed 'endpts'];
            end
            
            % make fiber density maps
            %fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
            fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,only_endpts);
            
            % save new fiber density file
            outName = [outName outNameStr];
            outPath = fullfile(thisFdDir,outName);
            nii=createNewNii(t1,fd,outPath,'fiber density');
            writeFileNifti(nii);
            
            %             % save out center of mass coords
            if only_seed_enpts
                imgCoM = centerofmass(nii.data);
                CoM = mrAnatXformCoords(nii.qto_xyz,imgCoM);
                dlmwrite(fullfile(thisFdDir,[outName '_CoM']),CoM);
            end
            
            % xform to standard space?
            inFile=[outPath '.nii.gz'];
            outFileTLRC=[outPath '_tlrc.nii.gz'];
            outNiiTLRC=xformANTs(inFile,outFileTLRC,sprintf(xform_aff,subject),sprintf(xform_warp,subject));
            
            outFile=[outPath '_mni.nii.gz'];
            outNii=xformANTs(outFileTLRC,outFile,xform_aff2,xform_warp2);
            outNii.data=outNii.data./max(outNii.data(:));
            
            
            % Smooth the image?
            if smooth
                outNii.data = smooth3(outNii.data, 'gaussian', smooth);
            end
            
            writeFileNifti(outNii);
            
            % save out center of mass coords for tlrc space
            if only_seed_endpts
                imgCoM = centerofmass(outNii.data);
                CoM = mrAnatXformCoords(outNii.qto_xyz,imgCoM);
                dlmwrite(fullfile(thisFdDir,[outName '_CoM_mni']),CoM);
            end
            
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


%%








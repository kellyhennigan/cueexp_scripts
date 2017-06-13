%% Make fiber density maps

% assumes all filberfiles have fibers oriented to start in the DA ROI and
% end in the target ROI

% saves out niftis that contain a count of the number of fibers in each
% voxel

%% define directories and file names, load files


clear all
close all

p=getCuePaths();
dataDir = p.data;

[subjects,gi]=getCueSubjects('dti');
% subjects = {'nd150921','bb160402','tm160117'}; gi=[0 0 0];


% method = 'mrtrix';
method = 'conTrack';


seed = 'DA';
targets = {'caudate','putamen'};
% targets = {'nacc'};


% string to identify fiber group files?
fgFileStr = '_autoclean'; % files are named [target fgFileStr '.pdb']


% string to include on outfile?
outNameStr = '';

t1File = 't1.nii.gz';

% options
only_seed_endpts = 0; % create density maps of only seed endpoints?
only_endpts = 1; % create density maps of only seed/target endpoints?
smooth = 0; % 0 or empty to not smooth, otherwise this defines the smoothing kernel

LorR = ['L','R']; % if ['L','R'], script shold loop over l/r sides;
mergeLR = 1; % 1 to merge l/r sides; otherwise 0



%% get to it

cd(dataDir);

i=1;
for i=1:numel(subjects)
    
    subject = subjects{i};
    
    fprintf(['\n\n Working on subject ',subject,'...\n\n']);
    
    
    % cd to subject's directory
    cd(fullfile(dataDir,subject))
    
    
    % define fg_densities directory; create if necessary
    fdDir = fullfile(dataDir,subject, 'fg_densities',method);
    if (~exist(fdDir, 'dir'))
        mkdir(fdDir)
    end
    
    
    % load dt6.mat and t1 images
    dt = dtiLoadDt6(fullfile('dti96trilin','dt6.mat'));
    t1 = readFileNifti(t1File);
    
    
    for j=1:numel(targets)
        
        target = targets{j};
        
        
        for lr=LorR
            
            roi1 = roiNiftiToMat(['ROIs/' seed lr '.nii.gz']);
            
            roi2 = roiNiftiToMat(['ROIs/' target lr '.nii.gz']);
            
            % load fiber group
            fg = fgRead(fullfile('fibers',method,[seed lr '_' target lr fgFileStr '.pdb']));
            
            % reorient to make sure all fibers start in roi1 and end in roi2
            [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
            
            % define out name for fiber density file
            outName = fg.name;
            
            % to use just seed endpoints of fibers:
            if only_seed_endpts
                fg.fibers = cellfun(@(x) x(:,1), fg.fibers,'UniformOutput',0);
                outName = [outName, '_' seed '_endpts'];
            end
            
            % make fiber density maps
            %fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
            fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,only_endpts);
            
            % Smooth the image?
            if smooth
                fd = smooth3(fd, 'gaussian', smooth);
                outName = [outName '_S' num2str(smooth)];
            end
            
            % save new fiber density file
            outName = [outName outNameStr];
            nii=createNewNii(t1,fd,fullfile(fdDir,outName),'fiber density');
            writeFileNifti(nii);
            
            % save out center of mass coords
            imgCoM = centerofmass(nii.data);
            CoM = mrAnatXformCoords(nii.qto_xyz,imgCoM);
            dlmwrite(fullfile(fdDir,[outName '_CoM']),CoM);
            
            clear imgCoM CoM nii fd fg
            
        end % lr
        
        if mergeLR
            outNameR = outName;
            outNameL = strrep(outName,'R','L');
            outNameLR = strrep(outName,'R','');
            niiLR=mergeNiis({fullfile(fdDir,outNameL),fullfile(fdDir,outNameR)},fullfile(fdDir,outNameLR));
            writeFileNifti(niiLR);
        end
        
        
    end % targets
    
    
    fprintf(['done with subject ' subjects{i} '.\n\n']);
    
    
end % subjects











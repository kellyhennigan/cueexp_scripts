%% define variables for calling createOverlayImages


%% 

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getCuePaths;
dataDir=p.data;
cd(dataDir);


% cell array of subject ids to process
subjects=getCueSubjects('dti',0);
subjects = {'zl150930','tm160117'};

bgFilePath = fullfile(dataDir,'%s','t1','t1_tlrc.nii.gz');


% filepath to mask, if desired
% maskFilePath = fullfile(dataDir,'ROIs','DA.nii');

% tracking method
method = 'mrtrix_fa';

smoothstr='_smooth3';

% directory with fiber density files
fdDir = fullfile(dataDir,'%s','fg_densities',method);


% filenames of fiber density files; %s is target
% NOTE: this should be in a cell array with L and R fd maps from the same
% ROIs in the same row, and different paths in different columns, e.g.:
fdFileStrs = {['DA_%s_belowAC_dil2' smoothstr '_tlrc.nii.gz'];
    ['DA_%s_dil2' smoothstr '_tlrc.nii.gz'];
    ['DA_%s_dil2' smoothstr '_tlrc.nii.gz']};

% fdFileStrs = {'DA_%s_belowAC_dil2_tlrc.nii.gz'};

% NOTE: this should be a cell array that matches the dimensions of
% fdFileStrs above
targets={'nacc';
'caudate';
'putamen'};

thresh=.1; % value to threshold maps; otherwise 0 to not threshold

scale = 0; % 1 to scale, otherwise 0

c_range=[.1 .9]; % min/max quantiles of data values to determine color range

plane=2; % which plane to plot

% acpcSlices=[-16:-5]; % which acpc slices to plot
% acpcSlices=[]; % which acpc slices to plot

cols=getDTIFDColors(targets); % colors for fiber density maps

ac=[]; % auto-crop images? inf means no cropping

plotCBar = 0;

saveFigs = 0; % [1/0 to save out slice image, 1/0 to save out cropped image]

figDir = [p.figures '/fg_densities'];

figPrefix = ['NCP' smoothstr];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

for s=1:numel(subjects)
    
    subject=subjects{s};
    
     % load background image
    bg = niftiRead(sprintf(bgFilePath,subject));
   
    
% load fiber density files
fd = cellfun(@(x,y) niftiRead(fullfile(sprintf(fdDir,subject),sprintf(x,y))), fdFileStrs, targets);
fdImgs ={fd(:).data}; fdImgs=reshape(fdImgs,size(targets));
fd = fd(1);  fdXform = fd.qto_xyz;

% if masking overlays is desired, do it
if ~notDefined('maskFilePath')  && ~isempty(maskFilePath)
    mask = niftiRead(maskFilePath);
    fdImgs = cellfun(@(x) double(x) .* repmat(double(mask.data),1,1,1,size(x,4)), fdImgs, 'UniformOutput',0);
end


% if thresholding is desired, do it
if ~notDefined('thresh') && thresh~=0
    fdImgs = cellfun(@(x) threshImg(x, thresh), fdImgs, 'UniformOutput',0);
end


% if scaling is desired, do it
if ~notDefined('scale') && scale==1
    fdImgs = cellfun(@scaleFiberCounts, fdImgs, 'UniformOutput',0);
end


% merge overlays in the same rows (e.g., L and R)
if size(targets,2)>1
    fdImgs = cellfun(@(x,y) x+y, fdImgs(:,1), fdImgs(:,2), 'UniformOutput',0);
end

 
% if acpcSlices isn't defined, plot center of mass coords
if notDefined('acpcSlices') || isempty('acpcSlices')
    coords = round(cell2mat(reshape(cellfun(@(x) getNiiVolStat(x,fd.qto_xyz,'com'), fdImgs, 'UniformOutput',0), [], 1)));
    acpcSlices = unique(coords(:,plane))';
end


nOls = numel(fdImgs); % useful variable to have


%% plot overlay(s)


        j=1;
        for j = 1:nOls
            
            
            % put L/R density maps into nifti structure for its header info
            fd.data = fdImgs{j};
            

            % plot fiber density overlay
            doPlot=0;
            [imgRgbs, olMasks,olVals(j,:),~,acpcSlicesOut] = plotOverlayImage(fd,bg,cols{j},c_range,plane,acpcSlices,doPlot,ac,plotCBar);
            
            
            % cell array of just rgb values for overlays
            olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
            
            
        end % nOls
        
        
        
        %% now combine fiber density overlays for each slice
        
    
        for k=1:numel(acpcSlicesOut)
            
            
            bgImg = imgRgbs{k}; % this is the background image (w/some overlay values for the last fd)
            
            
            % get overlay values for this slice
            sl=cell2mat(permute(olVals(:,k),[3 2 1]));
            
            
            % get fiber density overlay rgb values for this slice
            rgbOverlays = cell2mat(reshape(olRgb(:,k),1,1,1,nOls));
            
            
            % combine rgb overlay images w/nan values for voxels w/no overlay
            thisImg = combineRgbOverlays(rgbOverlays,sl);
            
            
            % add gray scaled background to pixels without an overlay value
            thisImg(isnan(thisImg))=bgImg(isnan(thisImg)); thisImg(thisImg==0)=bgImg(thisImg==0);
            
            
            % cell array w/all combined overlays to plot
            slImgs{k} = thisImg;
            
            
        end % acpcSlices
        
    
    
    %% now plot and (if desired) save images
    
    % put acpcSlices into cell array for cellfun
    acpcSlicesOut = num2cell(acpcSlicesOut);
    
    
    % plot overlay and save new figure
    [h,figNames]= cellfun(@(x,y) plotFDMaps(x,plane,y,saveFigs,figDir,[figPrefix '_' subject]), slImgs, acpcSlicesOut, 'UniformOutput',0);
    
%     close all
    
     clear olVals olRgb slImgs
    
end % subjects










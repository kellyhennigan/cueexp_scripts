%% define variables for calling createOverlayImages


%%

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getCuePaths;
dataDir=p.data;
cd(dataDir);

% filepath to background image
bg = niftiRead(fullfile(dataDir,'templates','TT_N27.nii'));

% filepath to mask, if desired
maskFilePath = fullfile(dataDir,'ROIs','DA.nii');

% tracking method
method = 'mrtrix_fa';

% smoothstr='_smooth3';
smoothstr='';

% directory with fiber density files
fdDir = fullfile(dataDir,'fg_densities',method);


% filenames of fiber density files; %s is target
fdFileStrs = {['DA_%s_belowAC_dil2_autoclean_DAendpts_tlrc' smoothstr '_MEAN.nii.gz'];
    ['DA_%s_dil2_autoclean_DAendpts_tlrc' smoothstr '_MEAN.nii.gz'];
    ['DA_%s_dil2_autoclean_DAendpts_tlrc' smoothstr '_MEAN.nii.gz']};

% NOTE: this should be a cell array that matches the dimensions of
% fdFileStrs above
targets={'nacc';
    'caudate';
    'putamen'};


thresh=0; % value to threshold maps; otherwise 0 to not threshold

scale = 0; % 1 to scale, otherwise 0

crange=[1 numel(targets)]; % min/max quantiles of data values to determine color range

plane=2; % 1 for sagittal, 2 for coronal, 3 for axial

% acpcSlices=[]; % which acpc slices to plot

cols=getDTIColors(targets);

ac=[]; % auto-crop images? inf means no cropping

plotCBar = 0;

saveFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]

figDir = [p.figures '/fg_densities'];

figPrefix = ['win' smoothstr];



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


% load fiber density files
fd = cellfun(@(x,y) niftiRead(fullfile(fdDir,sprintf(x,y))), fdFileStrs, targets);
fdImgs ={fd(:).data}; fdImgs=reshape(fdImgs,size(targets));
fd = fd(1);  fdXform = fd.qto_xyz;

% if scaling is desired, do it
if ~notDefined('scale') && scale==1
    fdImgs = cellfun(@scaleFiberCounts, fdImgs, 'UniformOutput',0);
end

% if thresholding is desired, do it
if ~notDefined('thresh') && thresh~=0
    fdImgs = cellfun(@(x) threshImg(x, thresh), fdImgs, 'UniformOutput',0);
end

% if masking overlays is desired, do it
if ~notDefined('maskFilePath')  && ~isempty(maskFilePath)
    mask = niftiRead(maskFilePath);
    fdImgs = cellfun(@(x) double(x) .* repmat(double(mask.data),1,1,1,size(x,4)), fdImgs, 'UniformOutput',0);
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


% do hard segmentation of voxels based on strongest connectivity
allImgs = cat(4,fdImgs{:});

% get the 'win_idx' - idx of which fd group is biggest for each voxel
[~,win_idx]=max(allImgs,[],4);
win_idx(sum(allImgs,4)==0)=0;

% create a new nifti w/win_idx as img data
fd.data=win_idx;

% plot overlay of voxels w/biggest connectivity
doPlot=0;
[slImgs,~,~,~,acpcSlicesOut] = plotOverlayImage(fd,bg,cols,[1 numel(fdImgs)],plane,acpcSlices,doPlot,ac);


% plot overlay and save new figure
% [h,figName] = plotFDMaps(slImg,plane,acpcSlice,saveFig,figDir,figPrefix,subj)
[h,figNames]= cellfun(@(x,y) plotFDMaps(x,plane,y,saveFigs,figDir,figPrefix), slImgs, num2cell(acpcSlicesOut), 'UniformOutput',0);







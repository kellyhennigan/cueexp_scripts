%% define variables for calling createOverlayImages


%%

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getCuePaths;
dataDir=p.data;
cd(dataDir);


% cell array of subject ids to process
% subjects=getCueSubjects('dti',0);
% subjects = {'zl150930','tm160117'};
% subjects = {'tm160117'};
subjects={'controls'};

bg = niftiRead(fullfile(dataDir,'templates','TT_N27.nii'));


% filepath to mask, if desired
% maskFilePath = fullfile(dataDir,'ROIs','DA.nii');

% tracking method
method = 'mrtrix_fa';

smoothstr='';

% directory with fiber density files
fdDir = fullfile(dataDir,'fg_densities',method);


% filenames of fiber density files; %s is target
% NOTE: this should be in a cell array with L and R fd maps from the same
% ROIs in the same row, and different paths in different columns, e.g.:
if strcmp(subjects{1},'controls')
    fdFileStrs = {['DA_%s_belowAC_dil2' smoothstr '_autoclean_DAendpts_tlrc_MEAN'];
        ['DA_%s_aboveAC_dil2' smoothstr '_autoclean_DAendpts_tlrc_MEAN']
        ['DA_%s_dil2' smoothstr '_autoclean_DAendpts_tlrc_MEAN'];
        ['DA_%s_dil2' smoothstr '_autoclean_DAendpts_tlrc_MEAN']};
else
    fdFileStrs = {['DA_%s_belowAC_dil2' smoothstr '_autoclean_DAendpts_tlrc_ALL'];
        ['DA_%s_aboveAC_dil2' smoothstr '_autoclean_DAendpts_tlrc_ALL']
        ['DA_%s_dil2' smoothstr '_autoclean_DAendpts_tlrc_ALL'];
        ['DA_%s_dil2' smoothstr '_autoclean_DAendpts_tlrc_ALL']};
end
%
% fdFileStrs = {
%     ['DA_%s_dil2' smoothstr '_autoclean_DAendpts_tlrc_ALL.nii.gz'];
%     };


% NOTE: this should be a cell array that matches the dimensions of
% fdFileStrs above
targets={'nacc';
    'nacc';
    'caudate';
    'putamen'};
% targets={
%     'putamen'};

thresh=.05; % value to threshold maps; otherwise 0 to not threshold

scale = 0; % 1 to scale, otherwise 0

q_crange=[.1 .9]; % min/max quantiles of data values to determine color range

plane=3; % which plane to plot

acpcSlices=[-10]; % which acpc slices to plot
% acpcSlices=[]; % which acpc slices to plot

cols=getDTIFDColors(targets,fdFileStrs); % colors for fiber density maps

ac=[]; % auto-crop images? inf means no cropping

plotCBar = 0;

saveSingleFDFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]
saveCombinedFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]

figDir = [p.figures_dti '/fg_densities'];

figPrefix = ['NCP_tlrc_' smoothstr];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

    
    % load fiber density files
    fd = cellfun(@(x,y) niftiRead(fullfile(sprintf(fdDir),sprintf([x '.nii.gz'],y))), fdFileStrs, targets);
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
    
    
    % determine c_range for each overlay
    if ~notDefined('q_crange')
        c_range=cellfun(@(x) quantile(x(x~=0),[q_crange]), fdImgs,'UniformOutput',0);
    end
    
           
    % if acpcSlices isn't defined, plot center of mass coords
    if notDefined('acpcSlices') || isempty('acpcSlices')
        coords = round(cell2mat(reshape(cellfun(@(x) getNiiVolStat(x,fd.qto_xyz,'com'), fdImgs, 'UniformOutput',0), [], 1)));
        acpcSlices = unique(coords(:,plane))';
    end
    
    
    nOls = numel(fdImgs); % useful variable to have
    
    
    %% plot overlay(s)
    
    s=1
for s=1:numel(subjects)
    
    subject=subjects{s};
    

    j=1;
    for j = 1:nOls
        
 
        % put L/R density maps into nifti structure for its header info
        fd.data = fdImgs{j}(:,:,:,s);
        
        
        % plot fiber density overlay
        doPlot=1;
        [imgRgbs, olMasks,olVals(j,:),h,acpcSlicesOut] = plotOverlayImage(fd,bg,cols{j},c_range{j},plane,acpcSlices,doPlot,ac,plotCBar);
       
        % save out single 
        if saveSingleFDFigs
            outDir = fullfile(figDir,sprintf(fdFileStrs{j},targets{j}));
            if ~exist(outDir,'dir')
                mkdir(outDir)
            end
            for k=1:numel(acpcSlicesOut)
                print(h(k),'-dpng','-r300',fullfile(outDir,[subject '_plane' num2str(plane) '_' num2str(acpcSlicesOut)]));
            end
        end
        
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
        
        
%         % cell array w/all combined overlays to plot
%         slImgs{k} = thisImg;
%         
%         
        % plot overlay and save new figure
        [h,figNames]= plotFDMaps(thisImg,plane,acpcSlicesOut(k),saveFigs,figDir,[figPrefix '_' subject]);
    
        
    end % acpcSlices
    
    
    clear olVals olRgb slImgs
    
    
end % subjects










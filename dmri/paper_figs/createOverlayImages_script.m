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
subjects={'controls'};
% subjects = {'bp160213','kn160918','cs171002'};
% subjidx=[16 32 40];
% filepath to mask, if desired
% maskFilePath = fullfile(dataDir,'ROIs','DA.nii');

% tracking method
method = 'mrtrix_fa';


% directory with fiber density files
fdDir = fullfile(dataDir,'fg_densities',method);

smoothStr='';
% smoothStr='_smooth3';

% endptStr = '_DAendpts'; % endpoints string
endptStr = ''; % endpoints string

gspace='mni'; % group space


% this should be a cell array that matches the dimensions of fdFileStrs 
% targets={'nacc';
%     'nacc';
%     'caudate';
%     'putamen'};


% filenames of fiber density files; %s is target
% NOTE: this should be in a cell array with L and R fd maps from the same
% ROIs in the same row, and different maps in different columns
% if strcmp(subjects{1},'controls')
%     fdFileStrs = {['DA_%s_belowAC_dil2' smoothStr '_autoclean' endptStr '_' gspace '_MEAN'];
%         ['DA_%s_aboveAC_dil2' smoothStr '_autoclean' endptStr '_' gspace '_MEAN']
%         ['DA_%s_dil2' smoothStr '_autoclean' endptStr '_' gspace '_MEAN'];
%         ['DA_%s_dil2' smoothStr '_autoclean' endptStr '_' gspace '_MEAN']};
% else
%     fdFileStrs = {['DA_%s_belowAC_dil2' smoothStr '_autoclean' endptStr '_' gspace '_ALL'];
%         ['DA_%s_aboveAC_dil2' smoothStr '_autoclean' endptStr '_' gspace '_ALL']
%         ['DA_%s_dil2' smoothStr '_autoclean' endptStr '_' gspace '_ALL'];
%         ['DA_%s_dil2' smoothStr '_autoclean' endptStr '_' gspace '_ALL']};
% end

targets={'nacc'};
fdFileStrs = {['DAL_%sL_belowAC_dil2' smoothStr '_autoclean' endptStr '_' gspace '_MEAN']};

if strcmp(gspace,'tlrc')
    bg = niftiRead(fullfile(dataDir,'templates','TT_N27.nii'));
elseif strcmp(gspace,'mni')
    bg = niftiRead(fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii'));
end


thresh=.05; % value to threshold maps; otherwise 0 to not threshold

scale = 0; % 1 to scale, otherwise 0

q_crange=[.1 .9]; % min/max quantiles of data values to determine color range

plane=2; % which plane to plot
% acpcSlices=[-20:2:10]; % which acpc slices to plot
acpcSlices=[-5]; % which acpc slices to plot

% plane=3; % which plane to plot
% acpcSlices=[-18:2:-12]; % which acpc slices to plot
% acpcSlices=[]; % which acpc slices to plot

% cols=getDTIFDColors(targets,fdFileStrs); % colors for fiber density maps
cols{1}=[
    0.0510    0.1843    0.3569
    0.1098    0.2078    0.5373
    0.2824    0.2039    0.6392
    0.3882    0.2549    0.5922
    0.4941    0.3020    0.5608
    0.6000    0.3294    0.5412
    0.6980    0.3647    0.5176
    0.8118    0.4039    0.4471
    0.9020    0.4510    0.3843
    0.9373    0.5255    0.3412
    0.9961    0.6196    0.2510
    0.9922    0.7333    0.2627
    0.9804    0.8510    0.2784];



ac=[]; % auto-crop images? inf means no cropping

plotCBar = 0;

doPlot=1; % plot out figures to screen? 
 
saveSingleFDFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]

plotCombinedOverlays = 1; % 1 to plot combined fiber density overlays, otherwise 0

saveCombinedFigs = 1; % 1 to save otherwise 0 (if plotCombineOverlays=0, these wont save)

figDir = [p.figures_dti '/fg_densities'];

saveStr = [smoothStr endptStr];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


% load fiber density files
fd = cellfun(@(x,y) niftiRead(fullfile(sprintf(fdDir),sprintf([x '.nii.gz'],y))), fdFileStrs, targets);
if ~notDefined('subjidx')
    for j=1:numel(fd)
        fd(j).data=fd(j).data(:,:,:,subjidx);
    end
    subjects=subjects(subjidx);
end
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


% determine c_range for each overlay
if ~notDefined('q_crange')
    c_range=cellfun(@(x) quantile(x(x~=0),[q_crange]), fdImgs,'UniformOutput',0);
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
        [imgRgbs, olMasks,olVals(j,:),h,acpcSlicesOut] = plotOverlayImage(fd,bg,cols{j},c_range{j},plane,acpcSlices,doPlot,ac,plotCBar);
        
        % save out single
        if saveSingleFDFigs
            outDir = fullfile(figDir,sprintf(fdFileStrs{j},targets{j}));
            if ~exist(outDir,'dir')
                mkdir(outDir)
            end
            switch plane
                    case 1
                        planeStr = 'X=';
                    case 2
                        planeStr = 'Y=';
                    case 3
                        planeStr = 'Z=';
            end
            for k=1:numel(acpcSlicesOut)
                print(h{k},'-dpng','-r300',fullfile(outDir,[subject '_' planeStr num2str(acpcSlicesOut(k)) '_' smoothStr '_' saveStr]));
            end
        end
        
        % cell array of just rgb values for overlays
        olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
        
        
    end % nOls
    
    
    %% now combine fiber density overlays for each slice
    
    if plotCombinedOverlays
        
        
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
            
            
            % plot overlay and save new figure
            outDir = fullfile(figDir,['combinedFDs_' gspace]);
            if ~exist(outDir,'dir')
                mkdir(outDir)
            end
            [h,figNames]= plotFDMaps(thisImg,plane,acpcSlicesOut(k),saveCombinedFigs,outDir,[subject '_' saveStr]);
            
            
        end % acpcSlices
        
    end % plotCombinedOverlays
    
    clear olVals olRgb slImgs
    
    
    
end % subjects










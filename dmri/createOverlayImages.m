%% overlay fiber densities onto subject's T1 in native space

% this script is designed to load fiber density images and plot them as
% color overlays on grayscaled anatomical background images. It's a little
% clunky because it does extra processing to combine rgb images from
% different overlays so that the RGB values are weighted according to the
% relative contributions of the fibe density values (e.g., if a voxel has a
% value of '1' for a fiber density map w/rgb value [1 0 0] and a .5 for
% another map w/rgb value [0 0 1], then the resulting rgb value at that
% voxel will be [.67 0 .33].

% targets in the same row of the cell array will be plotted together (e.g.,
% L and R overlays of the same target).

% this script should be called from a script called:

% createOverlayImages_[]_script, where [] is something like group, subj, or
% ROI.


%%

% assume overlay directory is fiber density directory if it isn't defined
if notDefined('olDir')
    olDir = ['fg_densities/' method];  % filepath for overlay file (relative to subj)
end


% unless otherwise specified, use FDColors for colormaps
if notDefined('cols')
    cols = getDTIColors('fd');
end


% if autocrop isn't defined, don't do it
if notDefined('ac')
    ac = inf;
end

% if plane isn't defined, do axial plane by default
if notDefined('plane')
    plane = 3;
end



% do hard segmentation based on strongest connectivity? Default is to not
% do this
if notDefined('plot_biggest')
    plot_biggest=0;
end
if plot_biggest==1
    cols = getDTIColors(1:3);
    figPrefix = 'win';
end


%%

% if desired, get just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx,:);
    cols=cols(t_idx,:);
end

nOls = size(targets,1); % useful variable to have


 

%% do it


s=1;
for s=1:numel(subjects)
    
    subj = subjects{s};
    
    
    % load background image
    bg = readFileNifti(sprintf(bgFilePath,subj));
    
    
    % load fiber density files
    fd = cellfun(@(x) readFileNifti(fullfile(subj, olDir,[x fStr '.nii.gz'])), targets);
    fdImgs ={fd(:).data}; fdImgs=reshape(fdImgs,size(targets));
    fd = fd(1);  fdXform = fd.qto_xyz;
    
  
   % if thresholding is desired, do it
    if ~notDefined('thresh') && thresh~=0
        fdImgs = cellfun(@(x) threshImg(x, thresh), fdImgs, 'UniformOutput',0);
    end
  
    
    % if scaling is desired, do it
    if ~notDefined('scale') && scale==1
        fdImgs = cellfun(@scaleFiberCounts, fdImgs, 'UniformOutput',0);
    end
  
    
    % if masking overlays is desired, do it
    if ~notDefined('maskFilePath')  && ~isempty(maskFilePath)
        mask = readFileNifti(sprintf(maskFilePath,subj));
        fdImgs = cellfun(@(x) double(x) .* double(mask.data), fdImgs, 'UniformOutput',0);
    end
   
    
      % if acpcSlices isn't defined, plot center of mass coords
    if notDefined('acpcSlices') || isempty('acpcSlices')
        coords = round(cell2mat(reshape(cellfun(@(x) getNiiVolStat(x,fd.qto_xyz,'com'), fdImgs, 'UniformOutput',0), [], 1)));
        acpcSlices = unique(coords(:,plane))';
    end
       
   
    % merge overlays in the same rows (e.g., L and R)
    if size(targets,2)>1
        fdImgs = cellfun(@(x,y) x+y, fdImgs(:,1), fdImgs(:,2), 'UniformOutput',0);
    end
    
    
    % do hard segmentation of voxels based on strongest connectivity?
    if plot_biggest==1
        
        allImgs = cat(4,fdImgs{:});
        
        % get the 'win_idx' - idx of which fd group is biggest for each voxel
        [~,win_idx]=max(allImgs,[],4);
        win_idx(sum(allImgs,4)==0)=0;
        
        % create a new nifti w/win_idx as img data
        fd.data=win_idx;
        
        % plot overlay of voxels w/biggest connectivity
        [slImgs,~,~,~,acpcSlicesOut] = plotOverlayImage(fd,bg,cols,[1 numel(fdImgs)],plane,acpcSlices,0,ac);
        
        
    else
        
        
        j=1;
        for j = 1:nOls
            
            
            % put L/R density maps into nifti structure for its header info
            fd.data = fdImgs{j};
            
            
            % plot fiber density overlay
            [imgRgbs, olMasks,olVals(j,:),~,acpcSlicesOut] = plotOverlayImage(fd,bg,cols{j},c_range,plane,acpcSlices,0,ac);
            
            
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
        
        
    end % plot_biggest
    
    
    
    %% now plot and (if desired) save images
    
    % put acpcSlices into cell array for cellfun
    acpcSlicesOut = num2cell(acpcSlicesOut);
    
    
    % plot overlay and save new figure
    [h,figNames]= cellfun(@(x,y) plotFDMaps(x,plane,y,saveFigs,figDir,figPrefix,subj), slImgs, acpcSlicesOut, 'UniformOutput',0);
    
%     close all
    
    
end % subjects









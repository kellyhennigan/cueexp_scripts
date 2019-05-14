
clear all
close all

% get experiment-specific paths & cd to main data dir
p = getCuePaths;
dataDir=p.data;
cd(dataDir);


% cell array of subject ids to process
subjects = {'jh160702','ph161104'};

bgFilePath = fullfile(dataDir,'%s','t1','t1_fs.nii.gz');

roiFilePath = fullfile(dataDir,'%s','ROIs','%s.nii.gz'); % directory with tlrc space ROIs

roiNames = {'nacc','caudate','putamen'};

figPrefix = 'NCP';

outDir = fullfile(p.figures_dti,'ROIs');


plane=2; % which plane to plot

sl=[9]; % which acpc slices to plot (leave empty to find the slice with the most roi coords)


cols=getDTIColors(roiNames);
ac=[]; % auto-crop images? inf means no cropping


saveFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end

i=1
for i=1:numel(subjects)
    
    subject=subjects{i};
    
     % load background image
    bg = niftiRead(sprintf(bgFilePath,subject));
   
    
% load fiber density files
roi = cellfun(@(x) niftiRead(fullfile(sprintf(roiFilePath,subject,x))), roiNames);
roiImgs ={roi(:).data}; 
roi = roi(1);  roiXform = roi.qto_xyz;


nOls = numel(roiImgs); % useful variable to have


% assign roi voxels values based on roi mask (eg, nacc voxels are 1, caudate voxels are 2, etc)
allImgs = cat(4,roiImgs{:});
[~,win_idx]=max(allImgs,[],4);
win_idx(sum(allImgs,4)==0)=0;

% create a new nifti w/win_idx as img data
roi.data=win_idx;

  
        % determine x,y,z slices with the most roi coords
        if notDefined('sl') || isempty('sl')
            [ii,jj,kk]=ind2sub(size(roi.data),find(roi.data));
            acpcCoords = mode(round(mrAnatXformCoords(roi.qto_xyz,[ii jj kk]))); % x,y and/or z slices to plot
            sl=acpcCoords(plane);
        end
        
        
% plot ROIs
doPlot=1;
[slImgs,~,~,h] = plotOverlayImage(roi,bg,cols,[1 nOls],plane,sl,doPlot,ac);

% save it
outName = [figPrefix '_' subject '_%s' num2str(sl)];
switch plane
    case 1      % sagittal
        outName=sprintf(outName,'X');
    case 2      % coronal
        outName=sprintf(outName,'Y');
    case 3      % axial
        outName=sprintf(outName,'Z');
end

print(h{1},'-dpng','-r300',fullfile(outDir,outName))
%         saveas(h{1},fullfile(this_outDir,[outName '.png']));


end  % subjects 
%% quick and dirty script to plot and save out *single subject* ROI masks 
% in x,y, and z planes with a subject loop


clear all
close all

[p,task,subjects,gi]=whichCueSubjects('stim','dti');
subjects={'jh160702'};
dataDir = p.data;

roiFilePath = fullfile(dataDir,'%s','%s.nii'); % directory with tlrc space ROIs
roiNames = {'DA','nacc','caudate','putamen'};


figDir = p.figures;

t1Path = fullfile(dataDir,'%s','t1.nii.gz'); %s is subject ID

outDir = fullfile(figDir,'ROIs_subject','%s'); %s is roiName
    
saveViews = {'x','y','z'}; % x y z for sagittal, coronal, and axial views

col = [1 0 0]; % color for ROI mask


%% do it


for j=1:numel(roiNames)
    
    this_inRoiFile = sprintf(inRoiFile,roiNames{j});
    
    for i=1:numel(subjects)
        
        subject = subjects{i};
        
        fprintf(['\n\nworking on subject ' subject '...\n\n']);

if ~exist(outDir,'dir')
    mkdir(outDir)
end

roi = niftiRead(roiPath);
t1 = niftiRead(t1Path);


% determine x,y,z slices with the most roi coords
[i j k]=ind2sub(size(roi.data),find(roi.data));
sl = mode(round(mrAnatXformCoords(roi.qto_xyz,[i j k]))); % x,y and z slices to plot



for i=1:3
    [imgRgbs,~,~,h,acpcSlices{i}] = plotOverlayImage(roi,t1,col,[0 1],i,sl(i));
    outPath = fullfile(outDir,[roiName '_' saveViews{i} num2str(sl(i))]);
    print(h,'-dpng','-r300',outPath)
    saveas(h{1},[outPath '.png'])
%     imwrite(,'myMultipageFile.tif')
end


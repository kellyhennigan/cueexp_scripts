%% quick and dirty script to plot and save out *single subject* ROI masks
% in x,y, and z planes with a subject loop


clear all
close all

p=getCuePaths;
dataDir = p.data;
subjects={'jh160702'};

roiFilePath = fullfile(dataDir,'%s','ROIs','%s.nii.gz'); % directory with tlrc space ROIs
roiNames = {'DA'};

outDir = fullfile(p.figures_dti,'ROIs');

t1Path = fullfile(dataDir,'%s','t1.nii.gz'); %s is subject ID


plane=2; % 1 for sagittal, 2 for coronal, 3 for axial view

cols=getDTIColors(roiNames);


%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end

i=1
for i=1:numel(subjects)
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    t1 = niftiRead(sprintf(t1Path,subject));
    
    j=1
    for j=1:numel(roiNames)
        
        roi = niftiRead(sprintf(roiFilePath,subject,roiNames{j}));
        
        
        % determine x,y,z slices with the most roi coords
        [ii jj kk]=ind2sub(size(roi.data),find(roi.data));
        sl = mode(round(mrAnatXformCoords(roi.qto_xyz,[ii jj kk]))); % x,y and/or z slices to plot
        
        
        % plot ROI overlaid on subject's T1
        [imgRgbs,~,~,h] = plotOverlayImage(roi,t1,cols(j,:),[0 1],plane,sl(plane),[],[],[],0);
        
        % save it
        switch plane
            case 1      % sagittal
                outName=[roiNames{j} '_' subject '_X' num2str(sl(plane))];
            case 2      % coronal
                outName=[roiNames{j} '_' subject '_Y' num2str(sl(plane))];
            case 3      % axial
                outName=[roiNames{j} '_' subject '_Z' num2str(sl(plane))];
        end
        
        print(h{1},'-dpng','-r300',fullfile(outDir,outName))
        %         saveas(h{1},fullfile(this_outDir,[outName '.png']));
        
        
    end % roiNames
    
    fprintf(['done.\n']);
    
end % subjects


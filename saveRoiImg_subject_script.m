%% quick and dirty script to plot and save out *single subject* ROI masks
% on t1 underlay


clear all
close all

% [p,task,subjects,gi]=whichCueSubjects('stim','dti');
p=getCuePaths;
subjects={'tm160117'};
% subjects = getCueSubjects('dti');
dataDir = p.data;

roiFilePath = fullfile(dataDir,'%s','ROIs','%s.nii.gz'); % filepath to ROI file(s); %s is roi name

% list of ROIs to plot (script will loop over these)
roiNames = {'nacc','caudate','putamen'};
% roiNames = {'asgins','amygdala','nacc'};
% roiNames = {'mpfc8mmL'};

figDir = p.figures_dti;

t1Path = fullfile(dataDir,'%s','t1.nii.gz'); %s is subject ID

outDir = fullfile(figDir,'ROIs_subject','%s'); %s is roiName

plane=1; % 1 for sagittal, 2 for coronal, 3 for axial view

% col = [1 1 0]; % color for ROI mask
col=[238,178,35]./255;

%% do it
i=1
for i=1:numel(subjects)
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    t1 = niftiRead(sprintf(t1Path,subject));
    
    j=1
    for j=1:numel(roiNames)
        
        this_outDir=sprintf(outDir,roiNames{j});
        if ~exist(this_outDir,'dir')
            mkdir(this_outDir)
        end
        
        roi = niftiRead(sprintf(roiFilePath,subject,roiNames{j}));
        
        
        % determine x,y,z slices with the most roi coords
        [i j k]=ind2sub(size(roi.data),find(roi.data));
        sl = mode(round(mrAnatXformCoords(roi.qto_xyz,[i j k]))); % x,y and/or z slices to plot
        
        
        % plot ROI overlaid on subject's T1
        [imgRgbs,~,~,h] = plotOverlayImage(roi,t1,col,[0 1],plane,sl(plane),[],[],[],0);
        
        % save it
        switch plane
            case 1      % sagittal
                outName=[subject '_X' num2str(sl(plane))];
            case 2      % coronal
                outName=[subject '_Y' num2str(sl(plane))];
            case 3      % axial
                outName=[subject '_Z' num2str(sl(plane))];
        end
        
        %     print(h{1},'-dpng','-r300',outPath)
        saveas(h{1},fullfile(this_outDir,[outName '.png']));
        
        
    end % roiNames
    
    fprintf(['done.\n']);
    
end % subjects


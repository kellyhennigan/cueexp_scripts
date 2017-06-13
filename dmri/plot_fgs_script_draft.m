
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
subjects=getCueSubjects('dti');
dataDir = p.data;
figDir = fullfile(p.figures,'fgs_single_subs');

% paths and directories are relative to subject specific dir
t1Path = fullfile(dataDir,'%s','t1.nii.gz'); % %s is subject id
dtPath = fullfile(dataDir,'%s','dti96trilin','dt6.mat'); % %s is subject id

LorR = 'R';

roiDir = fullfile(dataDir,'%s','ROIs');

rois1 = {'DA','DA','DA'};

rois2 = {'caudate','nacc','putamen'};

method = 'conTrack';

fgDir = fullfile(dataDir,'%s','fibers',method);

fgNameStr = '%s%s_%s%s_autoclean.pdb'; %s: roi1,LorR,roi2,LorR
fgNameStr2 = '%s%s_%s%s_autoclean_cl1.pdb'; %s: roi1,LorR,roi2,LorR

cols = [   0.9333    0.6980    0.1373
    0.9804    0.0941    0.1137
    0.1294    0.4431    0.7098];

nNodes = 20;

%% 

i=1
for i = 7:numel(subjects)

    close all
    
subject = subjects{i};

fprintf('\n\nworking on subject %s...\n',subject);

%load t1
t1        = niftiRead(sprintf(t1Path,subject));
 dt = dtiLoadDt6(sprintf(dtPath,subject));
 
 
 for j=1:numel(rois1)
     
    
     roi1=roiNiftiToMat([sprintf(roiDir,subject) '/' rois1{j} LorR '.nii.gz']);
     roi2=roiNiftiToMat([sprintf(roiDir,subject) '/' rois2{j} LorR '.nii.gz']);
     
     this_fg = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStr,rois1{j},LorR,rois2{j},LorR)]);
     if j==2
         this_fg = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStr2,rois1{j},LorR,rois2{j},LorR)]);
     end
     
     [~,~,~,~,~, SuperFiber, fgClipped, ~,~, fgRes{j}] = ...
         dtiComputeDiffusionPropertiesAlongFG(this_fg, dt, roi1, roi2, nNodes);
 end
 
 % Rescale image values to get better gary/white/CSF contrast
 img = mrAnatHistogramClip(double(t1.data),0.3,0.99);
%  t1.data=img;
    
    
 %%   PLOTS
 
 % get some useful plot params
 scsz=get(0,'Screensize');
 plotTubes = 1;  % plot fiber pathways as tubes or lines? 
 fg_rad = .5;   % radius of fiber pathway tubes (only matters if plotTubes=1)
 
 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%% SAGITTAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% camlight is right by default; though I'm not sure what looks better...

 if strcmpi(LorR,'R')
        vw = [90,0];
 else
     vw = [270,0];
 end
 
 
  sh=AFQ_RenderFibers(fgRes{1},'color',cols(1,:),'numfibers',100,'tubes',plotTubes,'radius',fg_rad)
 delete(sh.l); % delete light object 
 fig = gcf;
 for j=2:numel(rois1)
     sh=AFQ_RenderFibers(fgRes{j},'color',cols(j,:),'numfibers',100,'tubes',plotTubes,'radius',.3,'newfig',0);
 end
 AFQ_AddImageTo3dPlot(t1,[-1, 0, 0],'gray');
  view(vw);
  llh = lightangle(vw(1),vw(2));


 % change axis on x and zlims
zlim(gca,[-50,50])
ylim(gca,[-50,50])

pos=get(fig,'position');
set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
 %    set(gca,'Position',[0,0,1,1]);

 print(gcf,'-dpng','-r300',fullfile(figDir,[LorR '_CNP_' subject '_sagittal']));



 
%% %%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 vw = [0,0]; % coronal view 
 
cam_str = 'coronal';
 
 
 sh=AFQ_RenderFibers(fgRes{1},'color',cols(1,:),'numfibers',100,'tubes',plotTubes,'radius',fg_rad);
  delete(sh.l); % delete light object 
 fig = gcf;
  for j=2:numel(rois1)
     sh=AFQ_RenderFibers(fgRes{j},'color',cols(j,:),'numfibers',100,'tubes',plotTubes,'radius',.3,'newfig',0);
 end
 AFQ_AddImageTo3dPlot(t1,[0, 1, 0],'gray');
  view(vw);
  llh = lightangle(vw(1),vw(2));

% change axis on x and zlims
xlim(gca,[-40,40])
zlim(gca,[-40,40])

pos=get(fig,'position');
set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
%     set(gca,'Position',[0,0,1,1]);

 print(gcf,'-dpng','-r300',fullfile(figDir,[LorR '_CNP_' subject '_coronal']));

% 
% 
%      camlight(sh.l,'left');
%   print(gcf,'-dpdf','-r600','naccR_corr_light')

end % subjects
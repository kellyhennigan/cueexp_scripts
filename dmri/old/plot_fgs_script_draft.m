
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
subjects=getCueSubjects('dti');
subjects={'tm160117'};
dataDir = p.data; cd(dataDir)
figDir = fullfile(p.figures,'fgs_single_subs');

% paths and directories are relative to subject specific dir
t1Path = fullfile(dataDir,'%s','t1','t1_fs.nii.gz'); % %s is subject id
% dtPath = fullfile(dataDir,'%s','dti96trilin','dt6.mat'); % %s is subject id

LorR = 'R';

roiDir = fullfile(dataDir,'%s','ROIs');

seed = 'DA';

targets = {'nacc','nacc','caudate','putamen'};

method = 'mrtrix_fa';

fgDir = fullfile(dataDir,'%s','fibers',method);

fgNameStrs = {'%s%s_%s%s_belowAC_dil2_autoclean.pdb',...
    '%s%s_%s%s_aboveAC_autoclean.pdb',...
    '%s%s_%s%s_dil2_autoclean.pdb',...
    '%s%s_%s%s_dil2_autoclean.pdb'};
    
    
 
 % get some useful plot params
 scsz=get(0,'Screensize');
 plotTubes = 0;  % plot fiber pathways as tubes or lines? 
 fg_rad = .1;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=400;
 
cols = getDTIColors(targets);
cols{2}= [244 101 7]./255; 

%% 

i=1
% for i = 7:numel(subjects)

    close all
    
subject = subjects{i};

fprintf('\n\nworking on subject %s...\n',subject);

%load t1
t1        = niftiRead(sprintf(t1Path,subject));
 % Rescale image values to get better gary/white/CSF contrast
 img = mrAnatHistogramClip(double(t1.data),0.3,0.99);
 t1.data=img;

%  dt = dtiLoadDt6(sprintf(dtPath,subject));
 
%   roi1=roiNiftiToMat([sprintf(roiDir,subject) '/' seed LorR '.nii.gz']);
  
 for j=1:numel(targets)
    
%      roi2=roiNiftiToMat([sprintf(roiDir,subject) '/' targets{j} LorR '.nii.gz']);
     
     fg{j} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStrs{j},seed,LorR,targets{j},LorR)]);
     
%     [fa, md, rd, ad, cl, SuperFiber,fgClipped,~,~,fgRes{j},eigVals]=...
%         dtiComputeDiffusionPropertiesAlongFG_with_eigs(fg{j},dt,[],[],nNodes,[]);
%     
  end
 
    
    
 %%   PLOTS
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAGITTAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% camlight is right by default; though I'm not sure what looks better...

 if strcmpi(LorR,'R')
        vw = [90,0];
 else
     vw = [270,0];
 end
 
 
 sh=AFQ_RenderFibers(fg{1},'color',cols{1},'numfibers',400,'tubes',plotTubes,'radius',fg_rad)
 delete(sh); % delete light object 
 fig = gcf;
 for j=2:numel(targets)
     sh=AFQ_RenderFibers(fg{j},'color',cols{j},'numfibers',100,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
 end
 AFQ_AddImageTo3dPlot(t1,[-1, 0, 0],'gray');
  view(vw);
%   llh = lightangle(vw(1),vw(2));


 % change axis on x and zlims
zlim(gca,[-50,50])
ylim(gca,[-50,50])

pos=get(fig,'position');
set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
 %    set(gca,'Position',[0,0,1,1]);

%  print(gcf,'-dpng','-r300',fullfile(figDir,[LorR '_CNP_' subject '_WB_sagittal']));
 print(gcf,'-dpng','-r300',fullfile(figDir,[LorR '_CNP_' subject '_sagittal']));



 
%% %%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 vw = [0,0]; % coronal view 
 
cam_str = 'coronal';
 
 
 sh=AFQ_RenderFibers(fgRes{1},'color',cols{1},'numfibers',100,'tubes',plotTubes,'radius',fg_rad);
%   delete(sh); % delete light object 
 fig = gcf;
  for j=2:numel(targets)
     sh=AFQ_RenderFibers(fgRes{j},'color',cols{j},'numfibers',100,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
 end
 AFQ_AddImageTo3dPlot(t1,[0, 1, 0],'gray');
  view(vw);
%   llh = lightangle(vw(1),vw(2));

% change axis on x and zlims
xlim(gca,[-40,40])
zlim(gca,[-40,40])

pos=get(fig,'position');
set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
%     set(gca,'Position',[0,0,1,1]);

 print(gcf,'-dpng','-r300',fullfile(figDir,[LorR '_CNP_' subject '_coronal']));

fprintf('done.\n\n');
% 
%      camlight(sh.l,'left');
%   print(gcf,'-dpdf','-r600','naccR_corr_light')

% end % subjects
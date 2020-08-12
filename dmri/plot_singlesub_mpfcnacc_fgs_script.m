
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
dataDir = p.data; 

% subjects={'al151016','hw161104','jh160702','jw160316','ph161104','pk160319','rp160205'};
subjects=getCueSubjects('dti',0);
% subjects={'ph161104'}; 

% paths and directories are relative to subject specific dir
t1Path = fullfile(dataDir,'%s','t1','t1_fs.nii.gz'); % %s is subject id

seed = 'mpfc8mm'; 

target = 'nacc'; 

fgNameStr = [seed '%s_' target '%s_autoclean23.pdb']; %s is L or R

method = 'mrtrix_fa';

fgDir = fullfile(dataDir,'%s','fibers',method);

outDir = fullfile(p.figures_dti,'fgs_single_subs','mpfc8mm_nacc_autoclean23');


% get some useful plot params
scsz=get(0,'Screensize');
plotTubes = 1;  % plot fiber pathways as tubes or lines?
fg_rad = .2;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=100;

cols={[1 0 0]};

plotToScreen=1; % 1 to plot to screen, otherwise 0


%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end

cd(dataDir);

i=1;
for i = 1:numel(subjects)
    
    close all
    
    subject = subjects{i};
    
    fprintf('\n\nworking on subject %s...\n',subject);
    
    %load t1
    t1 = niftiRead(sprintf(t1Path,subject));
    % Rescale image values to get better gary/white/CSF contrast
    img = mrAnatHistogramClip(double(t1.data),0.3,0.99);
    t1.data=img;
    
    
    % load L and R pathways
    fg{1,1} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStr,'L','L')]);
    fg{1,2} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStr,'R','R')]);
    
    
    %%   PLOTS
    
    
    sh=AFQ_RenderFibers(fg{1,1},'color',cols{1},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
    delete(sh); % delete light object (for some reason this needs to be deleted from the first FG plotted to look good...
    sh=AFQ_RenderFibers(fg{1,2},'color',cols{1},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
   
    fig = gcf;
    pos=get(fig,'position');
    set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
    %   llh = lightangle(vw(1),vw(2));
    
    % this command makes the image fill the entire figure window:
    %    set(gca,'Position',[0,0,1,1]);
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% SAGITTAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%% left
    
    % view for left fibers
    vwL = [270,0];
    
    h=AFQ_AddImageTo3dPlot(t1,[1, 0, 0],'gray');
    
    % get whole brain axes limits
    zl=zlim;
    yl=ylim;
    
    view(vwL);
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_sagittalL']));
    
%     % change axis on y and zlims to close-up
%     zlim(gca,[-50,50])
%     ylim(gca,[-50,50])
%     
%     print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_sagittalL']));
%     
    delete(h) % delete that slice
    
    %%%%%%%% right
    vwR = [90,0];
    
    h= AFQ_AddImageTo3dPlot(t1,[-1, 0, 0],'gray');
    
    %%% save out right side
    view(vwR)
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_sagittalR']));
    
%     % change axis on y and zlims to close-up
%     zlim(gca,[-50,50])
%     ylim(gca,[-50,50])
%     print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_sagittalR']));
%     
    delete(h) % delete that slice
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vwC = [0,0]; % coronal view
    
    h=AFQ_AddImageTo3dPlot(t1,[0, 18, 0],'gray');
    view(vwC);
    %   llh = lightangle(vwC(1),vwC(2));
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_coronal']));
    
%     % change axis on x and zlims
%     xlim(gca,[-40,40])
%     zlim(gca,[-40,40])
%     
%     print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_coronal']));
%     

   delete(h) % delete that slice
 
    
    %
    %      camlight(sh.l,'left');
    %   print(gcf,'-dpdf','-r600','naccR_corr_light')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AXIAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    vwA = [0,90]; % axial view
    
    h=AFQ_AddImageTo3dPlot(t1,[0, 0, -1],'gray');
    view(vwA);
    %   llh = lightangle(vwC(1),vwC(2));
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_axial']));
    

    fprintf('done.\n\n');
    
    
    %
    %      camlight(sh.l,'left');
    %   print(gcf,'-dpdf','-r600','naccR_corr_light')
   
    
end % subjects
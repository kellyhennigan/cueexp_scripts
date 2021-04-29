
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
dataDir = p.data; 

% subjects={'al151016','hw161104','jh160702','jw160316','ph161104','pk160319','rp160205'};
subjects=getCueSubjects('dti',1);
% subjects={'jh160702'}; 

% paths and directories are relative to subject specific dir
t1Path = fullfile(dataDir,'%s','t1','t1_ns.nii.gz'); % %s is subject id


fgNames = {'mpfc8mmL_naccL_autoclean23.pdb';
    'mpfc8mmR_naccR_autoclean23.pdb';
    'asginsL_naccL_autoclean.pdb';
    'asginsR_naccR_autoclean.pdb';
    'amygdalaL_naccL_autoclean.pdb';
    'amygdalaR_naccR_autoclean.pdb'};

method = 'mrtrix_fa';

fgDir = fullfile(dataDir,'%s','fibers',method);

outDir = fullfile(p.figures_dti,'fgs_single_subs','connacctome');


% get some useful plot params
scsz=get(0,'Screensize');
plotTubes = 1;  % plot fiber pathways as tubes or lines?
fg_rad = .2;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=100;

cols={[0.0588    0.8196    0.8588];
    [0.0588    0.8196    0.8588];
    [0.8863    0.0941    0.0078];
     [0.8863    0.0941    0.0078];
     [0 0 0.5451];
     [0 0 0.5451];};
     

plotToScreen=0; % 1 to plot to screen, otherwise 0


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
    
    
    % load pathways
    for j=1:numel(fgNames)
        fg{j} = fgRead([sprintf(fgDir,subject) '/' fgNames{j}]);
    end
    
    
    
    %%   PLOTS
    
    
    sh=AFQ_RenderFibers(fg{1},'color',cols{1},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
    delete(sh); % delete light object (for some reason this needs to be deleted from the first FG plotted to look good...
    
    for j=2:numel(fg)
        sh=AFQ_RenderFibers(fg{j},'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
    end
    
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
    
    h=AFQ_AddImageTo3dPlot(t1,[2, 0, 0],'gray');
    
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
    
    h= AFQ_AddImageTo3dPlot(t1,[-2, 0, 0],'gray');
    
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
    
%     vwC = [0,0]; % coronal view
%     
%     h=AFQ_AddImageTo3dPlot(t1,[0, 18, 0],'gray');
%     view(vwC);
%     %   llh = lightangle(vwC(1),vwC(2));
%     
%     set(gca,'fontName','Helvetica','fontSize',12)
%     
%     print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_coronal']));
%     
% %     % change axis on x and zlims
% %     xlim(gca,[-40,40])
% %     zlim(gca,[-40,40])
% %     
% %     print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_coronal']));
% %     
% 
%    delete(h) % delete that slice
%  
    
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
    
    
    %
    %      camlight(sh.l,'left');
    %   print(gcf,'-dpdf','-r600','naccR_corr_light')
   
    
%% all slices, "connacctome" angle
%          
%     hx= AFQ_AddImageTo3dPlot(t1,[-2, 0, 0],'gray'); % sag
%     hy= AFQ_AddImageTo3dPlot(t1,[0, -18, 0],'gray'); % coronal
%     hz= AFQ_AddImageTo3dPlot(t1,[0, 0, -6],'gray'); % axial 
%     
%     %%% get a nice 3d view
%     v=[ -0.8536    0.5210    0.0000    0.1663
%    -0.2136   -0.3499    0.9121   -0.1743
%    -0.4752   -0.7785   -0.4099    9.4921
%          0         0         0    1.0000]; 
%      view(v);
%       
%     print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_3dview']));
    
%     
%     delete(h) % delete that slice
   
   fprintf('done.\n\n');
 
    
end % subjects

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
dataDir = p.data;

% subjects={'al151016','hw161104','jh160702','jw160316','ph161104','pk160319','rp160205'};
% subjects=getCueSubjects('dti',1);
% subjects={'mr170621','lh180622','kk180117','cm180506','zm160627','se161021','rv160413'};
subjects={'mr170621'};

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
fg_rad = .3;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=300;

cols={[0.0588    0.8196    0.8588];
    [0.0588    0.8196    0.8588];
    [0.8863    0.0941    0.0078];
    [0.8863    0.0941    0.0078];
    [0 0 0.5451];
    [0 0 0.5451];};


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
    
    
    
    % load pathways
    for j=1:numel(fgNames)
        fg{j} = fgRead([sprintf(fgDir,subject) '/' fgNames{j}]);
    end
    
    
    
    %% plots
    
    %%%%%%%% set up the figure window
    scsz=get(0,'Screensize');
    figh=figure; hold on
    pos=get(figh,'position');
    set(figh,'Position',[scsz(3)-610 scsz(4)-610 600 600])
    cameratoolbar('Show');
    cameratoolbar('SetMode','orbit');
    fprintf('\nmesh can be rotated with arrow keys\n')
    axis equal
    set(gca,'fontName','Helvetica','fontSize',12)
    
    % this command makes the image fill the entire figure window:
    %    set(gca,'Position',[0,0,1,1]);
    
    %%%%%%%%%% render fiber groups
    for j=1:numel(fg)
        sh=AFQ_RenderFibers(fg{j},'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% SAGITTAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
     h=AFQ_AddImageTo3dPlot(t1,[2, 0, 0],'gray',[],[],[0 .9]);
     h = AFQ_AddImageTo3dPlot(nifti, slice, cmap, rescale, alpha, imgClipRange
    %     %%%%%%%%%%% sagittal t1 slice
    %
    h=AFQ_AddImageTo3dPlot(t1,[2, 0, 0],'gray');
    
    % get whole brain axes limits (for ref, in case you want to zoom in and
    % then zoom back out)
    xl=xlim; yl=ylim; zl=zlim;
    
    % view for left fibers
    view(270,0)
    
    % set up light object
    lh = camlight('right'); lighting gouraud
    
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_sagittalL']));
    
    % change axis on y and zlims to close-up
    zlim(gca,[-50,50])
    ylim(gca,[-30,70])
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject  '_sagittalL']));
    
    % delete slice and light object
    delete(h); delete(lh);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % coronal t1 slice
    h=AFQ_AddImageTo3dPlot(t1,[0, -5, 0],'gray');
    
    
    % coronal view
    view(180,0)
    
    % set up light object
    lh = camlight('right');   lighting gouraud
    
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_coronal']));
    
    % change axis on y and zlims to close-up
    xlim(gca,[-40,40])
    zlim(gca,[-30,30])
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject  '_coronal']));
    
    % delete slice and light object
    delete(h); delete(lh);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% AXIAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % axial t1 slice
    h=AFQ_AddImageTo3dPlot(t1,[0, 0, -6],'gray');
    
    
    % axial view
    view(0,90)
    
    % set up light object
    lh = camlight('right');   lighting gouraud
    
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_wb_axial']));
    
    % change axis on y and zlims to close-up
    xlim(gca,[-50,50])
    ylim(gca,[-30,70])
    
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject  '_axial']));
    
    % delete slice and light object
    delete(h); delete(lh);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3d %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % coronal & axial t1 slices
    h=AFQ_AddImageTo3dPlot(t1,[0, -6, 0],'gray');
    h2=AFQ_AddImageTo3dPlot(t1,[0, 0, -8],'gray');
    h3=AFQ_AddImageTo3dPlot(t1,[2, 0, 0],'gray');
    
    set(gca,'Position',[0,0,1,1])
    
    % 3d view
    view(135,45)
    
    % set up light object
    lh = camlight('right');   lighting gouraud
    
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject '_3d_w_midsag']));
    
    
    %     % delete slice and light object
    %     delete(h); delete(lh);
    
    
    
    fprintf('done.\n\n');
    
    
end % subjects


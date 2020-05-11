
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
dataDir = p.data; 
outDir = fullfile(p.figures_dti,'fgs_single_subs');

% subjects={'al151016','hw161104','jh160702','jw160316','ph161104','pk160319','rp160205'};
subjects={'ph161104'};


% paths and directories are relative to subject specific dir
t1Path = fullfile(dataDir,'%s','t1','t1_fs.nii.gz'); % %s is subject id


method = 'mrtrix_fa';

fgDir = fullfile(dataDir,'%s','fibers',method);

seed = 'DA';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% params for plotting all 4 fiber groups %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
targets={
    'caudate';
    'putamen';
    'nacc';
    'nacc'};

fgStrs = {
    '';
    '';
    '_belowAC';
    '_aboveAC'};

fgNameStrs = { '%s%s_%s%s%s_autoclean.pdb',...
    '%s%s_%s%s%s_autoclean.pdb',...
    '%s%s_%s%s%s_autoclean.pdb',...
    '%s%s_%s%s%s_autoclean.pdb'};
   
outStr = '_4';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% params for plotting just 2 MFB fiber groups %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

targets={
    'nacc';
    'nacc'};

fgStrs = {
    '_belowAC';
    '_aboveAC'};

fgNameStrs = { 
    '%s%s_%s%s%s_dil2_autoclean.pdb',...
    '%s%s_%s%s%s_dil2_autoclean.pdb'};
   
outStr = '_2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% get some useful plot params
scsz=get(0,'Screensize');
plotTubes = 1;  % plot fiber pathways as tubes or lines?
fg_rad = .2;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=100;


cols=cellfun(@(x,y) getDTIColors(x,y), targets, fgStrs,'uniformoutput',0);


plotToScreen=0; % 1 to plot to screen, otherwise 0

%%

if ~exist(outDir,'dir')
    mkdir(outDir)
end

cd(dataDir);

i=1;
for i = 1:numel(subjects)
    % for i = 1:5
    
    close all
    
    subject = subjects{i};
    
    fprintf('\n\nworking on subject %s...\n',subject);
    
    %load t1
    t1 = niftiRead(sprintf(t1Path,subject));
    % Rescale image values to get better gary/white/CSF contrast
    img = mrAnatHistogramClip(double(t1.data),0.3,0.99);
    t1.data=img;
    
    
    for j=1:numel(targets)
        
        % load L and R pathways
        fg{j,1} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStrs{j},seed,'L',targets{j},'L',fgStrs{j})]);
        fg{j,2} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStrs{j},seed,'R',targets{j},'R',fgStrs{j})]);
    end
    
    
    
    %%   PLOTS
    
    
    sh=AFQ_RenderFibers(fg{1,1},'color',cols{1},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
    delete(sh); % delete light object (for some reason this needs to be deleted from the first FG plotted to look good...
    fig = gcf;
    pos=get(fig,'position');
    set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
    %   llh = lightangle(vw(1),vw(2));
    
    % this command makes the image fill the entire figure window:
    %    set(gca,'Position',[0,0,1,1]);
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    for j=1:numel(targets)
        sh=AFQ_RenderFibers(fg{j,1},'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
        sh=AFQ_RenderFibers(fg{j,2},'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
    end
    
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
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_wb_sagittalL']));
    
    % change axis on y and zlims to close-up
    zlim(gca,[-50,50])
    ylim(gca,[-50,50])
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_sagittalL']));
    
    delete(h) % delete that slice
    
    %%%%%%%% right
    vwR = [90,0];
    
    h= AFQ_AddImageTo3dPlot(t1,[-1, 0, 0],'gray');
    
    %%% save out right side
    view(vwR)
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_wb_sagittalR']));
    
    % change axis on y and zlims to close-up
    zlim(gca,[-50,50])
    ylim(gca,[-50,50])
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_sagittalR']));
    
    delete(h) % delete that slice
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    vwC = [0,0]; % coronal view
    
    h=AFQ_AddImageTo3dPlot(t1,[0, 1, 0],'gray');
    view(vwC);
    %   llh = lightangle(vwC(1),vwC(2));
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_wb_coronal']));
    
    % change axis on x and zlims
    xlim(gca,[-40,40])
    zlim(gca,[-40,40])
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_coronal']));
    
    fprintf('done.\n\n');
    
    
    %
    %      camlight(sh.l,'left');
    %   print(gcf,'-dpdf','-r600','naccR_corr_light')
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% params for plotting just 2 MFB fiber groups %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear fg

targets={
    'nacc';
    'nacc'};

fgStrs = {
    '_belowAC';
    '_aboveAC'};

fgNameStrs = { 
    '%s%s_%s%s%s_autoclean.pdb',...
    '%s%s_%s%s%s_autoclean.pdb'};
   
outStr = '_2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% get some useful plot params
scsz=get(0,'Screensize');
plotTubes = 1;  % plot fiber pathways as tubes or lines?
fg_rad = .2;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=100;


cols=cellfun(@(x,y) getDTIColors(x,y), targets, fgStrs,'uniformoutput',0);


plotToScreen=0; % 1 to plot to screen, otherwise 0

%%

if ~exist(outDir,'dir')
    mkdir(outDir)
end

cd(dataDir);

i=1;
for i = 1:numel(subjects)
    % for i = 1:5
    
    close all
    
    subject = subjects{i};
    
    fprintf('\n\nworking on subject %s...\n',subject);
    
    %load t1
    t1 = niftiRead(sprintf(t1Path,subject));
    % Rescale image values to get better gary/white/CSF contrast
    img = mrAnatHistogramClip(double(t1.data),0.3,0.99);
    t1.data=img;
    
    
    for j=1:numel(targets)
        
        % load L and R pathways
        fg{j,1} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStrs{j},seed,'L',targets{j},'L',fgStrs{j})]);
        fg{j,2} = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStrs{j},seed,'R',targets{j},'R',fgStrs{j})]);
    end
    
    
    
    %%   PLOTS
    
    
    sh=AFQ_RenderFibers(fg{1,1},'color',cols{1},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
    delete(sh); % delete light object (for some reason this needs to be deleted from the first FG plotted to look good...
    fig = gcf;
    pos=get(fig,'position');
    set(fig,'Position',[scsz(3)-610 scsz(4)-610 600 600])
    %   llh = lightangle(vw(1),vw(2));
    
    % this command makes the image fill the entire figure window:
    %    set(gca,'Position',[0,0,1,1]);
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    for j=1:numel(targets)
        sh=AFQ_RenderFibers(fg{j,1},'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
        sh=AFQ_RenderFibers(fg{j,2},'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'newfig',0);
    end
    
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
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_wb_sagittalL']));
    
    % change axis on y and zlims to close-up
    zlim(gca,[-50,50])
    ylim(gca,[-50,50])
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_sagittalL']));
    
    delete(h) % delete that slice
    
    %%%%%%%% right
    vwR = [90,0];
    
    h= AFQ_AddImageTo3dPlot(t1,[-1, 0, 0],'gray');
    
    %%% save out right side
    view(vwR)
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_wb_sagittalR']));
    
    % change axis on y and zlims to close-up
    zlim(gca,[-50,50])
    ylim(gca,[-50,50])
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_sagittalR']));
    
    delete(h) % delete that slice
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    vwC = [0,0]; % coronal view
    
    h=AFQ_AddImageTo3dPlot(t1,[0, 1, 0],'gray');
    view(vwC);
    %   llh = lightangle(vwC(1),vwC(2));
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_wb_coronal']));
    
    % change axis on x and zlims
    xlim(gca,[-40,40])
    zlim(gca,[-40,40])
    
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject outStr '_coronal']));
    
    fprintf('done.\n\n');
    
    
    %
    %      camlight(sh.l,'left');
    %   print(gcf,'-dpdf','-r600','naccR_corr_light')

    
end % subjects
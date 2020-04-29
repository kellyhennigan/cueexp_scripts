
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
dataDir = p.data; 
outDir = fullfile(p.figures_dti,'fgs_mni_corrmap');

fgStr = 'DAL_naccL_belowAC_autoclean';

fgmni=fgRead(fullfile(dataDir,'fibers_mni',[fgStr '_group_mni.pdb']));


t1 = niftiRead(fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii'));

fgMCorr='FA';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it 


% get some useful plot params
scsz=get(0,'Screensize');
plotTubes = 1;  % plot fiber pathways as tubes or lines?
fg_rad = 1;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=numel(fgmni.fibers);

plotToScreen=1; % 1 to plot to screen, otherwise 0


if ~exist(outDir,'dir')
    mkdir(outDir)
end

cd(dataDir);


% Rescale image values to get better gary/white/CSF contrast
t1.data = mrAnatHistogramClip(double(t1.data),0.3,0.99);
    
  
% get corr values
vals=dlmread(fullfile(dataDir,'fg_bis_corr_vals',[fgStr '_controls_wCV_agedwimotion_' fgMCorr]));

crange = [-.5 0];
rgb=repmat({vals2colormap(vals,'autumn',crange)},1,numel(fgmni.fibers));


    %%   PLOTS
    
%      sh=AFQ_RenderFibers(fgRes,'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
%     coords=SuperFiber.fibers{1};
%     radius=3;
%     color=vals;
%     subdivs=30;
%     cmap='autumn';
%      newfig=0; 
%      AFQ_RenderTractProfile(coords, radius, vals, subdivs, cmap, crange, newfig)
%       
    sh=AFQ_RenderFibers(fgmni,'color',rgb,'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
    yl0=ylim; 
    zl0=zlim;
  
%    
%     delete(sh); % delete light object (for some reason this needs to be deleted from the first FG plotted to look good...
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
    
    % turn off lighting bc it washes out the t1 underlay
     set(sh,'Visible','off')
    
    % get whole brain axes limits
    zlwb=zlim;
    ylwb=ylim;
    
    view(vwL);
    
    % save out left fibers whole-brain figure
    print(gcf,'-dpng','-r300',fullfile(outDir,['BIS' fgMCorr 'corr' fgStr '_wb_sagittalL']));
    
    
    % change axis on y and zlims to close-up    
    zlim(gca,[-40,40])
    ylim(gca,[-40,40])
    
      print(gcf,'-dpng','-r300',fullfile(outDir,['BIS' fgMCorr 'corr' fgStr '_sagittalL']));
   
    
      
    delete(h) % delete that slice
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% CORONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    vwC = [0,0]; % coronal view
    
    h=AFQ_AddImageTo3dPlot(t1,[0, -6, 0],'gray');
    view(vwC);
    %   llh = lightangle(vwC(1),vwC(2));
    
    set(gca,'fontName','Helvetica','fontSize',12)
    
    print(gcf,'-dpng','-r300',fullfile(outDir,['BIS' fgMCorr 'corr' fgStr '_wb_coronalL']));
    
    % change axis on x and zlims
    xlim(gca,[-40,40])
    zlim(gca,[-40,40])
    
     print(gcf,'-dpng','-r300',fullfile(outDir,['BIS' fgMCorr 'corr' fgStr '_coronalL']));
     
    fprintf('done.\n\n');
    
    
    %
    %      camlight(sh.l,'left');
    %   print(gcf,'-dpdf','-r600','naccR_corr_light')
    
    %% get colorbar 
    
    sh=AFQ_RenderFibers(fgRes,'color',rgb,'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
    caxis(crange);
    colormap(autumn);
    colorbar;
 set(gca,'fontName','Helvetica','fontSize',12)
   
    print(gcf,'-dpng','-r300',fullfile(outDir,[subject 'BIS' fgMCorr 'corr' fgStr '_colorbar']));
   
    


clear all
close all

rng('default')

% get experiment-specific paths and cd to main data directory
p = getCuePaths;
dataDir = p.data;
figDir = p.figures_dti;
outDir=[figDir '/subject_xcoord_plots'];

% subjects=getCueSubjects('dti',0);
subjects={'ph161104'};

% fibers directory relative to subject dir
% inDir = fullfile(dataDir,'fg_densities','mrtrix_fa');
inDir = fullfile(dataDir,'%s','fibers','mrtrix_fa');

fgNames = {'DA%s_nacc%s_belowAC_autoclean.pdb';
    'DA%s_nacc%s_aboveAC_autoclean.pdb';
    'DA%s_caudate%s_autoclean.pdb';
    'DA%s_putamen%s_autoclean.pdb'};


LR=['L','R'];


fgStrs = {'Inferior NAcc tract';...
    'Superior NAcc tract';...
    'Caudate tract';...
    'Putamen tract'};


msize=20;

cols=[
    0.9333    0.6980    0.1373
    0.9569    0.3961    0.0275
    0.9804    0.0941    0.1137
    0.1725    0.5059    0.6353];

nf=100;
%%


% create dir for saving out figs, if desired
if ~exist(outDir,'dir')
    mkdir(outDir)
end



%% load fg groups

i=1;
for i=1:numel(subjects)
    
    subject=subjects{i};
    
      
        t1=niftiRead([p.data '/' subject '/t1/t1_fs.nii.gz']);
        da=niftiRead([p.data '/' subject '/ROIs/PauliAtlasDA.nii.gz']);
        t1.data(da.data==1)=0;
      
    for lr=LR
        % lr='R';
        
        j=1
        for j=1:numel(fgNames)
            
            fg=fgRead([sprintf(inDir,subject) '/' sprintf(fgNames{j},lr,lr)]);
            
            % get just DA endpts
            endpts=cell2mat(cellfun(@(x) x(:,1), fg.fibers','uniformoutput',0))';
            
            % get an index to randomly select 100 fibers
            idx=randperm(size(endpts,1),nf);
            
            x(:,j)=endpts(idx,1);
            y(:,j)=endpts(idx,2);
            z(:,j)=endpts(idx,3);
            
        end
        
        
        fig=setupFig;
        hold on
        for  j=1:numel(fgNames)
            plot3(x(:,j),y(:,j),z(:,j),'.','markersize',msize,'color',cols(j,:))
        end
        xlabel('X coordinates')
        ylabel('Y coordinates')
        zlabel('Z coordinates')
        view([0,0]) % x on x-axis, z on y-axis
        axis equal
        outName = [subject lr '_XZcoords_points']
        print(fig,fullfile(outDir,outName),'-depsc')
        zl=zlim;
        xl=xlim;
        yl=ylim;
        
        AFQ_AddImageTo3dPlot(t1,[0 -20 0])
        rotate3d
        zlim(gca,zl)
        xlim(gca,xl)
        ylim(gca,yl)
        print(fig,fullfile(outDir,[outName '_wunderlay']),'-depsc')
        
    end % LR
    
end % subjects




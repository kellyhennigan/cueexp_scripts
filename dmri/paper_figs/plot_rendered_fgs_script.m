
clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p=getCuePaths();
% subjects=getCueSubjects('dti',0);
subject='ph161104';

dataDir = p.data; cd(dataDir)
% figDir = fullfile(p.figures,'dmri','fgs_single_subs');
figDir = fullfile(p.figures_dti,'rendered_tube_fgs');



method = 'mrtrix_fa';

fgDir = fullfile(dataDir,'%s','fibers',method);

seed = 'DA';
targets = {'nacc','nacc','caudate','putamen'};
fgStrs={'_aboveAC','_belowAC','',''}; % just for figure name

fgNameStrs = { '%s%s_%s%s%s_dil2_autoclean.pdb',...
    '%s%s_%s%s%s_dil2_autoclean.pdb',...
    '%s%s_%s%s%s_dil2_autoclean.pdb',...
    '%s%s_%s%s%s_dil2_autoclean.pdb'};

LorR = 'L';

% get some useful plot params
plotTubes = 1;  % plot fiber pathways as tubes or lines?
fg_rad = 1;   % radius of fiber pathway tubes (only matters if plotTubes=1)
nfibers=100;


cols=cellfun(@(x,y) getDTIColors(x,y), targets, fgStrs,'uniformoutput',0);


plotToScreen=1; % 1 to plot to screen, otherwise 0

% cols{1}=[212 41 47]./255;
% cols{2}=[253 127 40]./255;
%%

if ~exist(figDir,'dir')
    mkdir(figDir)
end

cd(figDir)

fprintf('\n\nworking on subject %s...\n',subject);



for j=1:numel(targets)
    
    for lr=LorR
        
        % load pathways
        
        fg = fgRead([sprintf(fgDir,subject) '/' sprintf(fgNameStrs{j},seed,lr,targets{j},lr,fgStrs{j})]);
        
        sh=AFQ_RenderFibers(fg,'color',cols{j},'numfibers',nfibers,'tubes',plotTubes,'radius',fg_rad,'plottoscreen',plotToScreen);
        
        set(gca,'GridlineStyle','none')
        axis off
        ylim([-32  25])
        zlim([-20 25])
        print(gcf,'-dpng','-r300',[targets{j} lr fgStrs{j}]);
        
    end
    
end

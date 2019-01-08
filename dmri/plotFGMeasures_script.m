% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot

p = getCuePaths();

dataDir = p.data;

method = 'mrtrix_fa';
inDir=fullfile(dataDir,'fgMeasures',method);



figDir = [p.figures,'/dmri/fa_trajectories/controls'];
if ~exist(figDir,'dir')
    mkdir(figDir)
end

fgFileStrs = {'DALR_naccLR_belowAC_dil2_autoclean';
    'DALR_naccLR_aboveAC_dil2_autoclean';
    'DALR_caudateLR_dil2_autoclean';
    'DALR_putamenLR_dil2_autoclean'};

fgStrs = {'VTA/SN - NAcc pathway (inferior)';
    'VTA/SN - NAcc pathway (superior)';
    'VTA/SN - Caudate pathway';
    'VTA/SN - Putamen pathway'};

% omitSubs = {'zl150930','ps151001','aa151010','al151016','jv151030',...
%     'kl160122','ss160205','bp160213','cs160214','yl160507','li160927',...
%     'gm161101'};
% omitSubs = {'rl170603'}; % any subjects to omit?
omitSubs={''};

plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures

outDir_suffix = '';

plotColorSet = 'color'; % 'grayscale' or 'color'

plotErr = 'shaded'; % 'bar' or 'shaded'


cols{1}=[ 0.8275    0.2118    0.5098];
cols{2}= [0.9569    0.3961    0.0275];
cols{3}=[ 0.9333    0.6980    0.1373];
cols{4}=[0.1294    0.4431    0.7098];

plotToScreen=1; % 1 to plot to screen, otherwise 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

cd(inDir)

for j=1:numel(fgFileStrs)
    
    fgFileStr=fgFileStrs{j};
    load(fgFileStr)
    
    fa{1}=fgMeasures{1}(gi==0,:);
    % fa{2}=fgMeasures{1}(gi==1,:);
    
    mean_fa = cellfun(@nanmean, fa,'uniformoutput',0);
    se_fa = cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), fa,'uniformoutput',0);
    
    
    %% set up all plotting params
    
    % fig title
    figtitle = [fgStrs{j} ' FA profile'];
    
    % x and y labels
    xlab = 'Location (node)';
    ylab = 'FA';
    
    
    % labels for each line plot (goes in the legend)
    lineLabels={'controls'};
    %         lineLabels = cell(numel(groups),numel(stims));
    %         if numel(stims)>1
    %             lineLabels = repmat(stims,numel(groups),1); lineLabels = strrep(lineLabels,'_',' ');
    %         end
    %         if numel(groups)>1
    %             for g=1:numel(groups)
    %                 lineLabels(g,:) = cellfun(@(x) [x strrep(groups{g},'_',' ') ], lineLabels(g,:), 'uniformoutput',0);
    %             end
    %         end
    %
    
    % line colors & line specs
    lspec = '';
    
    % get stats, if plotting
    p=[];
    %         if plotStats
    %             if numel(groups)>1
    %                 p = getPValsGroup(tc); % one-way ANOVA
    %             else
    %                 p = getPValsRepMeas(tc); % repeated measures ANOVA
    %             end
    %         end
    
    
    % filepath, if saving
    savePath = [];
    if saveFig
        savePath = fullfile(figDir,fgFileStr);
    end
    
    
    %% finally, plot the thing!
    
    fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);
    
    switch plotErr
        case 'bar'
            [fig,leg]=plotNiceLinesEBar(1:size(fa{1},2),mean_fa,se_fa,cols(j),p,'',xlab,ylab,figtitle,'',plotToScreen);
        case 'shaded'
            [fig,leg]=plotNiceLines(1:size(fa{1},2),mean_fa,se_fa,cols(j),p,'',xlab,ylab,figtitle,'',plotToScreen);
    end
    
%     ylim([.2 .6])
    yl=ylim;
    plot([26 26],[yl(1) yl(2)],'--','linewidth',2,'color',[.2 .2 .2]);
    plot([75 75],[yl(1) yl(2)],'--','linewidth',2,'color',[.2 .2 .2]);
    ylim(yl)
    if savePath
        print(gcf,'-dpng','-r300',savePath);
    end
    
    fprintf('done.\n\n');
    
    
end % fgFileStrs
%




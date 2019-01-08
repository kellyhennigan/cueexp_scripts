% plot roi time courses by subject 

% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;
figDir = p.figures;

% directory & filename of fg measures
method = 'mrtrix_fa';
fgMatStr = 'DALR_naccLR_belowAC_dil2_autoclean'; %'.mat' will be added to end

% plot both groups
group = {'controls','patients'};

cols=getCueExpColors(group); % plotting colors for groups

omit_subs = {
%     'jr160507'
%     % 	'gm160909'
%     'ld160918'
%     'gm161101'
%     %     'cg160715'
%     % 	'jn160403'
%     % 	'sr151031'
    };

fgMPlot = 'FA'; % fg measure to plot as values along pathway node


%% load data

%%%%%%%%%%%% get fiber group measures
load(fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']))

keep_idx = ones(numel(subjects),1);

% remove omit_subs from keep index
keep_idx=logical(keep_idx.*~ismember(subjects,omit_subs));


%%  get fg data for just the desired subjects
subjects = subjects(keep_idx);
gi = gi(keep_idx);
fgMeasures = cellfun(@(x) x(keep_idx,:), fgMeasures,'uniformoutput',0);




% fgMeasure=fgMeasures{find(strcmp(fgMPlot,fgMLabels))};


for g=1:2
    groupfgm{g} = fgMeasures{find(strcmp(fgMPlot,fgMLabels))}(gi==g-1,:);
    n(g)=numel(gi(gi==g-1));
end

mean_fg = cellfun(@nanmean, groupfgm,'uniformoutput',0);
se_fg = cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);


p = getPValsGroup(groupfgm); % one-way ANOVA

xlab = 'fiber group nodes';
ylab = fgMPlot;
figtitle = 'group differences';
savePath ='';
plotToScreen=1;
cols = {[0 0 1];[1 0 0] }';

[fig,leg]=plotNiceLines(1:nNodes,mean_fg,se_fg,cols,p,{'controls','patients'},...
    xlab,ylab,figtitle,savePath,plotToScreen);

cd /Users/kelly/cueexp/figures/dti/group_diffs
print(gcf,'-dpng','-r300',[fgMPlot '_group']);




% plot roi time courses

% each figure will plot each subject's time course as a line for a single
% ROI for a single stim.

clear all
close all


% get paths for cue data & claudia's cue data
p = getCuePaths_Claudia;
dataDir2 = p.data;

p = getCuePaths;
dataDir = p.data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

figDir = p.figures;

tcDir = 'timecourses_afni_woOutliers';

roiStrs = {'nacc','ins','acing','caudate','mpfc','dlpfc'};
% roiStrs = {'acing'};


% lines plotted will be by subject, but more than 1 group can be specified
% note that >10 subjects makes it hard to tell who's who
groups = {'patients'}; % controls, patients, or both
% groups = {'patients'};

% specify specific stim types (e.g., 'food', or 'strong_want', etc.
% or 'want' for all want rating bins or 'type' for all image types
stim = 'strong_dontwant';

nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR

saveFig = 1;

useSpline = 0; % if 1, time series will be upsampled by TR*10



%% do it



t = 0:TR:TR.*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

r=1;
for r = 1:numel(roiStrs)

roiStr = roiStrs{r};

tc = {};


g=1;
for g=1:numel(groups)

if strcmpi(groups{g},'alcpatients') || strcmpi(groups{g},'2')
    inDir = fullfile(dataDir2,tcDir,roiStr);
else
    inDir = fullfile(dataDir,tcDir,roiStr);
end

%     [tc(g,:),subjects(g,:)]=cellfun(@(x) loadRoiTimeCourses(fullfile(inDir,[x '.csv']),groups{g},nTRs), stim,'uniformoutput',0);
[tc{g,1},subjects{g,1}]=loadRoiTimeCourses(fullfile(inDir,[stim '.csv']),groups{g},nTRs)

end

tc = cell2mat(tc);
subjects = vertcat(subjects{:});


if (useSpline) %  upsample time courses
    t_orig = t;
    t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
    tc = cellfun(@(x) spline(t_orig,x,t), tc, 'uniformoutput',0);
    tc =  cellfun(@(x) spline(t_orig,x,t), tc, 'uniformoutput',0);
end


%% plot it

cols = solarizedColors(size(tc,1));

figH = figure;
% set(figH, 'Visible', 'off');
hold on
ss = get(0,'Screensize'); % screen size

set(figH,'Position',[ss(3)-700 ss(4)-525 700 525]) % make figure 700 x 525 pixels
set(gca,'fontName','Arial','fontSize',14)
set(gca,'box','off');
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

for i=1:size(tc,1)
plot(xt,tc(i,:),'Linewidth',2,'color',cols(i,:))
end
set(gca,'XTickLabel',xt)

% legend
legend(subjects,'Location','EastOutside')
legend(gca,'boxoff')
% xlim([1 numel(xt)])
set(gca,'XTick',xt)
xlabel('time (in seconds) relative to cue onset')
ylabel('%\Delta BOLD')



% plot title
title([roiStr ' response to ' stim ' bysubject']);



%% save figure?

% nomenclature: roiStr_stimStr_groupStr

if saveFig
    
    outName = [roiStr '_' stim '_bysubject'];
    
   outDir = fullfile(figDir,tcDir,roiStr);
    
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
    
    print(gcf,'-dpng','-r600',fullfile(outDir,outName));
end


end % roiStrs







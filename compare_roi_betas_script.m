% a script to quickly compare ROI betas for, e.g., patients vs controls,
% etc.

clear all
close all

p = getCuePaths();
dataDir = p.data; 
figDir = p.figures;
task = 'cue';

[subjects,gi]=getCueSubjects(task);

inDir = fullfile(dataDir,['results_' task '_afni'],'roi_betas');

roi = 'VTA_clust'; % will look for a dir within inDir called this

stim = 'drugs'; % will compare this stim for patients vs controls 

gNames = {'controls','patients'}; % group names for plot

cols = getCueExpColors(2); % colors for plotting

 
%% load data

cd(fullfile(inDir,roi));

% load roi betas for controls and patients 
for g=1:numel(gNames)
    d{g} = loadRoiTimeCourses([stim '.csv'],subjects(gi==g-1));
end

% ttest 
[h,p] = ttest2(d{1},d{2})


%% plot data

titleStr = [strrep(roi,'_','') ' ' stim ' betas'];
legStr = gNames;
savePath = fullfile(figDir,'roi_betas',task,[roi '_' stim '_bygroup.png']);

% plot it
hh = plotNiceNHist(d,cols,titleStr,legStr,savePath);



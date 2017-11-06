% quick and dirty script to plot ROI betas

clear all
close all

p = getCuePaths();
dataDir = p.data;
figDir = p.figures;

task = 'cue';

betaDir = fullfile(dataDir,['results_' task '_afni_pa'],'roi_betas');

roiNames = {'nacc_desai','mpfc','VTA','ins_desai'};
% roiNames = {'nacc_desai'}

stims = {'drugs','food'};
stims = {'pa'};
stimStr = 'pa_drugs_food'

groups = {'controls','patients'};

cols = getCueExpColors(numel(groups));

saveOut = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

for j=1:numel(roiNames)
    
    roi=roiNames{j};
    
% load data
for g = 1:numel(groups)
    
    for k=1:numel(stims)
        
        B{g}(:,k) = loadRoiTimeCourses(fullfile(betaDir,roi,[stims{k} '.csv']),getCueSubjects('cue',groups{g}));
        
    end % stims
    
end % groups


% plot it
if saveOut
%     savePath = fullfile(figDir,'roi_betas',[roi '_betas_bars_bygroup.png']);
 savePath = fullfile(figDir,'roi_betas',[roi '_' stimStr '_betas.png']);
else
    savePath = [];
end
[fig,leg] = plotNiceBars(B,[roi ' betas'],stims,groups,cols,1,[roi ' betas by group and stim'],1,savePath,1);
    
end % roiNames

% % also plot as points 
% b0= B{1}(:,1)-B{1}(:,2); % drugs-neutral
% b1= B{2}(:,1)-B{2}(:,2); % drugs-neutral
% b0= B{1}(:,1); % drugs
% b1= B{2}(:,1); % drugs
% 
% fig2=setupFig
% hold on
% plot(zeros(numel(b0),1),b0(:,1),'.','color',cols(1,:),'markersize',20);
% plot(ones(numel(b1),1),b1(:,1),'.','color',cols(2,:),'markersize',20)
% xlim([-1 2])
% title([roi ' betas for drug-neutral by group'])
% 
% if saveOut
%     savePath2 = fullfile(figDir,'roi_betas',[roi '_betas_dots_bygroup.png']);
%     print(fig2,'-dpng','-r300',savePath2)
% end

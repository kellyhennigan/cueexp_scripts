% behavioral analysis script


clear all
close all


%% define filepaths & variables - edit as needed

% add scripts path to matlab's search path
p = getCuePaths;
path(p.scripts,path)


figDir = p.figures;




% data directory path
dataDir = p.data;
dataDir2='/Users/Kelly/cueexp_claudia/data';

% cue task data
fp1 = fullfile(dataDir, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string
fp2 = fullfile(dataDir2, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string



% define which subjects to analyze
[subjects,gi] = getCueSubjects(); % cell array with subject ID strings; gi index is 0 for controls and 1 for patients
[subjects2,gi2] = getCueSubjects_Claudia(); % cell array with subject ID strings; gi index is 0 for controls and 1 for patients


%% get data


fp1s = cellfun(@(x) sprintf(fp1,x), subjects, 'uniformoutput',0);
fp2s = cellfun(@(x) sprintf(fp2,x), subjects2, 'uniformoutput',0);

fps = [fp1s;fp2s];

subjects = [subjects;subjects2];
gi = [gi;gi2];

N = numel(subjects); % total # of subjects
n0=numel(find(gi==0)); n1=numel(find(gi==1)); n2=numel(find(gi==2));

[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fps, 'uniformoutput',0);



% get matrix of pref & mean pref ratings by trial type w/subjects in rows
pref = cell2mat(choice_num)';
mean_pref = [];
for i=1:numel(subjects)
    for j=1:4 % # of trial types
        mean_pref(i,j) = nanmean(choice_num{i}(trial_type{i}==j));
    end
end


%% Q1: are there differences in preference ratings by trial type? Does that vary across groups?


% one-way anova with repeated measures for only controls
anova_rm(mean_pref(gi==0,:));

% anova w/repeated measures comparing across groups
anova_rm({mean_pref(gi==0,:) mean_pref(gi==1,:) mean_pref(gi==2,:)})


% plot it
cols = [.15 .55 .82; .86 .2 .18;  0.83  0.21  0.51];

gmean_prefs = [];
se_prefs = [];
for i=1:3
    gmean_prefs(:,i) = mean(mean_pref(gi==i-1,:))';
    se_prefs(:,i) = (std(mean_pref(gi==i-1,:))./sqrt(numel(gi==0)))';
end

fig=figure; hold on;
h = barwitherr(se_prefs,gmean_prefs)
set(h,'EdgeColor','w')

set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

set(gca,'fontName','Arial','fontSize',14)
set(gca,'box','off');
colormap(cols)

% x axis
xLabels = {'alcohol','drugs','food','neutral'};
set(gca,'XTick',1:4)
set(gca,'XTickLabel',xLabels)
% set(gca,'XTickLabelRotation',30)

% y axis
ylabel('preference ratings')
% ylim([-.2, .45])

% legend
legend(['controls (n=' num2str(n0) ')'],...
    ['stim patients (n=' num2str(n1) ')'],...
    ['alc patients (n=' num2str(n2) ')'],'location','NorthEastOutside')
legend(gca,'boxoff')

% save figure?
saveFig = 0;
figDir = '/Users/Kelly/cueexp/figures';
if saveFig
    print(gcf,'-dpng','-r600',fullfile(figDir,'preference_ratings_by_group'))
end






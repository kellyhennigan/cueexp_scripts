% behavioral analysis script


clear all
close all


%% define filepaths & variables - edit as needed

% add scripts path to matlab's search path
p = getCuePaths;
path(path,p.scripts)


figDir = p.figures;




% data directory path
dataDir = p.data;


% cue task data
fp1 = fullfile(dataDir, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string
fp2 = fullfile(dataDir, '%s/behavior/cue_ratings.csv');


% qualtrics survey data & list of image types
fp3 = fullfile(dataDir, 'qualtrics_data/Post_Scan_Survey 6.csv');
fp4 = fullfile(dataDir, 'qualtrics_data/qualtrics_survey_image_types');


% define which subjects to analyze
[subjects,gi] = getCueSubjects(); % cell array with subject ID strings; gi index is 0 for controls and 1 for patients
N = numel(subjects); % total # of subjects
n0=numel(find(gi==0)); n1=numel(find(gi==1));


%% get data


fp1s = cellfun(@(x) sprintf(fp1,x), subjects, 'uniformoutput',0);
[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fp1s, 'uniformoutput',0);

% fp2s = cellfun(@(x) sprintf(fp2,x), subjects, 'uniformoutput',0);
% [cue_type,arousal,valence] = cellfun(@(x) getCueVARatings(x), fp2s, 'uniformoutput',0);
% 
% 
% [d,pa,na,familiarity,image_type]=getQualtricsData(fp3,fp4,subjects);


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
anova_rm({mean_pref(gi==0,:) mean_pref(gi==1,:)})


% plot it
cols = [.15 .55 .82; .86 .2 .18];

gmean_prefs = [mean(mean_pref(gi==0,:))',mean(mean_pref(gi==1,:))'];
se_prefs = [(std(mean_pref(gi==0,:))./sqrt(n0))',(std(mean_pref(gi==1,:))./sqrt(n1))'];

h = barwitherr(se_prefs,gmean_prefs)
set(h,'EdgeColor','w')

set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

set(gca,'fontName','Arial','fontSize',14)
set(gca,'box','off');
colormap(cols)

% x axis
xLabels = {'alcohol','drugs','food','neutral'};
set(gca,'XTickLabel',xLabels)
set(gca,'XTickLabelRotation',30)

% y axis
ylabel('preference ratings')
% ylim([-.2, .45])

% legend
legend(['controls (n=' num2str(n0) ')'],...
    ['addicts (n=' num2str(n1) ')'],'location','NorthEastOutside')
legend(gca,'boxoff')

% save figure?
saveFig = 1;
figDir = '/Users/Kelly/cueexp/figures';
if saveFig
    print(gcf,'-dpng','-r600',fullfile(figDir,'preference_ratings_by_group'))
end



%% Q: is there a relationship between RT and preference ratings?

rt = cell2mat(choice_rt'); choice = cell2mat(choice_num');
rt(isnan(choice))=[]; choice(isnan(choice))=[];

corr(choice,rt);
figure
plot(choice,rt,'.','markersize',10,'color',[.2 .2 .2])
xlabel('choice')
ylabel('RT')
% no there isn't - good! this means we can include RT as a regressor without worrying
% about correlated regressors



%% do post-experiment positive arousal ratings match preference ratings?



%% do valence/arousal cue ratings generally represent preferences for different categories?

% do intra-class correlation to test this 


%% are people's hunger levels related to their food ratings? 

corr(d.hungry,mean_pref(:,3))





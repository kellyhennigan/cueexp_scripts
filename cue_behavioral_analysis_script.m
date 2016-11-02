% behavioral analysis script


clear all
close all


%% define filepaths & variables - edit as needed

% add scripts path to matlab's search path
p = getCuePaths;
path(path,p.scripts)

saveFigs = 1; % 1 to save out generated figures, otherwise 0
figDir = fullfile(p.figures,'behavior');

% data directory path
dataDir = p.data;

% cue task data
fp1 = fullfile(dataDir, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string
fp2 = fullfile(dataDir, '%s/behavior/cue_ratings.csv');


% qualtrics survey data & list of image types
fp3 = fullfile(dataDir, 'qualtrics_data/Post_Scan_Survey161027.csv');


% define which subjects to analyze
[subjects,gi] = getCueSubjects('cue'); % cell array with subject ID strings; gi index is 0 for controls and 1 for patients
N = numel(subjects); % total # of subjects
n0=numel(find(gi==0)); n1=numel(find(gi==1));


%% get data


fp1s = cellfun(@(x) sprintf(fp1,x), subjects, 'uniformoutput',0);
[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fp1s, 'uniformoutput',0);

fp2s = cellfun(@(x) sprintf(fp2,x), subjects, 'uniformoutput',0);
[cue_type,arousal,valence] = cellfun(@(x) getCueVARatings(x), fp2s, 'uniformoutput',0);
% 
% 
[qd,pa,na,famil,qimage_type]=getQualtricsData(fp3,subjects);


%% define some useful variables 

condNames = {'alcohol','drugs','food','neutral'};
groupNames = {'controls','patients'};
cols = [.15 .55 .82; .86 .2 .18]; % group plot colors
plotSig = [1 1];


%% Q1: are there differences in pref ratings across trial types & groups? 
% Does that vary across groups?

% get matrix of pref & mean pref ratings by trial type w/subjects in rows
pref = cell2mat(choice_num')'; 
mean_pref = [];
for i=1:numel(subjects)
    for j=1:4 % # of trial types
        mean_pref(i,j) = nanmean(choice_num{i}(trial_type{i}==j));
    end
end

% pref ratings 
dName = 'preference ratings'; % measure to plot
d = {mean_pref(gi==0,:) mean_pref(gi==1,:)};
savePath = fullfile(figDir,'cue_pref.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);


%% now plot without alc condition

idx = [2 4 3]; % drugs neutral food

d{1} = d{1}(:,idx); d{2} = d{2}(:,idx); % pref ratings 
dName = 'preference ratings'; % measure to plot
savePath = fullfile(figDir,'cue_pref_no_alc.png');
fig = plotNiceBars(d,dName,condNames(idx),groupNames,cols,plotSig,savePath);



%% Q2: differences in pos & neg arousal across trial types and groups? 

mean_pa = []; mean_na = [];
for i=1:numel(subjects)
    for j=1:4 % # of trial types
        mean_pa(i,j) = nanmean(pa(i,qimage_type==j));
        mean_na(i,j) = nanmean(na(i,qimage_type==j));
    end
end

% positive arousal ratings
dName = 'positive arousal'; % measure to plot
d = {mean_pa(gi==0,:) mean_pa(gi==1,:)};
savePath = fullfile(figDir,'cue_pa.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);


% negative arousal ratings
dName = 'negative arousal'; % measure to plot
d = {mean_na(gi==0,:) mean_na(gi==1,:)};
savePath = fullfile(figDir,'cue_na.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);



%% Q3: differences in RT by trial type between groups? 

for s=1:numel(subjects)
    
    for j=1:numel(condNames)
        
        % cue rts 
        these_rt = cue_rt{s}(trial_type{s}==j);
        mean_cue_rt(s,j) = nanmean(these_rt(these_rt>0));
        n_cue_noresp(s,j) = numel(find(these_rt<0)); % keep track of # of no response trials
        
        % choice rts 
        these_rt = choice_rt{s}(trial_type{s}==j);
        mean_choice_rt(s,j) = nanmean(these_rt(these_rt>0));
        n_choice_noresp(s,j) = numel(find(these_rt<0)); % keep track of # of no response trials
        
        
    end
    
end

% cue rt 
dName = 'cue rt'; % measure to plot
d = {mean_cue_rt(gi==0,:) mean_cue_rt(gi==1,:)};
savePath = fullfile(figDir,'cue_cue_rt.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);


% choice rt 
dName = 'choice rt'; % measure to plot
d = {mean_choice_rt(gi==0,:) mean_choice_rt(gi==1,:)};
savePath = fullfile(figDir,'cue_choice_rt.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);



%% Q: is there a relationship between RT and preference ratings?

rt = cell2mat(choice_rt'); choice = cell2mat(choice_num');
rt(isnan(choice))=[]; choice(isnan(choice))=[];

figure
plot(choice,rt,'.','markersize',10,'color',[.2 .2 .2])
xlabel('choice')
ylabel('RT')

% looks slightly quadratic - shorter RTs for strong prefs & slightly longer
% rts for weaker prefs 


%% do post-experiment positive arousal ratings match preference ratings?

% correlation between PA and pref (averaged across subjects)
for i=1:numel(subjects)
    r(i) = corr(pref(i,:)',pa(i,:)');
end
nanmean(r)
fprintf(['\naverage correlation between pref & positive arousal ratings:\n' ...
    'r=%4.2f\n'], nanmean(r))
    
% yes - pref is correlated with post-experiment positive arousal ratings


%% are people's hunger levels related to their food ratings? 

r = corr(qd.hungry(~isnan(qd.hungry)),mean_pref(~isnan(qd.hungry),3));
fprintf(['\ncorrelation between hunger & food preference ratings:\n' ...
    'r=%4.2f\n'], r);


r = corr(qd.hungry(~isnan(qd.hungry)),mean_pa(~isnan(qd.hungry),3));
fprintf(['\ncorrelation between hunger & food preference ratings:\n' ...
    'r=%4.2f\n'], r);

% hunger seems to be more correlated with PA ratings than pref ratings -
% this makes sense because hunger levels are assessed after the scan at the
% same time as pa ratings are assessed


%% do patients have faster RTs for drugs compared to other stim? 

% cue RTs 
ttype = trial_type{1}; % trial type index 
cueRT=cell2mat(cue_rt')';
cueRT(cueRT==-1)=nan;
% cueRT = log(cueRT); % log transform to be closer to normally distributed 
cuert0=cueRT(gi==0,:);
cuert1=cueRT(gi==1,:);
fprintf('\npatients average RT to drug cues: %4.2f s\n',...
    mean(nanmean(cuert1(:,ttype==2),2)))
fprintf('\npatients average RT to neutral cues: %4.2f s\n',...
    mean(nanmean(cuert1(:,ttype==4),2)))
[h,p]=ttest(nanmean(cuert1(:,ttype==2),2),nanmean(cuert1(:,ttype==4),2));
fprintf(['\nt test for drug vs neutral cue RT differences in patients:\n ' ...
    'h=%d, p=%4.2f\n'],h,p) 


% choice RTs
choiceRT=cell2mat(choice_rt')';
choiceRT(choiceRT==-1)=nan;
% choiceRT = log(choiceRT); % log transform to be closer to normally distributed 
choicert0=choiceRT(gi==0,:);
choicert1=choiceRT(gi==1,:);
fprintf('\npatients average RT to drug pref ratings: %4.2f s\n',...
    mean(nanmean(choicert1(:,ttype==2),2)))
fprintf('\npatients average RT to neutral pref ratings: %4.2f s\n',...
    mean(nanmean(choicert1(:,ttype==4),2)))
[h,p]=ttest(nanmean(choicert1(:,ttype==2),2),nanmean(choicert1(:,ttype==4),2));
fprintf(['\nt test for drug vs neutral pref rating RT differences in patients:\n ' ...
    'h=%d, p=%4.2f\n'],h,p) 




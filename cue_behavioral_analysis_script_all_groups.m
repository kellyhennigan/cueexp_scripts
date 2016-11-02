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
dataDir2='/Users/Kelly/cueexp_claudia/data';

% cue task data
fp1 = fullfile(dataDir, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string
fp2 = fullfile(dataDir2, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string



% define which subjects to analyze
[subjects,gi] = getCueSubjects('cue'); % cell array with subject ID strings; gi index is 0 for controls and 1 for patients
[subjects2,gi2] = getCueSubjects_Claudia('cue'); % cell array with subject ID strings; gi index is 0 for controls and 1 for patients



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


%% define some useful variables 

condNames = {'alcohol','drugs','food','neutral'};
groupNames = {'controls','stim patients','alc patients'};
cols = [.15 .55 .82; .86 .2 .18; 0.83  0.21  0.51]; % group plot colors
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
d = {mean_pref(gi==0,:) mean_pref(gi==1,:) mean_pref(gi==2,:)};
savePath = fullfile(figDir,'cue_pref_allgroups.png');
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
d = {mean_cue_rt(gi==0,:) mean_cue_rt(gi==1,:) mean_cue_rt(gi==2,:)};
savePath = fullfile(figDir,'cue_cueRT_allgroups.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);


% choice rt 
dName = 'choice rt'; % measure to plot
d = {mean_choice_rt(gi==0,:) mean_choice_rt(gi==1,:) mean_choice_rt(gi==2,:)};
savePath = fullfile(figDir,'cue_choiceRT_allgroups.png');
fig = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath);



%% do patients have faster RTs for drugs compared to other stim? 

% cue RTs 
ttype = trial_type{1}; % trial type index 
cueRT=cell2mat(cue_rt')';
cueRT(cueRT==-1)=nan;
% cueRT = log(cueRT); % log transform to be closer to normally distributed 
cuert0=cueRT(gi==0,:);
cuert1=cueRT(gi==1,:);
cuert2=cueRT(gi==2,:);
fprintf('\npatients average RT to drug cues: %4.2f s\n',...
    mean(nanmean(cuert1(:,ttype==2),2)))
fprintf('\npatients average RT to neutral cues: %4.2f s\n',...
    mean(nanmean(cuert1(:,ttype==4),2)))
[h,p]=ttest(nanmean(cuert1(:,ttype==2),2),nanmean(cuert1(:,ttype==4),2));
fprintf(['\nt test for drug vs neutral cue RT differences in patients:\n ' ...
    'h=%d, p=%4.2f\n'],h,p) 

fprintf('\nALC patients average RT to alcohol cues: %4.2f s\n',...
    nanmean(nanmean(cuert2(:,ttype==1),2)))
fprintf('\nALC patients average RT to neutral cues: %4.2f s\n',...
    nanmean(nanmean(cuert2(:,ttype==4),2)))
[h,p]=ttest(nanmean(cuert2(:,ttype==1),2),nanmean(cuert2(:,ttype==4),2));
fprintf(['\nt test for alc vs neutral cue RT differences in ALC patients:\n ' ...
    'h=%d, p=%4.2f\n'],h,p) 



% choice RTs
choiceRT=cell2mat(choice_rt')';
choiceRT(choiceRT==-1)=nan;
% choiceRT = log(choiceRT); % log transform to be closer to normally distributed 
choicert0=choiceRT(gi==0,:);
choicert1=choiceRT(gi==1,:);
choicert2=choiceRT(gi==2,:);
fprintf('\npatients average RT to drug pref ratings: %4.2f s\n',...
    mean(nanmean(choicert1(:,ttype==2),2)))
fprintf('\npatients average RT to neutral pref ratings: %4.2f s\n',...
    mean(nanmean(choicert1(:,ttype==4),2)))
[h,p]=ttest(nanmean(choicert1(:,ttype==2),2),nanmean(choicert1(:,ttype==4),2));
fprintf(['\nt test for drug vs neutral pref rating RT differences in patients:\n ' ...
    'h=%d, p=%4.2f\n'],h,p) 

fprintf('\nALC patients average RT to alcohol pref ratings: %4.2f s\n',...
    mean(nanmean(choicert2(:,ttype==1),2)))
fprintf('\nALC patients average RT to neutral pref ratings: %4.2f s\n',...
    mean(nanmean(choicert2(:,ttype==4),2)))
[h,p]=ttest(nanmean(choicert2(:,ttype==1),2),nanmean(choicert2(:,ttype==4),2));
fprintf(['\nt test for alc vs neutral pref rating RT differences in ALC patients:\n ' ...
    'h=%d, p=%4.2f\n'],h,p) 



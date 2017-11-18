% script to save out behavioral measures into csv files


clear all
close all

p = getCuePaths(); % structural array of experiment file paths

dataDir = p.data; % main data directory 

% subjects is cell array of subj ids & gi indexes group membership (0=controls, 1=patients)
task = 'cue';
[subjects,gi] = getCueSubjects(task); 


conds = {'alcohol','drugs','food','neutral'};


% # of total subjects, and # of controls and patients
N=numel(subjects);


% cue task data
fp1 = fullfile(dataDir, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string
fp2 = fullfile(dataDir, '%s/behavior/cue_ratings.csv');


% qualtrics survey data & list of image types
fp3 = fullfile(dataDir, 'qualtrics_data/Post_Scan_Survey_171015.csv');


% directory for saving out figures
outDir = fullfile(p.baseDir,'paper_figs','behavior');




%% get data

%%%%%%%%%%%%%%%%%%%%%%%%% load task stim files %%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp1s = cellfun(@(x) sprintf(fp1,x), subjects, 'uniformoutput',0);
[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fp1s, 'uniformoutput',0);

ci = trial_type{1}; % condition trial index (should be the same for every subject)


%%%%%%%%%%%%%%%%%%%%%%% load PA/NA cue ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp2s = cellfun(@(x) sprintf(fp2,x), subjects, 'uniformoutput',0);
[cue_type,cue_pa,cue_na] = cellfun(@(x) getCueVARatings(x), fp2s, 'uniformoutput',0);
 

%%%%%%%%%%%%%%%%%%%%% load qualtrics survey data %%%%%%%%%%%%%%%%%%%%%%%%%%
[qd,pa,na,famil,qimage_type]=getQualtricsData(fp3,subjects);



%%%%%%%%%%%%%%%%%%%%%%%%%%%% pref ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean pref ratings by condition w/subjects in rows
pref = cell2mat(choice_num')'; % subjects x items pref ratings
mean_pref = [];
for j=1:numel(conds) % # of conds
    mean_pref(:,j) = nanmean(pref(:,ci==j),2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%% PA/NA image ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean pa and na ratings by condition w/subjects in rows
mean_pa = []; mean_na = [];
for j=1:numel(conds) % # of trial types
    mean_pa(:,j) = nanmean(pa(:,qimage_type==j),2);
    mean_na(:,j) = nanmean(na(:,qimage_type==j),2);
end



%%%%%%%%%%%%%%%%%%%%%%%%%% familiarity ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean pa and na ratings by condition w/subjects in rows
mean_famil = [];
for j=1:numel(conds) % # of trial types
    mean_famil(:,j) = nanmean(famil(:,qimage_type==j),2);
end



%%%%%%%%%%%%%%%%%%%%%%%%%% PA/NA cue ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% re-arrange cue PA & NA ratings into matrix w/subjects in rows
cue_pa = cell2mat(cue_pa); 
cue_na = cell2mat(cue_na); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RTs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean cue/choice RTs & # of no responses by condition w/subjs in rows
cue_rt = cell2mat(cue_rt')'; % subjects x items cue RT
choice_rt=cell2mat(choice_rt')'; % subjects x items choice RT

% re-code no responses from -1 to NaN
cue_rt(cue_rt<0)=nan;  choice_rt(choice_rt<0)=nan;

mean_cueRT = []; n_cueNoresp = []; mean_choiceRT = []; n_choiceNoresp = [];
for j=1:numel(conds)
    
    % cue rts
    mean_cueRT(:,j) = nanmean(cue_rt(:,ci==j),2);
    n_cueNoresp(:,j) = sum(isnan(cue_rt(:,ci==j)),2);
    
    % choice rts
    mean_choiceRT(:,j) = nanmean(choice_rt(:,ci==j),2);
    n_choiceNoresp(:,j) = sum(isnan(choice_rt(:,ci==j)),2);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save out csv files 

% make group string column
group = cell(N,1);
group(gi==0)={'controls'};
group(gi==1)={'patients'};


% make relapse status column
relapse_6month_status = getCueData(subjects,'relapse_6months');


cd(outDir);


%% want ratings

d = mean_pref; 
varStr = '_want';
outName = 'want_ratings.csv';

for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end

T=array2table(d,'VariableNames',varNames);

T=[table(subjects,group,relapse_6month_status) T]; 

writetable(T,outName);



%% PA ratings 

d = mean_pa;
varStr = '_PA';
outName = 'PA_ratings.csv';

for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end

T=array2table(d,'VariableNames',varNames);

T=[table(subjects,group,relapse_6month_status) T]; 

writetable(T,outName);


%% NA ratings 

d = mean_na;
varStr = '_NA';
outName = 'NA_ratings.csv';

for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end

T=array2table(d,'VariableNames',varNames);

T=[table(subjects,group,relapse_6month_status) T]; 

writetable(T,outName);



%% famil ratings 

d = mean_famil;
varStr = '_familiar';
outName = 'familiarity_ratings.csv';

for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end

T=array2table(d,'VariableNames',varNames);

T=[table(subjects,group,relapse_6month_status) T]; 

writetable(T,outName);



%% cue RT

d = mean_cueRT;
varStr = '_cueRT';
outName = 'cueRT.csv';

for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end

T=array2table(d,'VariableNames',varNames);

T=[table(subjects,group,relapse_6month_status) T]; 

writetable(T,outName);


%% choice RT

d = mean_choiceRT;
varStr = '_choiceRT';
outName = 'choiceRT.csv';

for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end

T=array2table(d,'VariableNames',varNames);

T=[table(subjects,group,relapse_6month_status) T]; 

writetable(T,outName);











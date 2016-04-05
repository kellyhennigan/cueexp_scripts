% makeRegsSA2_script

% script to make regressors for all SA2 subjects
%
% will save out separate base and stress regressors for each stim
% listed below, a separate regressor time series will be modeled for onsets
% occurring during the baseline and stress contexts.


clear all
close all


%%%%%%%%%%%% for cue subjects
% subjects = getCueSubjects(); % subjects and context order code
subjects = {'jc160321'}

p = getCuePaths;
nTRs = 436; % hard code this because the behavioral data file goes only to 432 volumes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%% for Claudia's subjects
% subjects = getCueSubjects_Claudia(); % subjects and context order code
% p = getCuePaths_Claudia;
% nTRs = 446; % hard code this 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% main data directory containing subject directories for saving out regs
dataDir = p.data;


% stim file, where %s will be subject id
stimfilepath = [dataDir '/%s/behavior/cue_matrix.csv'];

% this corresponds to trial types 1-4, respectively
conds = {'alcohol','drugs','food','neutral'};


% labels to be used for reg filenames for pref ratings
pref_idx = [-2 -1 1 2];
pref_labels = {'strong_dontwant','somewhat_dontwant',...
    'somewhat_want','strong_want'};


hrf = 'waver'; % choices are spm or 'waver'

% subject stim file will have a TR column where TR indexes the following
% parts of each trial:
%   1 - cue onset
%   2 - image onset
%   3 & 4 - choice period
%   5,6 & 7 - iti period


%%%%% this script makes the following (unconvolved regressors):
% cue onset by condition (alcohol, drugs. etc.)
% img onset by condition
% choice onset by condition
% choice period by condition
% cue rt
% choice rt
% pref ratings at image onset
% pref ratigns at choice period onset



%%

for s=1:numel(subjects)
    
    subject = subjects{s};
    
    fprintf(['\n\nSaving regressor time series for subject ' subject '...\n\n']);
    
    % define subjects-specific directories
    subjDir = fullfile(dataDir,subject);
    regDir =  fullfile(subjDir,'regs');
    
    % if reg dir doesn't exist, create it
    if ~exist(regDir,'dir')
        mkdir(regDir)
    end
    
    
    [trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
        choice_type,choice_rt,iti,drift,image_name]=getCueTaskBehData(sprintf(stimfilepath,subject),'long');
    
    
    % if nTRs is zero, then behavioral data for this subject wasn't loaded
    if nTRs==0
        fprintf(['\n behavioral data not loaded for subject ' subject ', so skipping...\n'])
    else
        
        
        %% make reg time series
        
        
        %%%%%%%%%%%%%%%%%%% cue onset period: tr=1
        [reg,regc]=createRegTS(find(tr==1),1,nTRs,hrf,[regDir '/cue.1D']);
        
        
        
        %%%%%%%%%%%%%%%%%%% img onset period: tr=2
        [reg,regc]=createRegTS(find(tr==2),1,nTRs,hrf,[regDir '/img.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% choice onset period: tr=3
        [reg,regc]=createRegTS(find(tr==3),1,nTRs,hrf,[regDir '/choice.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% choice period: tr=3 & tr=4
        [reg,regc]=createRegTS(find(tr==3 | tr==4),1,nTRs,hrf,[regDir '/choice_period.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% cue onset by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(tr==1 & trial_type==i),1,nTRs,hrf,[regDir '/cue_' conds{i} '.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%%% image onset by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(tr==2 & trial_type==i),1,nTRs,hrf,[regDir '/img_' conds{i} '.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%%% cue & image by trial type
        for i=1:4
            idx1=find(tr==1 & trial_type==i);
            idx2=find(tr==2 & trial_type==i);
            [reg,regc]=createRegTS([idx1;idx2],1,nTRs,hrf,[regDir '/cueimg_' conds{i} '.1D']);
        end
      
        
        %%%%%%%%%%%%%%%%%%% choice onset by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(tr==3 & trial_type==i),1,nTRs,hrf,[regDir '/choice_' conds{i} '.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%%% choice period by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(trial_type==i & (tr==3 | tr==4)),1,nTRs,hrf,[regDir '/choice_period_' conds{i} '.1D']);
        end
        
        %%%%%%%%%%%%%%%%%%% cue onset by pref ratings (for VOIs)
        for i=1:4
            [reg,~]=createRegTS(find(tr==1 & choice_num==pref_idx(i)),1,nTRs,0, [regDir '/cue_' pref_labels{i} '.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%%% image onset by pref ratings
        for i=1:4
            [reg,regc]=createRegTS(find(tr==2 & choice_num==pref_idx(i)),1,nTRs,hrf, [regDir '/img_' pref_labels{i} '.1D']);
        end
        
        %%%%%%%%%%%%%%%%%%% choice onset by pref ratings
        for i=1:4   
            [reg,regc]=createRegTS(find(tr==3 & choice_num==pref_idx(i)),1,nTRs,hrf, [regDir '/choice_' pref_labels{i} '.1D']);
        end
        
        
        %%%%%%%%%% cue rt - model stick function w/RT as height at cue onset (tr=1)
        [reg,regc]=createRegTS(find(tr==1),cue_rt(tr==1),nTRs,hrf,[regDir '/cue_rt.1D']);
        
        
        %%%%%%%%%% choice rt - model stick function w/RT as height at choice onset (tr=1)
        [reg,regc]=createRegTS(find(tr==3),choice_rt(tr==1),nTRs,hrf,[regDir '/choice_rt.1D']);
        
        
        fprintf(['\n\ndone with subject ' subject '.\n']);
        
    end
    
end % subjects




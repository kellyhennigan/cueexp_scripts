% makeRegsSA2_script

% script to make a drug regressor using only drug images that the subject
% rated as familiar
%

clear all
close all

p=getCuePaths;
dataDir = p.data;

task = 'cue';
subjects = getCueSubjects(task,1);

nTRs = 436;


% stim file, where %s will be subject id
stimfilepath = [dataDir '/%s/behavior/cue_matrix.csv'];

% this corresponds to trial types 1-4, respectively
cond = 'drugs';


hrf = 'waver'; % choices are spm or 'waver'

% file of qualtrics survey data
qualfile = fullfile(dataDir, 'qualtrics_data/Post_Scan_Survey161105.csv');

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

% load familiarity ratings
[qd,pa,na,famil,qimage_type]=getQualtricsData(qualfile,subjects);
drug_famil = famil(:,qimage_type==2); 

s=1
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
        
       drug_trial_onsets =  find(tr==1 & trial_type==2);
       
   
       % get index of only the trials that were rated high familiarity  
       fam_ind = find(drug_famil(s,:)==7);
       
       % if less than 9 trials were rated a 7 on familiarity, take trials
       % with a ratings of 6 or 7
       if numel(fam_ind)<9
           fam_ind = find(drug_famil(s,:)>=6);
       end
        
       drug_trial_onsets = drug_trial_onsets(fam_ind);
       
       drug_trial_TRs = repmat(drug_trial_onsets,1,4)+repmat(0:3,numel(drug_trial_onsets),1);
 
       
        %%%%%%%%%%%%%%%%%%% cue onset 
        [reg,regc]=createRegTS(drug_trial_onsets,1,nTRs,hrf,[regDir '/' cond '_fam_cue_cue.1D']);
        
              
        %%%%%%%%%%%%%%%%%%% model whole trial 
        [reg,regc]=createRegTS(drug_trial_TRs,1,nTRs,hrf,[regDir '/' cond '_fam_trial_cue.1D']);
        
        
        fprintf(['\n\ndone with subject ' subject '.\n']);
        
    end
    
end % subjects




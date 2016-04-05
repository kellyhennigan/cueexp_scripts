% script to run to get subject's mid data (from the cuefmri project),
% concatenate blocks 1 and 2, and save out the concatenate stim time file. 

subject = input('enter subject id: ','s');



%% do it 

rawDataDir = '/Users/Kelly/Google Drive/cuefmri/mid/task_files/MID/data';
b1 = fullfile(rawDataDir,[subject '_b1.csv']);
b2 = fullfile(rawDataDir,[subject '_b2.csv']);

outDir1 = '/Users/Kelly/Google Drive/cuefmri/mid/behavioral_data';
outFilePath = fullfile(outDir1,[subject '_mid_matrix.csv']);

concatMidBehData(b1,b2,outFilePath)

outDir2 = ['/Users/Kelly/cueexp/data/' subject '/behavior'];
if ~exist(outDir2,'dir')
    mkdir(outDir2)
end
outFilePath = fullfile(outDir2,'mid_matrix.csv');

concatMidBehData(b1,b2,outFilePath)


% % get block 1 data 
% [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
%     total,iti,drift,total_winpercent,binned_winpercent,header]=getMidBehData(outFilePath);
% 

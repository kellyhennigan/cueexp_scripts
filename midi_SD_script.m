% signal detection calculation 
% based on notes here: 
% https://www.birmingham.ac.uk/Documents/college-les/psych/vision-laboratory/sdtintro.pdf
% and here:
% http://www.cns.nyu.edu/~david/handouts/sdt/sdt.html

%% 


clear all
close all

p = getCuePaths(); % structural array of experiment file paths

dataDir = p.data; % main data directory

% subjects is cell array of subj ids & gi indexes group membership (0=controls, 1=patients)
task = 'midi';
[subjects,gi] = getCueSubjects(task);

groups = {'controls','patients'}; % group names
% groups = {'controls','relapsers','nonrelapsers'}; % group names


gi_list = unique(gi); % list of group indices
if numel(groups) ~= numel(gi_list)
    error('hold up - the number of group names and group indices dont match...');
end

cols = getCueExpColors(numel(groups));

% # of total subjects, and # of controls and patients
N=numel(subjects); n0 = numel(gi==0); n1 = numel(gi==1);

% cell array of paths to subjects' behavioral data files
filepath = fullfile(dataDir,'%s','behavior',[task '_matrix.csv']); %s will be subject id

cueratings_filepath = fullfile(dataDir,'%s','behavior',[task '_ratings.csv']); %s will be subject id

% save out figures?
savePlots = 1;

% directory for saving out figures
outDir = fullfile(p.figures,[task '_behavior']);

% if saving plots and out dir doesn't exist already, create it
if savePlots
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
end

% trial type codes:
%   1 = +$0 GO
%   2 = +$0 NOGO
%   3 = -$0 GO
%   4 = -$0 NOGO
%   5 = +$5 GO
%   6 = +$5 NOGO
%   7 = -$5 GO
%   8 = -$5 NOGO

% names for trial types
ttypeNames = {'+0 GO','+0 NOGO','-0 GO','-0 NOGO','+5 GO','+5 NOGO','-5 GO','-5 NOGO'};
go_idx = [1:2:8]; nogo_idx = [2:2:8];
cueNames = {'$0 gain','$0 loss','$5 gain','$5 loss'};

% behavioral measures:
% % accuracy (wins) by trialtype)
% RTs for GO trials


%% load data

n_wins = []; % # of wins " "
mean_rt = []; % mean RTs matrix with trial type in columns and subjects in rows

% load task data
for i=1:N
    
    [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,win,trial_gain,...
        total,iti,drift,total_winpercent,binned_winpercent]=loadMidBehData(sprintf(filepath,subjects{i}),'short');
    
    for j=1:numel(unique(trialtype))
        
        p_win(i,j) = sum(trialtype==j & win==1)./numel(find(trialtype==j));
        mean_rt(i,j) = mean(rt(trialtype==j & rt>0));
        
    end % trialtype
    
    
end % subject loop

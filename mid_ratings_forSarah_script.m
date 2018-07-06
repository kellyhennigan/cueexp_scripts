% analysis of MID behavioral data

clear all
close all

p = getCuePaths(); % structural array of experiment file paths

dataDir = p.data; % main data directory 

% subjects is cell array of subj ids & gi indexes group membership (0=controls, 1=patients)
task = 'mid';
[subjects,gi] = getCueSubjects(task); 

groups = {'controls','patients'}; % group names



% # of total subjects, and # of controls and patients
N=numel(subjects); n0 = numel(gi==0); n1 = numel(gi==1); 

% cell array of paths to subjects' behavioral data files
% filepath = fullfile(dataDir,'%s','behavior',[task '_matrix.csv']); %s will be subject id

cueratings_filepath = fullfile(dataDir,'%s','behavior',[task '_ratings.csv']); %s will be subject id


% directory for saving out figures
outDir = '/Users/kelly/cueexp/data/mid_betas_VAratings_forSarah';


% trial type codes:
%   1 = -0
%   2 = -1
%   3 = -5
%   4 = +0
%   5 = +1
%   6 = +5

% names for trial types
ttypeNames = {'loss0','loss1','loss5','gain0','gain1','gain5'};


% RTs: 
% >0 = RT when the subject won 
% -1 = responded too late / no response
% -2 = responded too early (before target onset)


%% load data



% load cue ratings
cuepa = nan(N,numel(ttypeNames));
cuena = nan(N,numel(ttypeNames));
for i=1:N
    
    [pa,na,~]=getCueRatings(sprintf(cueratings_filepath,subjects{i}));
    if ~isempty(pa)
        cuepa(i,:)=pa;
    end
    if ~isempty(na)
        cuena(i,:)=na;
    end
end


%% make table 


subsCol = table(subjects);
group_index = table(gi);
Tpa=array2table(cuepa,'VariableNames',ttypeNames);
Tna=array2table(cuena,'VariableNames',ttypeNames);

Tpa=[subsCol group_index Tpa];
Tna=[subsCol group_index Tna];

writetable(Tpa,fullfile(outDir,'mid_cuePA.csv'));
writetable(Tna,fullfile(outDir,'mid_cueNA.csv'));


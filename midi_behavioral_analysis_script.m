% analysis of MID behavioral data

clear all
close all

p = getCuePaths(); % structural array of experiment file paths

dataDir = p.data; % main data directory 

% subjects is cell array of subj ids & gi indexes group membership (0=controls, 1=patients)
task = 'midi';
[subjects,gi] = getCueSubjects(task); 

groups = {'controls','patients'}; % group names


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


% load cue ratings

cuepa = nan(N,numel(cueNames));
cuena = nan(N,numel(cueNames));
for i=1:N
    
    [pa,na,~]=getCueRatings(sprintf(cueratings_filepath,subjects{i}));
    if ~isempty(pa)
        cuepa(i,:)=pa;
    end
    if ~isempty(na)
        cuena(i,:)=na;
    end
end



%% 1) figure: bar plot of reaction times by trial type

% RTs should be faster for high magnitude trials (gain/loss $5) vs lower
% magnitude trials ($0 or $1 trials)

% ONLY GO TRIALS

dName = 'RT'; 
d = {mean_rt(gi==0,go_idx) mean_rt(gi==1,go_idx)};
for g=1:numel(groups)   
    titleStr = sprintf('%s (n=%d) RTs by GO trial type',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,ttypeNames(go_idx),groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end
titleStr = sprintf('%s and %s RTs by trial type',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames(go_idx),groups,cols,[1 1],titleStr,1,savePath);



%% 2) figure: bar plot of % win by trial type

% Since the RT threshold for winning is dynamically changed based on
% performance to maintain performance of ~66% correct, performance isn't
% expected to deviate by trial type (by design)

% percent win (by trial type) for 1) controls, 2) patients, 3) both
dName = 'Pwin'; 
d = {p_win(gi==0,:) p_win(gi==1,:)};
for g=1:numel(groups)   
    titleStr = sprintf('%s (n=%d) accuracy by trial type',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,ttypeNames,groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end
titleStr = sprintf('%s and %s accuracy by trial type',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);



%% 4) figure: bar plots of PA/NA cue ratings

% PA ratings should be highest for gain $5 cues, and NA ratings should be
% greatest for loss $5 cues 

% PA cue ratings
dName = 'PAcueratings';
d = {cuepa(gi==0,:) cuepa(gi==1,:)};
titleStr = sprintf('%s and %s PA cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,cueNames,groups,cols,[1 1],titleStr,1,savePath);


% NA cue ratings
dName = 'NAcueratings';
d = {cuena(gi==0,:) cuena(gi==1,:)};
titleStr = sprintf('%s and %s NA cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,cueNames,groups,cols,[1 1],titleStr,1,savePath);








% analysis of MID behavioral data

clear all
close all

p = getCuePaths(); % structural array of experiment file paths

dataDir = p.data; % main data directory
    
% subjects is cell array of subj ids & gi indexes group membership (0=controls, 1=patients)
task = 'midi';

% groups = {'controls','patients'}; % group names
% groups = {'controls','relapsers','nonrelapsers'}; % group names
groups = {'relapsers','nonrelapsers'}; % group names

[subjects,gi] = getCueSubjects(task);


gi(gi>0)=1; % recode all patients as gi=1


%% if groups are relapsers/nonrelapsers

if any(strcmp(groups,'nonrelapsers')) && any(strcmp(groups,'relapsers'))
    
    % code nonrelapsers as 2 and relapsers as 3
    ri=getCueData(subjects,'relapse_6months');
    gi(ri==1)=2; % relapsers
    gi(ri==0)=3; % nonrelapsers
    
    % remove patients with nan data
    subjects(gi==1) = [];
    gi(gi==1)=[];
    
    if ~any(strcmp(groups,'controls'))
        subjects(gi==0)=[];
        gi(gi==0)=[];
    end
    
end

%%

gi_list = unique(gi); % list of group indices
if numel(groups) ~= numel(gi_list)
    error('hold up - the number of group names and group indices dont match...');
end

cols = getCueExpColors(groups);

% # of total subjects, and # of controls and patients
N=numel(subjects); 
% n0 = numel(gi==0); n1 = numel(gi==1);

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

nogottype=[2 4 6 8];
nogo5ttype=[6 8];
nogoplus5ttype=[6];

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
    
    
    nogofalsehits(i,1)=numel(find(win(ismember(trialtype,nogottype))==0));
   nogo5falsehits(i,1)=numel(find(win(ismember(trialtype,nogo5ttype))==0));
   nogoplus5falsehits(i,1)=numel(find(win(ismember(trialtype,nogoplus5ttype))==0));
    
    for j=1:numel(unique(trialtype))
        
        p_win(i,j) = sum(trialtype==j & win==1)./numel(find(trialtype==j));
        mean_rt(i,j) = mean(rt(trialtype==j & rt>0));
        
    end % trialtype
   
end % subject loop


%% signal detection values


% calculate dprime and criterion parameters for: 
% +0 trials 
% +5 trials
% all 0 trials 
% all 5 trials 
hit_rate_g0 = p_win(:,1);
false_alarm_g0 = 1-p_win(:,2);
hit_rate_g5 = p_win(:,5);
false_alarm_g5 = 1-p_win(:,6);
hit_rate_0 = (p_win(:,1)+p_win(:,3))./2;
false_alarm_0 = (1-p_win(:,2)+1-p_win(:,4))./2;
hit_rate_5 = (p_win(:,5)+p_win(:,7))./2;
false_alarm_5 = (1-p_win(:,6)+1-p_win(:,8))./2;

% 
% signal detection successful hits and false hits
for i=1:N
    [dpg0(i,1),cg0(i,1)] = dprime_simple(hit_rate_g0(i,1),false_alarm_g0(i,1));
    [dpg5(i,1),cg5(i,1)] = dprime_simple(hit_rate_g5(i,1),false_alarm_g5(i,1));
    [dp0(i,1),c0(i,1)] = dprime_simple(hit_rate_0(i,1),false_alarm_0(i,1));
    [dp5(i,1),c5(i,1)] = dprime_simple(hit_rate_5(i,1),false_alarm_5(i,1));
    
    % signal detection successful hits and false hits
    [dpg02(i,1),cg02(i,1)] = dprime(hit_rate_g0(i,1),false_alarm_g0(i,1));
    [dpg52(i,1),cg52(i,1)] = dprime(hit_rate_g5(i,1),false_alarm_g5(i,1));
    [dp02(i,1),c02(i,1)] = dprime(hit_rate_0(i,1),false_alarm_0(i,1));
    [dp52(i,1),c52(i,1)] = dprime(hit_rate_5(i,1),false_alarm_5(i,1));
    
end


% load cue ratings

cuepa = nan(N,numel(cueNames));
cuena = nan(N,numel(cueNames));
cueval = nan(N,numel(cueNames));
cuearo = nan(N,numel(cueNames));

for i=1:N
    
    [pa,na,val,aro,~]=getCueRatings(sprintf(cueratings_filepath,subjects{i}));
    if ~isempty(pa)
        cuepa(i,:)=pa;
    end
    if ~isempty(na)
        cuena(i,:)=na;
    end
     
    if ~isempty(val)
        cueval(i,:)=val;
    end
    if ~isempty(aro)
        cuearo(i,:)=aro;
    end

end



%% 1) figure: bar plot of reaction times by trial type

% RTs should be faster for high magnitude trials (gain/loss $5) vs lower
% magnitude trials ($0 or $1 trials)

% ONLY GO TRIALS


dName = 'RT';

% for each group separately
clear d
for g=1:numel(groups)
    d{g} = mean_rt(gi==gi_list(g),go_idx);
    titleStr = sprintf('%s (n=%d) RTs by GO trial type',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,ttypeNames(go_idx),groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end

% for all groups
titleStr = sprintf('%s %s and %s RTs by trial type',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames(go_idx),groups,cols,[1 1],titleStr,1,savePath);



%% figure: bar plot of reaction times by trial type

% RTs should be faster for high magnitude trials (gain/loss $5) vs lower
% magnitude trials ($0 or $1 trials)

% ONLY GO TRIALS

dName = 'deltaRT';

% 0-5 gain RT; 0-5 loss RT
deltaRT = [mean_rt(:,strcmp(ttypeNames,'+0 GO'))-mean_rt(:,strcmp(ttypeNames,'+5 GO')),...
    mean_rt(:,strcmp(ttypeNames,'-0 GO'))-mean_rt(:,strcmp(ttypeNames,'-5 GO'))];
condNames = {'0-5 GO gain trials','0-5 GO loss trials'}; 

% for each group separately
clear d
for g=1:numel(groups)
    d{g} = deltaRT(gi==gi_list(g),:);
    titleStr = sprintf('%s (n=%d) incentivized delta RTs for GO gains and losses',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,condNames,groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end

% for all groups
titleStr = sprintf('RTs by trial type',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,condNames,groups,cols,[1 1],titleStr,1,savePath);




%% figure: bar plot of % win by trial type

% Since the RT threshold for winning is dynamically changed based on
% performance to maintain performance of ~66% correct, performance isn't
% expected to deviate by trial type (by design)

% percent win (by trial type) for 1) controls, 2) patients, 3) both
dName = 'Pwin';

clear d
for g=1:numel(groups)
    
    d{g} = p_win(gi==gi_list(g),:);
    
    titleStr = sprintf('%s (n=%d) accuracy by trial type',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,ttypeNames,groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end

titleStr = 'accuracy by trial type by group';
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);


%% figure: bar plot of % win by go vs no go 

dName = 'Pwin GONOGO';

clear d
for g=1:numel(groups)
    
    group_pwin = p_win(gi==gi_list(g),:);
    
    d{g}(:,1) = mean(group_pwin(:,1:2:8),2); % go 
    d{g}(:,2) = mean(group_pwin(:,2:2:8),2); % no go 
    titleStr = sprintf('%s (n=%d) accuracy by GO vs NOGO',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,{'GO','NOGO'},groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end

titleStr = 'accuracy by GO vs NOGO trials by group';
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,{'GO','NOGO'},groups,cols,[1 1],titleStr,1,savePath);


%% figure: bar plot of % win by gain versus loss

dName = 'Pwin GAINLOSS';

clear d
for g=1:numel(groups)
    
    group_pwin = p_win(gi==gi_list(g),:);
    
    d{g}(:,1) = mean(group_pwin(:,[1 2 5 6]),2); % gain trials
    d{g}(:,2) = mean(group_pwin(:,[3 4 7 8]),2); % loss trials
    titleStr = sprintf('%s (n=%d) accuracy by GAIN vs LOSS trials',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,{'gain trials','loss trials'},groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end

titleStr = 'accuracy by GAIN vs LOSS trials by group';
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,{'gain trials','loss trials'},groups,cols,[1 1],titleStr,1,savePath);


%% figure: bar plot of % win by magnitude 

dName = 'Pwin 0 vs 5';

clear d
for g=1:numel(groups)
    
    group_pwin = p_win(gi==gi_list(g),:);
    
    d{g}(:,1) = mean(group_pwin(:,[1:4]),2); % 0  trials
    d{g}(:,2) = mean(group_pwin(:,[5:8]),2); % 5 trials
    titleStr = sprintf('%s (n=%d) accuracy by 0 vs HIGH trials',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,{'$0 trials','$5 trials'},groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end

titleStr = 'accuracy by 0 vs HIGH trials by group';
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,{'$0 trials','$5 trials'},groups,cols,[1 1],titleStr,1,savePath);







%% 4) figure: bar plots of PA/NA cue ratings

% PA ratings should be highest for gain $5 cues, and NA ratings should be
% greatest for loss $5 cues

% PA cue ratings
dName = 'PAcueratings';
clear d
for g=1:numel(groups)
    d{g} = cuepa(gi==gi_list(g),:);
end

titleStr = sprintf('PA cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,cueNames,groups,cols,[1 1],titleStr,1,savePath);


% NA cue ratings
dName = 'NAcueratings';
clear d
for g=1:numel(groups)
    d{g} = cuena(gi==gi_list(g),:);
end

titleStr = sprintf('NA cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,cueNames,groups,cols,[1 1],titleStr,1,savePath);



% val cue ratings
dName = 'VALENCEcueratings';
clear d
for g=1:numel(groups)
    d{g} = cueval(gi==gi_list(g),:);
end

titleStr = sprintf('VALENCE cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,cueNames,groups,cols,[1 1],titleStr,1,savePath);


% arousal cue ratings
dName = 'AROUSALcueratings';
clear d
for g=1:numel(groups)
    d{g} = cuearo(gi==gi_list(g),:);
end

titleStr = sprintf('AROUSAL cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,cueNames,groups,cols,[1 1],titleStr,1,savePath);


%% 

a=dp5;
a(abs(a)>10)
a(abs(a)>10)=nan
[h,p,~,stats]=ttest2(a(gi==0),a(gi==1))
[h,p,~,stats]=ttest2(a(rel==0),a(rel==1))


a=cg0;
a(abs(a)>10)
a(abs(a)>10)=nan
[h,p,~,stats]=ttest2(a(gi==0),a(gi==1))

% difference between patients and controls for d prime but not criterion
% for high rewards (but not 0 rewards)

%% figure: dprime and criterion

% Since the RT threshold for winning is dynamically changed based on
% performance to maintain performance of ~66% correct, performance isn't
% expected to deviate by trial type (by design)

% % percent win (by trial type) for 1) controls, 2) patients, 3) both
% dName = 'dprime_gain5';
% 
% clear d
% for g=1:numel(groups)
%     
%     d{g} = dpg5(gi==gi_list(g),:);
%     
%     titleStr = sprintf('%s (n=%d) d prime for high gains',groups{g},size(d{g},1));
%     if savePlots
%         savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
%     else
%         savePath = [];
%     end
%     fig = plotNiceBars(d{g},dName,[],groups(g),cols(g,:),[1 1],titleStr,1,savePath);
% end
% 
% titleStr = 'accuracy by trial type by group';
% if savePlots
%     savePath = fullfile(outDir,[dName '_bygroup.png']);
% else
%     savePath = [];
% end
% fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);
% 

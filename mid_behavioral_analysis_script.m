% analysis of MID behavioral data

clear all
close all

p = getCuePaths(); % structural array of experiment file paths

dataDir = p.data; % main data directory 

% subjects is cell array of subj ids & gi indexes group membership (0=controls, 1=patients)
task = 'mid';
[subjects,gi] = getCueSubjects(task); 

% groups = {'controls','patients'}; % group names
groups = {'controls'}; % group names

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

mean_rt = []; % mean RTs matrix with trial type in columns and subjects in rows
n_hits = []; % # of hits " " 
n_miss1 = []; % # of misses bc responded too late or not at all " " 
n_miss2 = []; % # of misses bc responded too early (BEFORE target onset)

% load task data
for i=1:N
    
    [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,win,trial_gain,...
        total,iti,drift,total_winpercent,binned_winpercent]=loadMidBehData(sprintf(filepath,subjects{i}),'short');
        
    for j=1:numel(unique(trialtype))
        
        mean_rt(i,j) = mean(rt(trialtype==j & rt>0)); % mean rt for win trials 
        p_win(i,j) = sum(trialtype==j & win==1)./numel(find(trialtype==j));
        p_miss1(i,j) = sum(trialtype==j & rt==-1)./numel(find(trialtype==j));
        p_miss2(i,j) = sum(trialtype==j & rt==-2)./numel(find(trialtype==j));
        
    end % trialtype
    
end % subject loop


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



%% 1) figure: bar plot of reaction times by trial type

% RTs should be faster for high magnitude trials (gain/loss $5) vs lower
% magnitude trials ($0 or $1 trials)


dName = 'RT'; 
d = {mean_rt(gi==0,:) mean_rt(gi==1,:)};
for g=1:numel(groups)   
    titleStr = sprintf('%s (n=%d) RTs by trial type',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,ttypeNames,groups(g),cols(g,:),[1 1],titleStr,1,savePath);
end
titleStr = sprintf('%s and %s RTs by trial type',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);



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
    fig = plotNiceBars(d{g},dName,ttypeNames,groups(g),cols(g,:),[1 1],titleStr,0,savePath);
end
titleStr = sprintf('%s and %s accuracy by trial type',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);


%% 3) figure: bar plot of # of early hits

% though RT threshold is dynamically changed to maintain performance of
% ~33% misses, so by design we don't expect variation in # of misses by
% trial type or group, it's possible that there are differences in # of
% misses due to early responses, which would indicate greater impulsive responding 

% percent win (by trial type) for 1) controls, 2) patients, 3) both
dName = 'nEarlyResponses'; 
d = {p_miss2(gi==0,:) p_miss2(gi==1,:)};
for g=1:numel(groups)   
    titleStr = sprintf('%s (n=%d) early responses by trial type',groups{g},size(d{g},1));
    if savePlots
        savePath = fullfile(outDir,[dName '_' groups{g} '.png']);
    else
        savePath = [];
    end
    fig = plotNiceBars(d{g},dName,ttypeNames,groups(g),cols(g,:),[1 1],titleStr,0,savePath);
end
titleStr = sprintf('%s and %s early responses by trial type',groups{:});
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
fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);


% NA cue ratings
dName = 'NAcueratings';
d = {cuena(gi==0,:) cuena(gi==1,:)};
titleStr = sprintf('%s and %s NA cue ratings',groups{:});
if savePlots
    savePath = fullfile(outDir,[dName '_bygroup.png']);
else
    savePath = [];
end
fig = plotNiceBars(d,dName,ttypeNames,groups,cols,[1 1],titleStr,1,savePath);



%% 5) figure: correlation between RT(loss/gain0-loss/gain5) and cue ratings 

%%%%%%%%%%% GAINS 

% cue positive arousal 
x=cuepa(:,6);
xlab = 'PA cue ratings (gain5)'; % x label

% x=cuepa(:,6)-cuepa(:,4);
% xlab = '\DeltaPA cue ratings (gain5-gain0)'; % x label

% gain RT
y=mean_rt(:,4)-mean_rt(:,6);
ylab = '\DeltaRT(gain0-gain5)'; % x label

% y=mean_rt(:,6);
% ylab = 'gain5 RTs'; % x label


figH=setupFig; axH=gca;
hold on
for g=1:numel(groups)
    [axH,rpStr] = plotCorr(axH,x(gi==g-1),y(gi==g-1),xlab,ylab,'',cols(g,:));
    tStr{g} = ['\fontsize{14}{\color[rgb]{' num2str(cols(g,:)) '}' groups{g} ' ' rpStr '} ']; % title strings
end
% to write corr coefficients side by side:
title(axH,[tStr{:}])
hold off
if savePlots
    print(gcf,'-dpng','-r300',fullfile(outDir,'cuePA_gainRT_corr_bygroup'));
end

%%%%%%%%%%% LOSSES

% cue negative arousal 
x=cuena(:,3);
xlab = 'NA cue ratings (loss5)'; % x label

% x=cuena(:,6)-cuena(:,4);
% xlab = '\DeltaNA cue ratings (loss5-loss0)'; % x label

% loss RT
y=mean_rt(:,1)-mean_rt(:,3);
ylab = '\DeltaRT(loss0-loss5)'; % x label

% y=mean_rt(:,3);
% ylab = 'loss5 RTs'; % x label


figH=setupFig; axH=gca;
hold on
for g=1:numel(groups)
    [axH,rpStr] = plotCorr(axH,x(gi==g-1),y(gi==g-1),xlab,ylab,'',cols(g,:));
    tStr{g} = ['\fontsize{14}{\color[rgb]{' num2str(cols(g,:)) '}' groups{g} ' ' rpStr '} ']; % title strings
end
% to write corr coefficients side by side:
title(axH,[tStr{:}])
hold off
if savePlots
    print(gcf,'-dpng','-r300',fullfile(outDir,'cueNA_lossRT_corr_bygroup'));
end




%% 6) correlation between cue ratings and NAcc anticipation for gains

% cue positive arousal 
x=cuepa(:,6);
xlab = 'PA cue ratings (gain5)'; % x label

% x=cuepa(:,6)-cuepa(:,4);
% xlab = '\DeltaPA cue ratings (gain5-gain0)'; % x label


% nacc activity 
% y = loadRoiTimeCourses(fullfile(p.data,'results_mid_afni','roi_betas','nacc_desai','gvnant.csv'),subjects,1);
% ylab = '\Delta NAcc BOLD(gain5-gain0)'; % y label

TRs = 3:5;
y = mean(loadRoiTimeCourses(fullfile(p.data,'timecourses_mid_afni','nacc_desai','gain5.csv'),subjects,TRs),2);
ylab = ['NAcc mean(TRs' num2str(TRs(1)) '-' num2str(TRs(end)) ')']; % y label


figH=setupFig; axH=gca;
hold on
for g=1:numel(groups)
    [axH,rpStr] = plotCorr(axH,x(gi==g-1),y(gi==g-1),xlab,ylab,'',cols(g,:));
    tStr{g} = ['\fontsize{14}{\color[rgb]{' num2str(cols(g,:)) '}' groups{g} ' ' rpStr '} ']; % title strings
end
% to write corr coefficients side by side:
title(axH,[tStr{:}])
hold off
if savePlots
    print(gcf,'-dpng','-r300',fullfile(outDir,'cuePA_nacc_corr_bygroup'));
end



%% 7) correlation between RT and NAcc anticipation for gains

% note: Brian isn't into this analysis - he doesn't think RT is a good
% proxy for motivation, but rather is motor-related, so predicts that it
% shouldnt be correlated with NAcc activity...

% gain RTs
x=mean_rt(:,4)-mean_rt(:,6);
xlab = '\DeltaRT(gain0-gain5)'; % x label

% x=mean_rt(:,6);
% xlab = 'gain5 RTs'; % x label

% nacc activity 
% y = loadRoiTimeCourses(fullfile(p.data,'results_mid_afni','roi_betas','nacc_desai','gvnant.csv'),subjects,1);
% ylab = '\Delta NAcc BOLD(gain5-gain0)'; % y label

TRs = 3:6;
y = mean(loadRoiTimeCourses(fullfile(p.data,'timecourses_mid_afni','nacc_desai','gain5.csv'),subjects,TRs),2);
ylab = ['NAcc mean(TRs' num2str(TRs(1)) '-' num2str(TRs(end)) ')']; % y label


figH=setupFig; axH=gca;
hold on
for g=1:numel(groups)
    [axH,rpStr] = plotCorr(axH,x(gi==g-1),y(gi==g-1),xlab,ylab,'',cols(g,:));
    tStr{g} = ['\fontsize{14}{\color[rgb]{' num2str(cols(g,:)) '}' groups{g} ' ' rpStr '} ']; % title strings
end
% to write corr coefficients side by side:
title(axH,[tStr{:}])
hold off
if savePlots
    print(gcf,'-dpng','-r300',fullfile(outDir,'gainRT_nacc_corr_bygroup'));
end





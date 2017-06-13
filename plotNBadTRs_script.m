
%%%%%%%% script to plot a historgram of the # of bad TRs for a given task
%%%%%%%% for all subjects

% hopefully this will be useful in determining a threshold for subject
% exclusion due to bad movement

clear all
close all


fprintf('\n\nsubjects from: \n\t1) our data or \n\t2) Claudia''s data?\n\n');
d = input('select 1 or 2: ');

% at least try to plot bad TRs for all subjects, regardless of whether
% they've already been omitted from analysis for a certain task
if d==1
    p = getCuePaths;
    subjects = getCueSubjects();
elseif d==2
    p = getCuePaths_Claudia;
    subjects = getCueSubjects_Claudia();
end
dataDir = p.data

funcDir = [dataDir '/%s/func_proc/']; % func data dir, %s is subject id
mp_file = '%s_vr.1D'; % motion param file where %s is task

figDir = fullfile(p.figures,'QA');

plotMotionLim = 1; % euclidean distance limit to plot


%% which task to process? 

fprintf('\n');
task = input('cue, mid, or midi task (or just hit return for no task)? ','s');


%% do it


if ~exist(figDir,'dir')
    mkdir(figDir);
end


for s = 1:numel(subjects)
    
    subject = subjects{s};
    
    mfile = [sprintf(funcDir,subject) sprintf(mp_file,task)];
    if exist(mfile,'file') && ~isempty(dlmread(mfile))
        mp = dlmread(mfile);
        mp = mp(:,2:7);
        
        en = [0;sqrt(sum(diff(mp).^2,2))]; % euclidean norm (head motion distance roughly in mm units)
        
        nBadTRs(s) = numel(find(en>plotMotionLim)); % # of bad TRs
        pBadTRs(s) = 100.*nBadTRs(s)./numel(en);  % of TRs in task that are bad
        
        fprintf(['\n' subject ' has ' num2str(pBadTRs(s)) ' percent bad motion vols\n\n'])
        
    else
        nBadTRs(s) = nan; pBadTRs(s) = nan;
    end
end


%% plot histogram


hist(pBadTRs,numel(subjects));

xlabel(['% of TRs with head movement > euc dist of ' num2str(plotMotionLim)])
ylabel('# of subjects')
title(['head movement during ' task ' task'])

print(gcf,'-dpng','-r300',fullfile(figDir,['subj hist of head movement during ' task ' task']));
  
 

%%
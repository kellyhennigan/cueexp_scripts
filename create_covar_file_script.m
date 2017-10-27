% create covariate file for afni analysis


clear all
close all

%%%%%%%%%%%%%%% get task, etc.
task = whichCueTask();
p = getCuePaths();
dataDir = p.data;

outDir = fullfile(dataDir,['results_' task '_afni']);

subjects = getCueSubjects(task);

var_str = '_glm';

covar = 'age';  % age is covariate of interest

age = getCueData(subjects,covar);

subjid=cellfun(@(x) [x var_str], subjects,'uniformoutput',0);

T=table(subjid,age);

writetable(T,fullfile(outDir,'subj_age'),'Delimiter','tab')



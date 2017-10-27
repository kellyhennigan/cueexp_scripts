

clear all
close all

%%%%%%%%%%%%%%% get task, etc.
task = 'cue';
p = getCuePaths();
dataDir = p.data;

outDir = fullfile(dataDir,['results_' task '_afni']);


[subjects,gi] = getCueSubjects(task);

cd(outDir)
cd roi_betas/naccR_single_vox

betas=loadRoiTimeCourses('drugs.csv',subjects);

age = getCueData(subjects,'age');


%% check that ttest results (without covar) are the same in matlab vs afni

[h,p,~,stats]=ttest(betas(gi==1))
Z=t2z(stats.tstat,stats.df)
% for A Zscore: -1.652182

[h,p,~,stats]=ttest2(betas(gi==1),betas(gi==0))
Z=t2z(stats.tstat,stats.df)
% for A-B Zscore: 0.89503

%% check ttest results are the same in matlab vs afni with age as covar



% for A Zscore: -1.630213

% for A Zscore (age): .097184


% for A-B Zscore: .909944

% for A-B Zscore (age): -1.581129


stats=glm_fmri_fit(betas,X);
[h,p,~,stats]=ttest(stats.err_ts(gi==1))
Z=t2z(stats.tstat,stats.df)




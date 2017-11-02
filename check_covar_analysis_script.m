

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

vc = [25,25,22]; % i j k coords for single roi voxel


%% ttest results for drugs - matlab method

[h,p,~,stats]=ttest(betas(gi==1))
ZA_ml=t2z(stats.tstat,stats.df)
% for A Zscore: -1.652182

[h,p,~,stats]=ttest2(betas(gi==1),betas(gi==0))
ZAB_ml=t2z(stats.tstat,stats.df)
% for A-B Zscore: 0.89503


%% ttest results for drugs: afni 

cd(outDir)

vol = niftiRead('Zdrugs.nii');
vol.data = squeeze(vol.data);

ZA_afni = vol.data(vc(1),vc(2),vc(3),4); 
ZAB_afni = vol.data(vc(1),vc(2),vc(3),2); 


%% matlab vs afni results

fprintf('\ndifference between matlab vs afni Zscore for drugs in patients:\n')
disp(ZA_afni-ZA_ml)

fprintf('\ndifference between matlab vs afni Zscore for drugs in patients vs controls:\n')
disp(ZAB_afni-ZAB_ml)


%% test results for drugs w/age as covar - matlab method

stats2=glm_fmri_fit(betas,[ones(78,1) gi age])

ZAB_drugs_matlab = t2z(stats2.tB(2),stats2.df_err);

ZAB_age_matlab = t2z(stats2.tB(3),stats2.df_err);


% approach 2: 
stats=glm_fmri_fit(betas,[ones(78,1) age]);
[h,p,~,stats]=ttest2(stats.err_ts(gi==1),stats.err_ts(gi==0));
ZAB2_drugs_matlab = t2z(stats2.tB

%% test results for drugs w/age as covar - afni method


vol = niftiRead('Zdrugs_CVage.nii');
vol.data = squeeze(vol.data);

ZAB_drugs_afni = vol.data(vc(1),vc(2),vc(3),2); 
ZAB_age_afni = vol.data(vc(1),vc(2),vc(3),4); 



%% 



% 

cd /Users/Kelly/cueexp/data/aa151010/func_proc_cue
ts= dlmread('nacc_ts')
cd ../design_mats/
load('glm.mat')

% fit model in matlab:
stats=glm_fmri_fit(ts,X,regIdx); 


cd ../../results_nacc

% errts & fitts from afni fit 
errts = dlmread('aa151010_glm_errts.1D');
fitts = dlmread('aa151010_glm_fitts.1D');


%% compare

% note that the model fits are pretty comparable in matlab & afni - phew! 

cols = solarizedColors;


n = 60;
ts_fit = X*stats.B;
ts_err = stats.err_ts;

figure
hold on
plot(ts(1:60),'color',cols(7,:))
plot(ts_fit(1:60),'color',cols(5,:))



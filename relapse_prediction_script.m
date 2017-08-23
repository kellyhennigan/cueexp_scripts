% relapse prediction


clear all
close all


p = getCuePaths(); 
dataDir = p.data;


dataPath = fullfile(dataDir,'relapse_data','relapse_data_170822.csv');

%% do it

% load data
T = readtable(dataPath); 

nanidx=find(isnan(T.relapse));
% T.relapse(nanidx)=1;


% get all variable names
vars = T.Properties.VariableNames; 


%% check everything by itself

for i=1:res.Coefficients.pValue

    res.Coefficients.pValue
    
%% model : demographic predictors


modelspec = 'relapse ~ years_of_use';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ days_sober';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ poly_drug_dep';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ smoke';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ depression_diag';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ ptsd_diag';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ education';
res=fitglm(T,modelspec,'Distribution','binomial')





%% model : behavior predictors

modelspec = 'relapse ~ pref_drug';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ pa_drug';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ pa_drugcue';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ craving';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ bamq3';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ bamstimuse';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ bamq11';
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = 'relapse ~ bis';
res=fitglm(T,modelspec,'Distribution','binomial')

% between drug pa, drug cue pa, drug pref, and craving, drug pa best
% predicts relapse


%% brain data

roiName = 'mpfc';

% drugs
% modelspec = ['relapse ~ ' roiName '_drugs_TR3 + ' roiName '_drugs_TR4 + ' roiName '_drugs_TR5 + ' roiName '_drugs_TR6 + ' roiName '_drugs_TR7'];
% res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugs_TR5 + ' roiName '_drugs_TR6 + ' roiName '_drugs_TR7'];
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugs_TRmean'];
res=fitglm(T,modelspec,'Distribution','binomial')


% food
% modelspec = ['relapse ~ ' roiName '_food_TR3 + ' roiName '_food_TR4 + ' roiName '_food_TR5 + ' roiName '_food_TR6 + ' roiName '_food_TR7'];
% res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_food_TR5 + ' roiName '_food_TR6 + ' roiName '_food_TR7'];
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_food_TRmean'];
res=fitglm(T,modelspec,'Distribution','binomial')

% neutral
% modelspec = ['relapse ~ ' roiName '_neutral_TR3 + ' roiName '_neutral_TR4 + ' roiName '_neutral_TR5 + ' roiName '_neutral_TR6 + ' roiName '_neutral_TR7'];
% res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_neutral_TR5 + ' roiName '_neutral_TR6 + ' roiName '_neutral_TR7'];
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_neutral_TRmean'];
res=fitglm(T,modelspec,'Distribution','binomial')


% drugs-neutral
% modelspec = ['relapse ~ ' roiName '_drugsneutral_TR3 + ' roiName '_drugsneutral_TR4 + ' roiName '_drugsneutral_TR5 + ' roiName '_drugsneutral_TR6 + ' roiName '_drugsneutral_TR7'];
% res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugsneutral_TR5 + ' roiName '_drugsneutral_TR6 + ' roiName '_drugsneutral_TR7'];
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugsneutral_TRmean'];
res=fitglm(T,modelspec,'Distribution','binomial')

% drugs-food
% modelspec = ['relapse ~ ' roiName '_drugsfood_TR3 + ' roiName '_drugsfood_TR4 + ' roiName '_drugsfood_TR5 + ' roiName '_drugsfood_TR6 + ' roiName '_drugsfood_TR7'];
% res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugsfood_TR5 + ' roiName '_drugsfood_TR6 + ' roiName '_drugsfood_TR7'];
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugsfood_TRmean'];
res=fitglm(T,modelspec,'Distribution','binomial')


tr = 6;
modelspec = ['relapse ~ ' roiName '_drugs_TR' num2str(tr)];
res=fitglm(T,modelspec,'Distribution','binomial')

% mpfc seems related to relapse


%% model: demographics + behavior + brain 

modelspec = ['relapse ~ years_of_use + drug_pa + ' roiName '_drugs_TRmean'];
res=fitglm(T,modelspec,'Distribution','binomial');


%% 

% model ideas based on TRs differentiating patients and controls drug
% activation: 

% VTA - 5,6,7
% VTA_func - 5,6,7
% nacc - 6 and 7
% vsL - 6 and 7
% vsR - 5 and 6
% mpfc - 6* and 7



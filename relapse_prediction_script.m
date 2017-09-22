% relapse prediction


clear all
close all


p = getCuePaths(); 
dataDir = p.data;


dataPath = fullfile(dataDir,'relapse_data','relapse_data_170921.csv');

%% do it

% load data
T = readtable(dataPath); 
T.relapse(15)=nan;
T.relapse(19)=nan;

nanidx=find(isnan(T.relapse));

% T.relapse(nanidx)=0;
% T.relapse(nanidx)=1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check everything by itself

% get all variable names
vars = T.Properties.VariableNames; 

a={};
tB=[];

for i=6:numel(vars)
    
    modelspec = ['relapse ~ ' vars{i}];
    res=fitglm(T,modelspec,'Distribution','binomial');
    if res.Coefficients.pValue(2)<.05
        a=[a vars{i}];
        tB = [tB res.Coefficients.tStat(2)];
    end
end

[tB,ti]=sort(tB'); tB
a = a(ti)'; a


%% model : demographic predictors

modelspec = 'relapse ~ years_of_use + poly_drug_dep + clinical_diag';
res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC


%% model : self-report predictors

modelspec = 'relapse ~ pref_drug + craving + bamq3';
res=fitglm(T,modelspec,'Distribution','binomial')


% bam q3 seems predictive
res.Rsquared.Ordinary
res.ModelCriterion.AIC

%% model : brain predictors

modelspec = 'relapse ~ mpfc_drugs_beta + nacc_drugs_beta + vta_drugs_beta';
res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC

% bam q3 seems predictive


%% model: demographics + behavior + brain 

modelspec = ['relapse ~ years_of_use + bamq3 + nacc_drugs_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC


% years of use seems to matter





%% brain data

roiName = 'nacc';

% drugs
% modelspec = ['relapse ~ ' roiName '_drugs_TR3 + ' roiName '_drugs_TR4 + ' roiName '_drugs_TR5 + ' roiName '_drugs_TR6 + ' roiName '_drugs_TR7'];
% res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugs_TR5 + ' roiName '_drugs_TR6 + ' roiName '_drugs_TR7'];
res=fitglm(T,modelspec,'Distribution','binomial')

modelspec = ['relapse ~ ' roiName '_drugs_TR567mean'];
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

modelspec = ['relapse ~ years_of_use + bamq3 + mpfc_drugs_TR567mean + vsR_clust_drugs_TR3'];
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



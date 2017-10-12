% relapse prediction


clear all
close all


p = getCuePaths(); 
dataDir = p.data;


dataPath = fullfile(dataDir,'relapse_data','relapse_data_170930.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171011.csv');

%% do it

% load data
T = readtable(dataPath); 

% T.relapse(15)=nan; % cg160715
% T.relapse(19)=nan; % lm60914
% T.relapse(27)=nan; % tg170423

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


%% 

modelspec = ['relapse ~ bam_upset + nacc_drugs_beta + pa_drug'];
res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC


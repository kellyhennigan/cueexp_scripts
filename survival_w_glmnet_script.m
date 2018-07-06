% script to compare glmnet functions to cox regressions

% refs:
% https://web.stanford.edu/~hastie/glmnet_matlab/intro.html
% https://www.mathworks.com/help/stats/cox-proportional-hazard-regression.html
% https://www.mathworks.com/help/stats/readmission-times.html

clear all
close all


p = getCuePaths(); 
dataDir = p.data; % cue exp paths
figDir = p.figures; 


% get relapse data
% [obstime,censored,notes]=getCueRelapseSurvival(subjects);

dataPath = fullfile(dataDir,'relapse_data','relapse_data_180312.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_170930.csv');

% load data
T = readtable(dataPath); 
T.bam_upset(isnan(T.bam_upset))=3;

% get all variable names
vars = T.Properties.VariableNames

%% omit subjects that have no followup data


% subjects with no followup data
nanidx=find(isnan(T.relapse));
% T.relapse(nanidx)=0;


% remove data for subjects with nan relapse values
T(nanidx,:)=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define model and response data

X = [T.nacc_drugs_beta T.bam_upset];
y = T.obstime;
yrel = T.relapse;
censored = T.censored; % 1 if data is censored (relapse didnt happen), otherwise 0

y2 = [y yrel]; % glmnet wants censored data in second column of y, with 1 for event occurring and 0 for censored data


%% logistic regression

res=fitglm(X,yrel,'Distribution','binomial')


%% Cox regression on relapse 

[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)


%% cox regression using glmnet

fit = glmnet(X, y2, 'cox');





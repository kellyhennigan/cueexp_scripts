% script to get stats reported in manuscript methods


clear all
close all

p = getCuePaths(); 
dataDir = p.data;

task = 'cue'; 

%  group = 'nonrelapsers_6months';  % can be controls, patients, relapsers, or nonrelapsers
% group = 'patients';
% group = 'controls';
patients = getCueSubjects('cue',1);
patients_3months=getCueSubjects('cue','patients_3months');


%% # of meth, crack, cocaine users

sum(getCueData(patients,'primary_meth'))
sum(getCueData(patients,'primary_crack'))
sum(getCueData(patients,'primary_cocaine'))


%% time in treatment

% mean/se for days in treatment prior to participation:
days=getCueData(patients,'days_in_rehab');
mean(days)
std(days)./sqrt(numel(patients))


%% days since most recent stim use: 

days=getCueData(patients,'days_sober')
mean(days)
std(days)./sqrt(numel(patients))


%% percent polydrug dependence

sum(getCueData(patients,'poly_drug_dep'))./numel(patients)


%% percent alcohol dependence

sum(getCueData(patients,'alc_dep'))./numel(patients)

%% percent of followups conducted via phone, in person etc.: 

% see "urine tests" tab in patient recovery records google sheet

%% median/se and range of final followup days

% final followup days 
fu=getCueData(patients_3months,'finalfollowupdays');

% median, sd, and range for follow-up interval: 
nanmedian(fu)
nanstd(fu)
min(fu)
max(fu)


%% # of relapsers, time to relapse

rel=getCueData(patients,'relapse')
obstime = getCueData(patients,'observedtime');


%% correlation between drug want ratings and pa ratings 


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath = fullfile(dataDir,'relapse_data','relapse_data_180516.csv');

% load data
T = readtable(dataPath); 

% define outcome variable
Y = 'relIn3Mos';


eval(['T(isnan(T.' Y '),:)=[];']);
Yy = eval(['T.' Y]);

pa=T.pa_drug
pa(27)
pa(27)=[]
pref=T.pref_drug
pref(27)=[]
[r,p]=corr(pa,pref)


%% alternative self-report model

modelspec = [Y '~ pa_drug + craving + bam_upset'];
res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);


% standardized coefficients: 
X=[T.pref_drug T.craving T.bam_upset]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');
for ii=2:numel(res_standard.Coefficients.Estimate)
    fprintf('\n\nstandard estimate, SE, and p value for reg %d:\n',ii-1);
    fprintf('%.3f (%.3f) ,  p=%.3f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end



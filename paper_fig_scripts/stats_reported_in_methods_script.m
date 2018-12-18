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


%% number of patients in monitored treatment after FOR

rel3=getCueData(patients_3months,'relapse_3months');
pt0=getCueData(patients_3months(rel3==0),'post_for_treatment');
pt1=getCueData(patients_3months(rel3==1),'post_for_treatment');

sum(pt0)
sum(pt1)


%% see if NAcc responsesto drugs or relapse @3 months 
% varied by stimulant subgroup of choice


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath =fullfile(dataDir,'relapse_data','relapse_data_181012.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_180723.csv');

% load data
T = readtable(dataPath); 

% test for nacc drug responses
nacc_meth=T.nacc_drugs_beta(T.primary_meth==1)
nacc_coccrack=T.nacc_drugs_beta(T.primary_cocaine==1 | T.primary_crack==1)
[h,p]=ttest2(nacc_coccrack,nacc_meth)
stats2=mes(nacc_coccrack,nacc_meth,'hedgesg') % hedges g is equivalent to d

% test for relapse differences 
T(isnan(T.relIn3Mos),:)=[];
rel3_meth=T.relIn3Mos(T.primary_meth==1);
rel3_coccrack=T.relIn3Mos(T.primary_cocaine==1 | T.primary_crack==1);
groupvar=[ones(numel(rel3_meth),1);ones(numel(rel3_coccrack),1).*2];
[tbl,chi2stat,pval] = crosstab(groupvar,[rel3_meth;rel3_coccrack])


%% see what happens if we remove subjects that admitted to 
% consuming drugs other than stimulants during follow-up. 

p = getCuePaths();
dataDir = p.data;
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath =fullfile(dataDir,'relapse_data','relapse_data_181015.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_180723.csv');
% load data
T = readtable(dataPath);
% T.relIn6Mos(4)=1; % set ja151218 to be relapsed in 6 months
% define outcome variable


% now get only abstainers
T(isnan(T.relapse),:)=[];
T(T.relapse==1,:)=[];

a=[T.post3mos_alcuse T.post3mos_thcuse T.post3mos_sedativeuse T.post3mos_opiateuse T.post3mos_inhalantuse T.post3mos_otherdruguse]; 


% subjects that did NOT report stim use but DID report other drug use after
% treatment: 
T.subjid(sum(a,2)>0);

omitsubjs=T.subjid(sum(a,2)>0)

omitsubjs={'wh160130'
    'ds170728'
    'vb170914'
    'ts170927'}


% omit these subjects and make sure the effect of NAcc drug response
% doesn't go away: 

T = readtable(dataPath);
% T.relIn6Mos(4)=1; % set ja151218 to be relapsed in 6 months
% define outcome variable

Y = 'relIn3Mos';
% omit subjects that have no outcome data
eval(['T(isnan(T.' Y '),:)=[];']);

for oi=1:numel(omitsubjs)
T(strcmp(T.subjid,omitsubjs{oi}),:)=[];
% ri=find(strcmp(T.subjid,omitsubjs{oi}));
% T.relIn3Mos(ri)=1;
end

Yy = eval(['T.' Y]);

% modelspec = [Y ' ~ nacc_drugs_beta'];
% res=fitglm(T,modelspec,'Distribution','binomial');

X=[T.nacc_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');
for ii=1:numel(res_standard.Coefficients.Estimate)
  fprintf('\n\nstandard estimate, SE, Z, and p value for reg %d:\n',ii-1);
    fprintf('%.3f (%.3f) , Z=%.3f, p=%.3f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.Estimate(ii)./res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end

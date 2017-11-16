% relIn6Mos prediction


clear all
close all


p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;

% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171031.csv');
dataPath = fullfile(dataDir,'relapse_data','relapse_data_171114.csv');

% load data
T = readtable(dataPath); 

%% omit subjects that have no followup data

% subjects with no followup data
nanidx=find(isnan(T.relapse));


% remove data for subjects with no followup data
T(nanidx,:)=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check everything by itself

% get all variable names
vars = T.Properties.VariableNames; 

a={};
tB=[];

for i=7:numel(vars)
     i
%     modelspec = ['relapse ~ ' vars{i}];
    modelspec = ['relIn6Mos ~ ' vars{i}];
    res=fitglm(T,modelspec,'Distribution','binomial');
    if res.Coefficients.pValue(2)<.05
        a=[a vars{i}];
        tB = [tB res.Coefficients.tStat(2)];
    end
end

[tB,ti]=sort(tB'); tB
a = a(ti)'; a


%% model : demographic predictors

modelspec = 'relIn6Mos ~ years_of_use + poly_drug_dep + clinical_diag';

res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC

% standardized coefficients: 
X=[T.years_of_use T.poly_drug_dep T.clinical_diag]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,T.relIn6Mos,'Distribution','binomial')

%% model : self-report predictors

modelspec = 'relIn6Mos ~ pref_drug + craving + bam_upset';
res=fitglm(T,modelspec,'Distribution','binomial')


res.Rsquared.Ordinary
res.ModelCriterion.AIC

% standardized coefficients: 
X=[T.pref_drug T.craving T.bam_upset]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,T.relIn6Mos,'Distribution','binomial')


%% model : brain predictors

modelspec = 'relIn6Mos ~ nacc_drugs_beta';

% modelspec = 'relIn6Mos ~ nacc_drugs_beta + vta_drugs_beta + mpfc_drugs_beta';
% modelspec = 'relIn6Mos ~ mpfc_drugs_beta + ains_drugs_beta + nacc_drugs_beta + vta_drugs_beta';

res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC


% standardized coefficients: 
X=[T.mpfc_drugs_beta T.nacc_drugs_beta T.vta_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,T.relIn6Mos,'Distribution','binomial')



%% model: demographics + behavior + brain 

modelspec = ['relIn6Mos ~ years_of_use + bam_upset + nacc_drugs_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

res.Rsquared.Ordinary
res.ModelCriterion.AIC

% standardized coefficients: 
X=[T.years_of_use T.bam_upset T.nacc_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,T.relIn6Mos,'Distribution','binomial')


%% model: ROI drugs, food, neutral betas

roi = 'nacc';

% DRUGS
modelspec = ['relIn6Mos ~ ' roi '_drugs_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

% FOOD
modelspec = ['relIn6Mos ~ ' roi '_food_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

% NEUTRAL
modelspec = ['relIn6Mos ~ ' roi '_neutral_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

% DRUGS & FOOD 
modelspec = ['relIn6Mos ~ ' roi '_drugs_beta + ' roi '_food_beta' ];
res=fitglm(T,modelspec,'Distribution','binomial')

% DRUGS & NEUTRAL
modelspec = ['relIn6Mos ~ ' roi '_drugs_beta + ' roi '_neutral_beta' ];
res=fitglm(T,modelspec,'Distribution','binomial')

% FOOD & NEUTRAL
modelspec = ['relIn6Mos ~ ' roi '_food_beta + ' roi '_neutral_beta' ];
res=fitglm(T,modelspec,'Distribution','binomial')

% % DRUGS & FOOD & NEUTRAL
modelspec = ['relIn6Mos ~ ' roi '_drugs_beta + ' roi '_food_beta + ' roi '_neutral_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cox regression on relapse 


X = [T.nacc_drugs_beta];
y = T.obstime;
censored = T.censored;

[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% only look at the first 6 months
idx=find(T.obstime>200 & T.relapse==1);
censored_6months=censored; censored_6months(idx)=1;
y_6months=y; y_6months(y>200) = 200;
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)


%% cox regression on relapse for ROI drugs, food, neutral betas


y = T.obstime;
censored = T.censored;


roi = 'mpfc';

% DRUGS
X = eval(['T.' roi '_drugs_beta']);
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% FOOD
X = eval(['T.' roi '_food_beta']);
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% NEUTRAL
X = eval(['T.' roi '_neutral_beta']);
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% DRUGS & FOOD 
X = [eval(['T.' roi '_drugs_beta']) eval(['T.' roi '_food_beta'])];
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% DRUGS & NEUTRAL
X = [eval(['T.' roi '_drugs_beta']) eval(['T.' roi '_neutral_beta'])];
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% FOOD & NEUTRAL
X = [eval(['T.' roi '_food_beta']) eval(['T.' roi '_neutral_beta'])];
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

% % DRUGS & FOOD & NEUTRAL
X = [eval(['T.' roi '_drugs_beta']) eval(['T.' roi '_food_beta']) eval(['T.' roi '_neutral_beta'])];
[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)



%% plot empirical distribution of relapse based on NAcc activity 
% 

% sort 
[obstime,si]=sort(T.obstime);
censored = T.censored(si);
subjects = T.subjid(si);
nacc = T.nacc_drugs_beta(si);

hi = find(nacc>median(nacc));
lo = find(nacc<median(nacc));

col=[    0.1294    0.4118    0.8157
    0.9804    0.1255    0.6314];

figure=setupFig;
hold on;

% lo
[empF1,x1,empFlo1,empFup1] = ecdf(obstime(lo),'censoring',censored(lo));
stairs(x1,empF1,'Linewidth',2,'color',col(1,:));


% hi
[empF2,x2,empFlo2,empFup2] = ecdf(obstime(hi),'censoring',censored(hi));
stairs(x2,empF2,'Linewidth',2,'color',col(2,:));

legend('low reactivity','high reactivity','Location','EastOutside')
legend('boxoff')

% confidence intervals
stairs(x1,empFlo1,':','Linewidth',2,'color',col(1,:)); 
stairs(x1,empFup1,':','Linewidth',2,'color',col(1,:));

stairs(x2,empFlo2,':','Linewidth',2,'color',col(2,:)); 
stairs(x2,empFup2,':','Linewidth',2,'color',col(2,:));

fsize = 22;
set(gca,'fontName','Arial','fontSize',fsize)  
xlabel('Time (days)'); ylabel('Proportion relapsed'); title('Empirical CDF')

% xlim([0 200])

hold off

savePath = fullfile(figDir,'relapse_prediction','empiricalCDF_lohi.png');
print(gcf,'-dpng','-r300',savePath);



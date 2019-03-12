
clear all
close all


p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;


dataPath = fullfile(dataDir,'relapse_data','relapse_data_190225.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_180516.csv');

% load data
T = readtable(dataPath); 


% define outcome variable
Y = 'relIn1Mos';


%% omit subjects that have no outcome data 

eval(['T(isnan(T.' Y '),:)=[];']);
Yy = eval(['T.' Y]);
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check everything by itself

% get all variable names
vars = T.Properties.VariableNames; 

a={};
zB=[];

y = T.obstime;
censored = T.censored;

for i=9:numel(vars)
    
    X = table2array(T(:,i));
    
    [b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)

   if stats.p<.05
        a=[a vars{i}];
        zB = [zB stats.z];
    end
end

[zB,ti]=sort(zB'); zB
a = a(ti)'; a


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cox regression on relapse 


X=[T.nacc_drugs_beta]; 
X=(X-nanmean(X))./nanstd(X);

y = T.obstime;
censored = T.censored;

[b,logl,H,stats] = coxphfit(X,y,'Censoring',censored)


%%

hazardratio=exp(b)
se=stats.se
HR_CIlo=exp(b-1.96.*se)
HR_CIhi=exp(b+1.96.*se)

% only look at the first 3 months
idx=find(T.obstime>100 & T.relapse==1);
censored_3months=censored; censored_3months(idx)=1;
y_3months=y; y_3months(y>100) = 100;
[b,logl,H,stats] = coxphfit(X,y_3months,'Censoring',censored_3months)


% only look at the first 6 months
idx=find(T.obstime>200 & T.relapse==1);
censored_6months=censored; censored_6months(idx)=1;
y_6months=y; y_6months(y>200) = 200;
[b,logl,H,stats] = coxphfit(X,y_6months,'Censoring',censored_6months)

% only look at the first 8 months
idx=find(T.obstime>240 & T.relapse==1);
censored_8months=censored; censored_8months(idx)=1;
y_8months=y; y_8months(y>240) = 240;
[b,logl,H,stats] = coxphfit(X,y_8months,'Censoring',censored_8months)

%% cox regression on relapse for ROI drugs, food, neutral betas


y = T.obstime;
censored = T.censored;

% enter ROI string here: 
roi = 'nacc';

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

col(1,:) = [150 150 150]./255; % nonrelapsers
col(2,:) = [30 30 30]./255; % relapsers

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
set(gca,'fontName','Helvetica','fontSize',fsize)  
xlabel('Time (days)'); ylabel('Proportion relapsed'); 
title('Empirical CDF')

% xlim([0 200])

hold off

savePath = fullfile(figDir,'relapse_prediction','empiricalCDF_lohi.png');
print(gcf,'-dpng','-r300',savePath);


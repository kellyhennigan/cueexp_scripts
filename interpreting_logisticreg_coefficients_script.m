% example to understand log odds ratios. Data and content are from here:
% http://personal.psu.edu/abs12//stat504/Lecture/lec13rev.pdf

% 'donner party' data has age and gender for members of the donner party,
% and whether or not they survived. 

%%%%%%% remember that: 

% odds = p / (1-p)
% prob = odds / (1+odds)
% exp(log_odds) = odds


%%
clear all
close all

cd /Users/kelly/cueexp/scripts

T=readtable('donner_party.txt'); 

%% first, found out baseline prob & odds of surviving, regardless of age or
% gender

% logisitic regression with only an intercept term gives the overall log(odds) 
% of an outcome variable: 
X=ones(size(T,1),1);
b = glmfit(X,T.survival,'binomial','constant','off'); 
odds = exp(b); % odds = exp(log(odds))
p = odds./(1+odds); % probability = odds / (1 + odds)

fprintf('\nlog odds of surviving: %.4f\n',b); 

fprintf('\nodds of surviving: %.2f\n',odds); 

fprintf('\nin other words,\n for every 1 person that dies,\n %.2f persons live :( \n\n',odds);

fprintf('\nprobability of surviving: %.2f\n',p); 

% confirm that this prob is the same as if calculated by hand: 
p_hand = numel(find(T.survival==1))./numel(T.survival);
fprintf('\nprobability of survival calculated by hand: %.2f\n',p_hand);


%% now interpret log odds for a dichotomous predictor of y: 

modelspec = 'survival ~ female';
res = fitglm(T,modelspec,'Distribution','binomial');

b=res.Coefficients.Estimate;

% the coefficient for the predictor 'female' is the log odds ratio of
% female survival / male survival. 

% This is the interpretation because female var is coded as 1 for females
% and 0 for males, and the coefficient is the log ratio for when female=1
% vs baseline when female=0 (so, for males) 

logodds_male = b(1); % Yhat for "baseline" model where female=0 (so, for males)
logodds_female = b(1)+b(2).*1; % Yhat for female model 

odds_male= exp(logodds_male);
odds_female = exp(logodds_female);
odds_ratio = odds_female./odds_male;


fprintf('\nodds of survival for males:%.3f\n',...
   odds_male);

fprintf('\nodds of survival for females:%.3f\n',...
   odds_female);

fprintf('\nodds ratio of survival for females / males: %.3f\n',...
   odds_ratio);

% other ways to summarize the results: 
fprintf('\nthe odds of survival were about %.1f times greater for women than men\n',...
   odds_ratio);

% convert log odds back to proportions using inverse logit: 
%           p = exp(Yhat) / ( 1 + exp(Yhat))
% where Yhat is log(odds)
p_male = exp(b(1))./(1 + exp(b(1)));
p_female = exp(b(1)+b(2).*1)./(1 + exp(b(1)+b(2).*1));

fprintf('\n prob of survival for males:%.3f\n',...
   p_male);

fprintf('\n prob of survival for females:%.3f\n',...
   p_female);


fprintf('\nfor every male that dies, %.2f males survive\n\n',odds_male);
fprintf('\nfor every female that dies, %.2f females survive\n\n',odds_female);
fprintf('\nfor every male that survives, %.2f females survive\n\n',odds_ratio);

%% interpret log odds for a continuous predictor of y:

agec = T.age-mean(T.age); % (centered age)
T=[T table(agec)]; % add agec to table T

ave_age = mean(T.age);  % useful to know

modelspec = 'survival ~ agec';
res = fitglm(T,modelspec,'Distribution','binomial');

b=res.Coefficients.Estimate;

logodds_base = b(1); % Yhat for model where age (mean-centered) is 0, so, average age
ny = 1; % number of years above or below the average age
logodds_age = b(1)+b(2).*ny; % Yhat for model with age = mean age + ny years

odds_base= exp(logodds_base);
odds_age = exp(logodds_age);
odds_ratio = odds_age./odds_base;


fprintf('\nodds of survival for mean age of %.0f years old:%.3f\n',...
   ave_age,odds_base);

fprintf('\nodds of survival for %.0f year old:%.3f\n',...
   ny+ave_age,odds_age);

fprintf('\nodds ratio of survival for %.0f / %.0f year olds: %.3f\n',...
   ave_age+ny,ave_age,odds_ratio);

% other ways to summarize the results: 
fprintf('\nfor every %.0f year old that survives,\n %.2f %.0f year olds survive.\n\n',...
    ave_age,odds_ratio,ave_age+ny);

% convert log odds back to proportions using inverse logit: 
%           p = exp(Yhat) / ( 1 + exp(Yhat))
% where Yhat is log(odds)
p_ave_age = exp(b(1))./(1 + exp(b(1)));
p_age = exp(b(1)+b(2).*ny)./(1 + exp(b(1)+b(2).*ny));

fprintf('\n prob of survival for mean age (%.0f years old):%.3f\n',...
   ave_age,p_ave_age);

fprintf('\n prob of survival for %.0f year old: %.3f\n',...
   ave_age+ny,p_age);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  example with nacc brain activity predicting relapse: 


clear all
close all

p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath = fullfile(dataDir,'relapse_data','relapse_data_180516.csv');

% load data
T = readtable(dataPath); 

% remove subjects with no followup data
T(find(isnan(T.relIn3Mos)),:)=[];

y = T.relIn3Mos;

% first calculate the overall odds of relapse @3 months: 
X=ones(size(y,1),1);
b = glmfit(X,y,'binomial','constant','off'); 
odds = exp(b); % odds = exp(log(odds))
p = odds./(1+odds); % probability = odds / (1 + odds)

fprintf('\nlog odds of relapse by 3 mos: %.3f\n',b); 
fprintf('\nodds of relapse by 3 mos: %.2f\n',odds); 
fprintf('\nprob of relapse by 3 mos: %.2f\n',p); 
fprintf('\nin other words,\n for every 1 person that doesnt relapse by 3 mos,\n %.2f persons do relapse \n\n',odds);


% now check out the effect of nacc activity: 
X = T.nacc_drugs_beta;
X=(X-nanmean(X))./nanstd(X);
res=fitglm(X,y,'Distribution','binomial');
b=res.Coefficients.Estimate;

logodds_base = b(1); % intercept coefficient
ny = 1; % 
logodds_nacc = b(1)+b(2).*ny; % Yhat for model for patient w/ nacc activity = 1

odds_base= exp(logodds_base);
odds_nacc = exp(logodds_nacc);
odds_ratio = odds_nacc./odds_base;

fprintf('\nbase odds of relapse by 3 mos: %.3f\n',odds_base); 
fprintf('\nnacc odds of relapse by 3 mos: %.2f\n',odds_nacc); 
fprintf('\nodds ratio for nacc/base of relapse by 3 mos: %.2f\n',odds_ratio); 
fprintf('\nin other words,\n 1 unit of nacc activity increases odds of relapse @ 3 mos by %.2f persons do relapse \n\n',odds_nacc);


fprintf('\nodds of relapse w/mean nacc activity (nacc=0):%.3f\n',...
   odds_base);

fprintf('\nodds of relapse with 1 unit of nacc activity:%.3f\n',...
 odds_nacc);

fprintf('\nodds ratio of relapse for nacc=1 / nacc=0: : %.3f\n',...
   odds_ratio);

% convert log odds back to proportions using inverse logit: 
%           p = exp(Yhat) / ( 1 + exp(Yhat))
% where Yhat is log(odds)
p_ave_nacc = exp(b(1))./(1 + exp(b(1)));
p_nacc = exp(b(1)+b(2).*ny)./(1 + exp(b(1)+b(2).*ny));

fprintf('\n prob of relapse for mean nacc activity:%.3f\n',...
   p_ave_nacc);

fprintf('\n prob of relapse for 1 sd above mean nacc activity: %.3f\n',...
   p_nacc);

% other ways to summarize the results: 
fprintf(['\npercent change in odds of survival\n',...
    'for nacc=1 vs nacc=0: %.1f\n'],100.*(odds_ratio-1));



%% 

% for cox regression with a continous predictor with mean=0 and sd=1, 
% you get coefficient B from the model fit, 
% the hazard ratio = exp(B)

% e.g., if b=0.8477, 
% hazard ratio = exp(b) = 2.3342, 

% which means that for every increase of 1 SD, there's a 133% increase in
% risk for relapse.





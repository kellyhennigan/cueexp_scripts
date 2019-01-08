% example to look at the relationship between AUC and likelihood

clear all
close all

% example data set: relationship between hours studied and passing an exam
hours=[0.50	0.75	1.00	1.25	1.50	1.75	1.75	2.00	2.25	2.50	2.75	3.00	3.25	3.50	4.00	4.25	4.50	4.75	5.00	5.50]';

pass=[0	0	0	0	0	0	1	0	1	0	1	0	1	0	1	1	1	1	1	1]';

% odds of passing the exam:
odds_pass = numel(find(pass==1))./numel(find(pass==0));

% probability of passing: 
p_pass =  numel(find(pass==1))./numel(pass);

% logistic reg:
mdl = fitglm(hours,pass,'Distribution','binomial','Link','logit');
B=mdl.Coefficients.Estimate;
logodds_pass = B(1)+B(2).*hours;
odds_pass = exp(logodds_pass);

% remember that p = odds / (1 + odds)
p_pass= odds_pass ./ (1 + odds_pass)

% get model's predictions 
scores = mdl.Fitted.Probability;

%%%%% scores  = p_pass

% note that for every additional hour studied, logodds of passing increases
% by: 
B(2)

% note that for every additional hour studied, ODDS of passing increases
% by: 
exp(B(2))


%% plot logistic reg results: 

x=[min(hours):.01:max(hours)]';

logodds_passx = B(1)+B(2).*x;
odds_passx = exp(logodds_passx);

% remember that p = odds / (1 + odds)
p_passx= odds_passx ./ (1 + odds_passx)

fig=setupFig
xlabel('hours studying')
ylabel('prob of passing exam')
hold on
plot(hours,pass,'.','Markersize',20,'color',[0 0 0])
plot(x,p_passx,'color',[1 0 0])


%% 

% calculate the log-likelihood of the data: 

% this takes the difference between: 
% model prob for each data point and actual score (0 or 1) and then 
% takes the product of all those differences: 
likelihood = prod(scores.^pass.*(1-scores).^(1-pass)); 
logl=log(likelihood)

isequal(mdl.LogLikelihood,logl)
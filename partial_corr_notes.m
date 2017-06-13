% explore partial correlation plot


clear all
close all

d = readtable('/Users/kelly/cueexp/data/temp/test_data.csv'); 

subjects = d.subjects;
scores=d.scores;
age=d.age;
gender = d.gender; % 0=male, 1=female

faL=d.faL;
mdL=d.mdL;
rdL=d.rdL;
adL=d.adL;

faR=d.faR;
mdR=d.mdR;
rdR=d.rdR;
adR=d.adR;

n = numel(subjects); 

% fa,md,rd,& ad vars are from L&R DA <-> nacc autoclean cl1 node 11

%% 
% there's a pretty strong correlation btwn md and scores
corr(mdL,scores)

% there's no correlation between scores and age
corr(scores,age)

% there's a negative correlation btwn age and md
corr(mdL,age)



%% ex 1: show that the partial correlation of MD and scores 
% (controlling for age) is the same as correlating the residual time series
% of scores (after regressing out the effect of age) and MD (after
% regressing out the effect of age) 

% i.e.: 
%   isequal(
%   partialcorr(md,scores,age)
%       vs
%   corr(md & scores residuals, after regressing out the effect of age)

cV = [age]; % control variables
X = [ones(n,1), cV];

B = pinv(X'*X)*X'*mdL;      % pinv(x) gives the (Moore-Penrose) pseudo inverse of x
Yhat = X*B;                 % model's prediction for Y
mdL_res = mdL-Yhat;         % error time series 

B = pinv(X'*X)*X'*scores;  
Yhat = X*B;                
scores_res = scores-Yhat;   % error time series 

% get residual time series for md & scores (after controlling for age)
fprintf('\npartial corr results: %.3f\n\n',partialcorr(mdL,scores,cV));
isequal(...
    round(10000.*partialcorr(mdL,scores,cV))./10000,...
    round(10000.*corr(mdL_res,scores_res))./10000)



%% ex 2: show that the partial correlation of MD and scores 
% (controlling for age AND gender) is the same as correlating the residual time series
% of scores (after regressing out the effect of age and gender) and MD (after
% regressing out the effect of age) 

% i.e.: 
%   isequal(
%   partialcorr(md,scores,age)
%       vs
%   corr(md & scores residuals, after regressing out the effect of age)

cV = [age, gender]; % control variables
X = [ones(n,1),cV];

B = pinv(X'*X)*X'*mdL;      % pinv(x) gives the (Moore-Penrose) pseudo inverse of x
Yhat = X*B;                 % model's prediction for Y
mdL_res = mdL-Yhat;         % error time series 

B = pinv(X'*X)*X'*scores;  
Yhat = X*B;                
scores_res = scores-Yhat;   % error time series 

% get residual time series for md & scores (after controlling for age)
fprintf('\npartial corr results: %.3f\n\n',partialcorr(mdL,scores,cV));
isequal(...
    round(10000.*partialcorr(mdL,scores,cV))./10000,...
    round(10000.*corr(mdL_res,scores_res))./10000)






[r,p]=partialcorr(scores,md,age);
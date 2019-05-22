% relIn3Mos prediction


clear all
close all


p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
% dataPath =fullfile(dataDir,'relapse_data','relapse_data_190321.csv');
dataPath =fullfile(dataDir,'relapse_data','relapse_data_190521.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_180723.csv');

% load data
T = readtable(dataPath); 

% remove subjects from 1st sample
idx=find(strcmp(T.subjid,'er171009'));
T1=T(1:idx,:);
T2=T(idx+1:end,:);
T(1:idx,:)=[];

% define outcome variable
Y = 'relIn3Mos';


%% omit subjects that have no outcome data 

eval(['T(isnan(T.' Y '),:)=[];']);
Yy = eval(['T.' Y]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check everything by itself

% get all variable names
vars = T.Properties.VariableNames; 

a={};
tB=[];

for i=9:numel(vars)
     i
%     modelspec = ['relapse ~ ' vars{i}];
    modelspec = [Y ' ~ ' vars{i}];
    res=fitglm(T,modelspec,'Distribution','binomial');
    if res.Coefficients.pValue(2)<.15
        a=[a vars{i}];
        tB = [tB res.Coefficients.tStat(2)];
    end
end

[tB,ti]=sort(tB'); tB
a = a(ti)'; a


%% check all demographics including nacc drug response
% 
a={};
tB=[];

for i=9:numel(vars)
    i
    %     modelspec = ['relapse ~ ' vars{i}];
    if ~strcmp(vars(i),'nacc_drugs_beta')
        modelspec = [Y ' ~ nacc_drugs_beta + ' vars{i}];
        res=fitglm(T,modelspec,'Distribution','binomial');
        bi=find(strcmp(res.CoefficientNames,vars{i}));
        if res.Coefficients.pValue(2)<.15
            a=[a vars{i}];
            tB = [tB res.Coefficients.tStat(2)];
        end
%         if res.Coefficients.pValue(bi)<.10
%             a=[a vars{i}];
%             tB = [tB res.Coefficients.tStat(bi)];
%         end
    end
end

[tB,ti]=sort(tB'); tB
a = a(ti)'; a


%% model : demographic predictors

modelspec = [Y ' ~ age'];

res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);

% standardized coefficients: 
X=[T.age]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');

for ii=1:numel(res_standard.Coefficients.Estimate)
    fprintf('\n\nstandard estimate, SE, Z, and p value for reg %d:\n',ii-1);
    fprintf('%.2f (%.2f) , Z=%.2f, p=%.2f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.Estimate(ii)./res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end





%% model : self-report predictors

modelspec = [Y '~ pref_drug + craving + bam_upset'];
res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);


% standardized coefficients: 
X=[T.pref_drug T.craving T.bam_upset]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');
for ii=1:numel(res_standard.Coefficients.Estimate)
   fprintf('\n\nstandard estimate, SE, Z, and p value for reg %d:\n',ii-1);
    fprintf('%.2f (%.2f) , Z=%.2f, p=%.2f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.Estimate(ii)./res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end



%% model : brain predictors

% modelspec = 'relIn3Mos ~ nacc_drugs_beta';
% modelspec = [Y ' ~ nacc_drugs_beta + mpfc_drugs_beta + vta_drugs_beta'];
modelspec = [Y ' ~ nacc_drugs_beta + mpfc_drugs_beta + VTA_drugs_beta'];


res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);


% standardized coefficients: 
% X=[T.nacc_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
X=[T.nacc_drugs_beta T.mpfc_drugs_beta T.vta_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');
for ii=1:numel(res_standard.Coefficients.Estimate)
   fprintf('\n\nstandard estimate, SE, Z, and p value for reg %d:\n',ii-1);
    fprintf('%.2f (%.2f) , Z=%.2f, p=%.2f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.Estimate(ii)./res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end




%% model: demographics + brain 

modelspec = [Y ' ~ age + nacc_drugs_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);

% standardized coefficients: 
X=[T.age T.nacc_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');
for ii=1:numel(res_standard.Coefficients.Estimate)
   fprintf('\n\nstandard estimate, SE, Z, and p value for reg %d:\n',ii-1);
    fprintf('%.2f (%.2f) , Z=%.2f, p=%.2f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.Estimate(ii)./res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end



%% model: just NAcc drugs response

modelspec = [Y ' ~ nacc_drugs_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);

% standardized coefficients: 
X=[T.nacc_drugs_beta]; X=(X-nanmean(X))./nanstd(X);
res_standard = fitglm(X,Yy,'Distribution','binomial');
for ii=1:numel(res_standard.Coefficients.Estimate)
   fprintf('\n\nstandard estimate, SE, Z, and p value for reg %d:\n',ii-1);
    fprintf('%.2f (%.2f) , Z=%.2f, p=%.2f\n',...
        res_standard.Coefficients.Estimate(ii),...
        res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.Estimate(ii)./res_standard.Coefficients.SE(ii),...
        res_standard.Coefficients.pValue(ii));
end





%% model: ROI drugs, food, neutral betas

roi = 'pvt';

% DRUGS
modelspec = [Y ' ~ ' roi '_drugs_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

% FOOD
modelspec = [Y ' ~ ' roi '_food_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

% NEUTRAL
modelspec = [Y ' ~ ' roi '_neutral_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')

% DRUGS & FOOD 
modelspec = [Y ' ~ ' roi '_drugs_beta + ' roi '_food_beta' ];
res=fitglm(T,modelspec,'Distribution','binomial')

% DRUGS & NEUTRAL
modelspec = [Y ' ~ ' roi '_drugs_beta + ' roi '_neutral_beta' ];
res=fitglm(T,modelspec,'Distribution','binomial')

% FOOD & NEUTRAL
modelspec = [Y '~ ' roi '_food_beta + ' roi '_neutral_beta' ];
res=fitglm(T,modelspec,'Distribution','binomial')

% % DRUGS & FOOD & NEUTRAL
modelspec = [Y ' ~ ' roi '_drugs_beta + ' roi '_food_beta + ' roi '_neutral_beta'];
res=fitglm(T,modelspec,'Distribution','binomial')



%% 


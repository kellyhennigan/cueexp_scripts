 %% cross validation script

clear all
close all


p = getCuePaths();
dataDir = p.data;
figDir = p.figures;


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath = fullfile(dataDir,'relapse_data','relapse_data_181014.csv');

% load data
T = readtable(dataPath);

% define outcome variable
DV = 'relIn3Mos';

nIter = 1; % number of tests performed on a given test subject

rng default % start random seed generator from same spot

% do over or undersampling to ensure that the # of instances of each class
% are equal in the training sets:
doOversample = 1;
doUndersample = 0;

%% omit subjects that have no followup data


eval(['T(isnan(T.' DV '),:)=[];']);
y = eval(['T.' DV]); % outcome variable


%% DEFINE MODEL


%  X = [T.years_of_use T.poly_drug_dep T.clinical_diag];

X = [T.nacc_drugs_beta];    % predictors
% X = [T.years_of_use T.nacc_drugs_beta];
% X = [T.nacc_drugs_beta T.mpfc_drugs_beta T.vta_drugs_beta];
% X = [T.age];
% X = [T.pref_drug T.craving T.bam_upset];
% X = [T.nacc_drugs_beta T.nacc_food_beta];    % predictors
% X = [T.age T.nacc_drugs_beta];    % predictors
% X = [T.nacc_drugs_beta T.nacc_food_beta];    % predictors


X=(X-nanmean(X))./nanstd(X);      % standardized


n=numel(y); % sample size

%% estimate model leaving 1 subject out

for i=1:n
    
    
    % test set
    Xtest = X(i,:);
    ytest = y(i);
    
    
    for j=1:nIter
        
        % training set
        Xtrain = X; Xtrain(i,:) = [];
        ytrain = y; ytrain(i) = [];
        
        %         undersample or oversample so that there's an even number of instances of both 0 and
        %         1 outcomes in the training set:
        if doUndersample
            
            idx0 = find(ytrain==0);
            idx1 = find(ytrain==1);
            
            ni = min([numel(idx0),numel(idx1)]); % # of instances of the fewer class
            idx=[idx0(randperm(numel(idx0),ni));idx1(randperm(numel(idx1),ni))]; % random subset of rows that'll contain a even number of 0 and 1 cases
            Xtrain = Xtrain(idx,:);
            ytrain = ytrain(idx);
            
        elseif doOversample
            
            idx0 = find(ytrain==0);
            idx1 = find(ytrain==1);
            
            ni = max([numel(idx0),numel(idx1)]); % # of instances of the fewer class
            
            % oversample by randomly sampling additional instances of the fewer class with replacement :
            if numel(idx0)<ni
                idx0=[idx0;datasample(idx0,ni-numel(idx0))];
            elseif numel(idx1)<ni
                idx1=[idx1;datasample(idx1,ni-numel(idx1))];
            end
            idx=[idx0;idx1];
            Xtrain = Xtrain(idx,:);
            ytrain = ytrain(idx);
            
        end
        
        % training set
        res = fitglm(Xtrain,ytrain,'Distribution','binomial');
        b = res.Coefficients.Estimate;
        
        % model's guess for test subject
        %     Ptest = exp(b(1) + b(2:end).*Xtest) ./ (1 + exp(b(1) + b(2:end).*Xtest)); % logistic transform
        Ptest = exp(b(1) + sum(b(2:end)'.*Xtest)) ./ (1 + exp(b(1) + sum(b(2:end)'.*Xtest))); % logistic transform
        testguess=Ptest >= .5;
        
        % keep track of accuracy
        acc(i,j) = testguess==ytest;
        
        
        %% linear SVM
        
        mod=fitcsvm(Xtrain,ytrain,'KernelFunction','linear','Standardize',1);
        [label,score] = predict(mod,Xtest);
        
        acc2(i,j) = label==ytest;
        
    end
    
end
%

%% get average accuracy across iterations for each test subject

ave_acc = mean(acc,2);
ave_acc_svm = mean(acc2,2);


%% is the classifier performing better than chance?

% this is only valid if downsampling was used in the training sets such
% that there were an even number of 0 and 1 instances

% if that's the case, the p value
p = 1-binocdf(sum(ave_acc),n,.5);

fprintf('\nSVM test accuracy: %.2f\n\n',100.*sum(ave_acc_svm)./n);

fprintf('\nlogistic reg test accuracy: %.2f and p=%.3f\n\n',100.*sum(ave_acc)./n,p);



%% log regression with all the data

res = fitglm(X,y,'Distribution','binomial');
res


% y=exp(beta(1) + beta(2).*T.nacc_drugs_beta) ./ (1 + exp(beta(1) + beta(2).*T.nacc_drugs_beta))

% (1 + e^(b0 + b1*x))



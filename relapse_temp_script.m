% relIn6Mos prediction


clear all
close all


p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath = fullfile(dataDir,'relapse_data','relapse_data_180510.csv');

% load data
T = readtable(dataPath); 


% define outcome variable
Y = 'relIn3Mos';


% omit subs lost to followup or count as relapsers? 
omit=1; 

roi = 'nacc';


%% omit subjects that have no outcome data 

eval(['T(isnan(T.' Y '),:)=[];']);
Yy = eval(['T.' Y]);

%% EITHER OMIT OR ASSIGN LOST SUBJECTS TO RELAPSERS


if any(strcmp(Y,{'relIn6Mos','relIn7Mos','relIn8Mos','relapse','earlyrelapse'}))
    lost_subs = {'wh160130','at160601','lm160914','jb161004','se161021'};

elseif any(strcmp(Y,{'relIn3Mos','relIn4Mos'}))
    lost_subs = {'at160601','lm160914'};

end


lost_idx=ismember(T.subjid,lost_subs);

% remove subjects lost to follow up:
if omit
    T(lost_idx,:)=[];
    
% assign subjects lost to follow up to be relapsers:
else
    eval(['T.' Y '(lost_idx)=1;']);
end



%% model : NAcc activity 

modelspec = [Y ' ~ ' roi '_drugs_beta'];

res=fitglm(T,modelspec,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res.ModelCriterion.AIC);


modelspec2 = [Y ' ~ ' roi '_drugs_beta + ' roi '_food_beta'];


res2=fitglm(T,modelspec2,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res2.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res2.ModelCriterion.AIC);

modelspec3 = [Y ' ~ ' roi '_drugs_beta + years_of_use'];


res3=fitglm(T,modelspec3,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res3.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res3.ModelCriterion.AIC);

modelspec4 = [Y ' ~ years_of_use'];

res4=fitglm(T,modelspec4,'Distribution','binomial')

fprintf('Rsquared: %.3f\n',res4.Rsquared.Ordinary);
fprintf('AIC: %.2f\n',res4.ModelCriterion.AIC);


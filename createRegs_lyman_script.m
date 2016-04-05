% script to make a regressor file compatible with Lyman processing 


clear all
close all

subjects = getCueSubjects(); % subjects and context order code

subjects = {'aa151010'};

% main data directory containing subject directories for saving out regs
p = getCuePaths;
dataDir = p.data;



% this script will look for reg files named [rename 'c.1D']
regNames = {'cue','img','choice',...
    'img_alcohol','img_drugs','img_food','img_neutral',...
    'choice_strong_dontwant','choice_somewhat_dontwant',...
    'choice_somewhat_want','choice_strong_want','choice_rt'};
    


%% subject loop

s=1;

subject = subjects{s};


for r=1:numel(regNames)
    X(:,r) = dlmread(fullfile(dataDir,subject,'regs',[regNames{r} 'c.1D']));
end

csvwrite_with_headers(fullfile(dataDir,subject,'design_mats','glm.csv'),...
    X,regNames)


fprintf(['\n\ndone with subject ' subject '.\n']);



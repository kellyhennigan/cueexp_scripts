% make design mat and contrast files for fsl mytbss analysis

% based on notes found here: 
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/GLM/CreatingDesignMatricesByHand

clear all 
close all


subs=getCueSubjects('dti',0); 

n = numel(subs); 
[a,b]=sort(subs); % sort alphabetically

subs(b)
bis=getCueData(subs,'bis')
bis=bis(b); 
bis=bis-mean(bis);

age=getCueData(subs,'age')
age=age(b);
age=age-mean(age);

% column of 1s for mean/intercept and column of mean-centered bis scores
bisdesign = [ones(n,1) bis];

% contrast for mean/intercept and for mean-centered bis 
biscontrasts = [1 0; 0 1];

% column of 1s for mean/intercept and column of mean-centered bis scores
bisagedesign = [bis age];

% contrast for mean/intercept and for mean-centered bis 
bisagecontrasts = [1 0; 0 1];

% column of 1s for mean/intercept and column of mean-centered age
agedesign = [ones(n,1) age];

% contrast for mean/intercept and for mean-centered age
agecontrasts = [1 0; 0 1];



%% save out design and contrasts to text files and convert to fsl format

cd /Users/kelly/cueexp/data/mytbss/stats

dlmwrite('bisdesign',bisdesign,'delimiter',' ')
dlmwrite('biscontrasts',biscontrasts,'delimiter',' ')

system('Text2Vest bisdesign bisdesignfsl')
system('Text2Vest biscontrasts biscontrastsfsl')


dlmwrite('bisagedesign',bisagedesign,'delimiter',' ')
dlmwrite('bisagecontrasts',bisagecontrasts,'delimiter',' ')

system('Text2Vest bisagedesign bisagedesignfsl')
system('Text2Vest bisagecontrasts bisagecontrastsfsl')


dlmwrite('agedesign',agedesign,'delimiter',' ')
dlmwrite('agecontrasts',agecontrasts,'delimiter',' ')

system('Text2Vest agedesign agedesignfsl')
system('Text2Vest agecontrasts agecontrastsfsl')
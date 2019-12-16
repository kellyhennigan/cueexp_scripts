% make design mat and contrast files for fsl mytbss analysis

% based on notes found here: 
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/GLM/CreatingDesignMatricesByHand

clear all 
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% mytbssdir = '/Users/kelly/cueexp/data/mytbss_controlsbis';
% 
% subs=getCueSubjects('dti',0); 
% 
% n = numel(subs); 
% [subs,b]=sort(subs); % sort alphabetically
% 
% bis=getCueData(subs,'bis')
% bis=bis-mean(bis);
% 
% age=getCueData(subs,'age')
% age=age-mean(age);
% 
% mot=getCueData(subs,'dwimotion')
% mot=mot-mean(mot);
% 
% % column of 1s for mean/intercept and column of mean-centered bis scores
% bisdesign = [ones(n,1) bis];
% 
% % contrast for mean/intercept and for mean-centered bis 
% biscontrasts = [1 0; 0 1];
% 
% % column of 1s for mean/intercept and column of mean-centered bis scores
% bisagedesign = [bis age];
% 
% % contrast for mean/intercept and for mean-centered bis 
% bisagecontrasts = [1 0; 0 1];
% 
% % column of 1s for mean/intercept and column of mean-centered age
% agedesign = [ones(n,1) age];
% 
% % contrast for mean/intercept and for mean-centered age
% agecontrasts = [1 0; 0 1];
% 
% %%%%%%%%% save out design and contrasts to text files and convert to fsl format
% 
% cd(mytbssdir)
% cd stats 
% 
% dlmwrite('bisdesign',bisdesign,'delimiter',' ')
% dlmwrite('biscontrasts',biscontrasts,'delimiter',' ')
% 
% system('Text2Vest bisdesign bisdesignfsl')
% system('Text2Vest biscontrasts biscontrastsfsl')
% 
% 
% dlmwrite('bisagedesign',bisagedesign,'delimiter',' ')
% dlmwrite('bisagecontrasts',bisagecontrasts,'delimiter',' ')
% 
% system('Text2Vest bisagedesign bisagedesignfsl')
% system('Text2Vest bisagecontrasts bisagecontrastsfsl')
% 
% dlmwrite('agedesign',agedesign,'delimiter',' ')
% dlmwrite('agecontrasts',agecontrasts,'delimiter',' ')
% 
% system('Text2Vest agedesign agedesignfsl')
% system('Text2Vest agecontrasts agecontrastsfsl')
% 


%% now for group differences

mytbssdir = '/Users/kelly/cueexp/data/mytbss';
cd(mytbssdir)
cd stats 
cd designcontrastfiles/


subs0=getCueSubjects('dti',0); 
subs1=getCueSubjects('dti',1); 


% sort alphabetically
[subs0,~]=sort(subs0); 
[subs1,~]=sort(subs1); 

% concatenate whole subject list
subs=[subs0;subs1];
n = numel(subs); 


age=getCueData(subs,'age')
age0=age(1:numel(subs0)); age0=age0-mean(age0);
age1=age(numel(subs0)+1:end); age1=age1-mean(age1);
age=age-mean(age);


mot=getCueData(subs,'dwimotion')
mot0=mot(1:numel(subs0)); mot0=mot0-mean(mot0);
mot1=mot(numel(subs0)+1:end); mot1=mot1-mean(mot1);
mot=mot-mean(mot);

bis=getCueData(subs,'bis');
bis0=bis(1:numel(subs0)); bis0=bis0-mean(bis0);
bis1=bis(numel(subs0)+1:end); bis1=bis1-mean(bis1);
bis=bis-mean(bis);


%%

% two columns for the two groups (1 or 0 indicator for group)
EVgroup = zeros(n,2); 
EVgroup(1:numel(subs0),1)=1;
EVgroup(numel(subs0)+1:end,2)=1;

%%%%%%%% group design and contrasts with CV age 

designname = 'design_cvage';
contrastname = 'contrasts_cvage';

des =[EVgroup age]; 

con = [
    1 -1 0;
    -1 1 0;
    0 0 1;
    0 0 -1];

dlmwrite(designname,des,'delimiter',' ')
dlmwrite(contrastname,con,'delimiter',' ')

system(['Text2Vest ' designname ' ' designname '_fsl'])
system(['Text2Vest ' contrastname ' ' contrastname '_fsl'])

%%%%%%%% group design and contrasts with CV age and motion

designname = 'design_cvagemot';
contrastname = 'contrasts_cvagemot';

des =[EVgroup age mot]; 

con = [
    1 -1 0 0;
    -1 1 0 0;
    0 0 1 0;
    0 0 -1 0
    0 0 0 1;
    0 0 0 -1];

dlmwrite(designname,des,'delimiter',' ')
dlmwrite(contrastname,con,'delimiter',' ')

system(['Text2Vest ' designname ' ' designname '_fsl'])
system(['Text2Vest ' contrastname ' ' contrastname '_fsl'])


%%%%%%%% group design and contrasts with CV age and motion, looking at the
%%%%%%%% correlation of BIS

designname = 'design_bisbygroup_cvagemot';
contrastname = 'contrasts_bisbygroup_cvagemot';

EVbis = zeros(n,2);
EVbis(1:numel(subs0),1)=bis0;
EVbis(numel(subs0)+1:end,2)=bis1;

des =[EVgroup EVbis age mot]; 

con = [
    1 -1 0 0 0 0;
    -1 1 0 0 0 0;
    0 0 1 0 0 0;
    0 0 -1 0 0 0;
    0 0 0 1 0 0;
    0 0 0 -1 0 0;
    0 0 0 0 1 0;
    0 0 0 0 -1 0;
    0 0 0 0 0 1;
    0 0 0 0 0 -1
    ];

dlmwrite(designname,des,'delimiter',' ')
dlmwrite(contrastname,con,'delimiter',' ')

system(['Text2Vest ' designname ' ' designname '_fsl'])
system(['Text2Vest ' contrastname ' ' contrastname '_fsl'])



%%%%%%%% group design and contrasts with CV age and motion

designname = 'design_bis_cvagemot';
contrastname = 'contrasts_bis_cvagemot';

des =[EVgroup bis age mot]; 

con = [
    1 -1 0 0 0;
    -1 1 0 0 0;
    0 0 1 0 0;
    0 0 -1 0 0
    0 0 0 1 0;
    0 0 0 -1 0; 
    0 0 0 0 1;
    0 0 0 0 -1 
    ];

dlmwrite(designname,des,'delimiter',' ')
dlmwrite(contrastname,con,'delimiter',' ')

system(['Text2Vest ' designname ' ' designname '_fsl'])
system(['Text2Vest ' contrastname ' ' contrastname '_fsl'])


% two columns for the two groups (1 or 0 indicator for group)
EVgroup = zeros(n,2); 
EVgroup(1:numel(subs0),1)=1;
EVgroup(numel(subs0)+1:end,2)=1;


%%%%%%%% CONTROLS design and contrasts with CV age 

designname = 'design_controls_bis_cvagemot';
contrastname = 'contrasts_controls_bis_cvagemot';

des =[EVgroup(:,1) [bis0;zeros(numel(bis1),1)] [age0;zeros(numel(age1),1)]  [mot0;zeros(numel(mot1),1)] ];

con = [
    1 0 0 0;
    0 1 0 0;
    0 -1 0 0;
    0 1 0 0;
    0 -1 0 0;
    ];

dlmwrite(designname,des,'delimiter',' ')
dlmwrite(contrastname,con,'delimiter',' ')

system(['Text2Vest ' designname ' ' designname '_fsl'])
system(['Text2Vest ' contrastname ' ' contrastname '_fsl'])


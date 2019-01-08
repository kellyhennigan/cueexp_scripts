% script to determine the spatial organization of fiber groups projecting
% to/from the midbrain.

clear all
close all

p=getCuePaths();
dataDir = p.data;


cd /Users/kelly/cueexp/data/fg_densities/mrtrix_fa


% fibers directory relative to subject dir
inDir = fullfile(dataDir,'fg_densities','mrtrix_fa');

seed = 'DA';

targets = {'nacc','caudate','putamen'};

CoMFileStrs = {[seed '%s_%s%s_belowAC_dil2_CoM_tlrc.txt'];
    [seed '%s_%s%s_dil2_CoM_tlrc.txt'];
    [seed '%s_%s%s_dil2_CoM_tlrc.txt']}; % %s's are: L/R, target, L/R

LorR = ['L','R']; % if ['L','R'], script shold loop over l/r sides;


%%

lr='L'
% for lr=LorR
    
    for j=1:numel(targets)
        
        T=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},lr,targets{j},lr)));
        
        % make sure the CoM files have the same subjects in the same order
        if j==1
            subjects=table2array(T(:,1));
        else
            if ~isequal(T.Var1,subjects)
                error('hold up - the subjects in the center of mass files arent the same!')
            end
        end
        CoM{j}=table2array(T(:,2:4));
        x(:,j)=CoM{j}(:,1); y(:,j)=CoM{j}(:,2); z(:,j)=CoM{j}(:,3);
    end
    
    fprintf('\n\n%%%%%%%%% %s SIDE: %%%%%%%%%%%%%\n\n',lr)
     
    %% test medial-lateral gradient
    
    teststr = 'medial';
    
    ti=[1 2];
    res=[abs(x(:,ti(1)))<abs(x(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    ti=[1 3];
    res=[abs(x(:,ti(1)))<abs(x(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    ti=[2 3];
    res=[abs(x(:,ti(1)))<abs(x(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    
    %% test anterior-posterior gradient
    
    teststr = 'anterior';
    
    ti=[1 2];
    res=[abs(y(:,ti(1)))<abs(y(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    ti=[1 3];
    res=[abs(y(:,ti(1)))<abs(y(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    ti=[2 3];
    res=[abs(y(:,ti(1)))<abs(y(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    
    
    %% test interior-superior gradient
    
    teststr = 'inferior';
    
    ti=[1 2];
    res=[abs(z(:,ti(1)))<abs(z(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    ti=[1 3];
    res=[abs(z(:,ti(1)))<abs(z(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    ti=[2 3];
    res=[abs(z(:,ti(1)))<abs(z(:,ti(2)))];
    fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
        'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    
%%
    %%%%
%   when left and right CoM coords were averaged:
%%%%
% for 40 out of 40 subjects, DA endpoints for 
% nacc pathways are more medial than caudate pathways
% 
% for 40 out of 40 subjects, DA endpoints for 
% nacc pathways are more medial than putamen pathways
% 
% for 31 out of 40 subjects, DA endpoints for 
% caudate pathways are more medial than putamen pathways
% 
% for 37 out of 40 subjects, DA endpoints for 
% nacc pathways are more anterior than caudate pathways
% 
% for 38 out of 40 subjects, DA endpoints for 
% nacc pathways are more anterior than putamen pathways
% 
% for 23 out of 40 subjects, DA endpoints for 
% caudate pathways are more anterior than putamen pathways
% 
% for 17 out of 40 subjects, DA endpoints for 
% nacc pathways are more inferior than caudate pathways
% 
% for 27 out of 40 subjects, DA endpoints for 
% nacc pathways are more inferior than putamen pathways
% 
% for 31 out of 40 subjects, DA endpoints for 
% caudate pathways are more inferior than putamen pathways  

    
    
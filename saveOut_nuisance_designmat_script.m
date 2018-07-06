% script to regress out nuisance regressors and save out the err ts

clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects(task);
% subjects = {'jh160702'};

 afniStr = '_afni'; % '_afni' to use afni xform version, '' to use ants version
% afniStr = ''; % '_afni' to use afni xform version, '' to use ants version

% define file path to nuisance regressors

nDPolyRegs=2; % number of degrees of polynomial baseline regressors

nuisance_regfiles{1} = fullfile(dataDir,'%s','func_proc',[task '_vr.1D']);
nuisance_regidx{1} = [2:7]; % column index for which vectors to use within each regfile
nuisance_regfiles{2} = fullfile(dataDir,'%s','func_proc',[task '_csf' afniStr '.1D']);
nuisance_regidx{2} = 1; 
nuisance_regfiles{3} = fullfile(dataDir,'%s','func_proc',[task '_wm' afniStr '.1D']);
nuisance_regidx{3} = 1; 


regNames = {'poly0','poly1','poly2','dx','dy','dz','roll','pitch','yaw','csf','wm'};

outFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc' afniStr '_nuisance_designmat']);

nTRs=436;


%% do it



i=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
        
        baseregs=modelBaseline(nTRs,nDPolyRegs);
        for n=1:numel(nuisance_regfiles)
            temp = dlmread(sprintf(nuisance_regfiles{n},subject));
            baseregs = [baseregs, temp(:,nuisance_regidx{n})];
        end
        
        % define design matrix w/intercept and nuisance regs
        baseregs = array2table(baseregs,'VariableNames',regNames);
        
        writetable(baseregs,sprintf(outFilePath,subject));
        
        fprintf('done.\n\n');
    
end % subjects


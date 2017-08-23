% script to save out design matrix of baseline regressors; currently meant
% to be used for regressing out noise prior to conducting functional
% connectivity analyses.


clear all
close all

%% define relevant variables, paths, etc.

task = 'cue';

[p,task,subjects,gi]=whichCueSubjects('stim',task)

dataDir = p.data;


afniStr = '_afni';


regLabels = [];

% define regressors to be included in baseline design matrix
regfiles{1} = fullfile(dataDir,'%s','func_proc',[task '_vr.1D']);
regidx{1} = [2:7];
regLabels = [regLabels {'roll','pitch','yaw','dS','dL','dP'}];

regfiles{2} = fullfile(dataDir,'%s','func_proc',[task '_csf' afniStr '.1D']);
regidx{2} = 1;
regLabels = [regLabels {'csf'}];

regfiles{3} = fullfile(dataDir,'%s','func_proc',[task '_wm' afniStr '.1D']);
regidx{3} = 1;
regLabels = [regLabels {'wm'}];


% polynomial degrees for modeling baseline -
%  e.g., 2 means modeling constant, linear and quadratic drift
nPolyDeg = 2;
baseLabels = [];
for p=0:nPolyDeg
    baseLabels = [baseLabels {['polybase' num2str(p)]}];
end


% combine all regLabels for saving out
regLabels = [baseLabels regLabels];

% name for out file
outPath = fullfile(dataDir,'%s','func_proc',[task '_nuisance_regs']);


%% do it

i=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...']);
    
    % get nuisance regressors
    X = [];
    for j=1:numel(regfiles)
        
        this_reg = dlmread(sprintf(regfiles{j},subject));
        X = [X this_reg(:,regidx{j})];
        
    end
    
    % define some baseline regs & add them to the design matrix
    Xbase = modelBaseline(size(X,1),nPolyDeg);
    X = [Xbase X];
    
    % convert to table format
    X = array2table(X,'VariableNames',regLabels);
    
    % save it
    writetable(X,sprintf(outPath,subject));
    
    fprintf('done.\n\n');
    
end % subjects



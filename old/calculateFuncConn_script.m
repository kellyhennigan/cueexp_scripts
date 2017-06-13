% script to calculate functional connectivity between 2 ROIs


clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects(task);

% file path to onset time files (1st %s is subject and 2nd %s is stimNames)
stims = {'drugs','food','neutral'};

seedRoiName = 'nacc_desai';

roiNames = {'LC','acing','csf','caudate','amyg','mpfc','ins_desai','dlpfc','PVT','wm','VTA'};


% name of dir to save to where %s is task
inFile = fullfile(dataDir,'%s','single_trial_cue_timecourses','%s','%s'); 

TRi = 4:7; % index of which TR to extract (TR1 is at trial onset, etc.)
TR = 2; % 2 sec TR
ti = (TRi-1).*TR; % time at the indexed TR


%% do it

i=1; j=1; k=1;
for i=1:numel(subjects); % subject loop
       
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    for k = 1:numel(stims)
        
        % load in seed timecourses for this stim
        seed = dlmread(sprintf(inFile,subject,seedRoiName,stims{k})); seed = mean(seed(:,TRi),2);
        
        for j=1:numel(roiNames)
            
            % load in roi timecourses for this stim
            roi = dlmread(sprintf(inFile,subject,roiNames{j},stims{k})); roi = mean(roi(:,TRi),2);
            
            % correlate per-trial seed-roi activity
            r{j}(i,k) = corr(seed,roi); 
            
        end
        
    end
end
       
% Fisher  transform the correlation coefficients
Z = cellfun(@(x) .5.*log((1+x)./(1-x)),r,'uniformoutput',0);

    
%% rearrange by group and plot 

groupNames = {'controls','patients'};
plotSig = [1 1];
cols=getCueExpColors(numel(groupNames));
saveDir = fullfile(p.figures,'func_conn');
    
    
j=1;
for j=1:numel(roiNames)
    
    d{1}=Z{j}(gi==0,:); % Z scores for controls correlations
    d{2}=Z{j}(gi==1,:); % " " for patients
    
    dName=[seedRoiName '-' roiNames{j} '_TRs' sprintf(repmat('%d',1,numel(TRi)),TRi)];
    
    savePath = fullfile(saveDir,dName); 
    
    [fig,leg] = plotNiceBars(d,dName,stims,groupNames,cols,plotSig,savePath);
    
end


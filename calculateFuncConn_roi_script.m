% script to calculate functional connectivity between a seed and other ROIs
% to run this script, "saveRoiTimeCourses_signletrial_script" should be run
% first so that roi estimates of single trial activity are saved out.


clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects(task);

% file path to onset time files (1st %s is subject and 2nd %s is stimNames)
stims = {'food'};

seedRoiName = 'nacc_desai';

% roiNames = {'LC','acing','csf','caudate','amyg','mpfc','ins_desai','dlpfc','PVT','wm','VTA'};
% roiNames = {'acing','caudate','clust_caudR','csf','dlpfc','mpfc','ins_desai','dlpfc','VTA','wm'};
roiNames = {'dlpfc','vlpfc'};

% name of dir to save to where %s is: subject, roi, stim
inFile = fullfile(dataDir,'%s',['single_trial_' task '_timecourses'],'%s','%s'); 

% TRi = 4:7; % index of which TR to extract (TR1 is at trial onset, etc.)
TRi = 4; % index of which TR to extract (TR1 is at trial onset, etc.)
TR = 2; % 2 sec TR
ti = (TRi-1).*TR; % time at the indexed TR

% figure to save out plots to 
saveDir = fullfile(p.figures,'selfreport_brain_corr',seedRoiName);
% saveDir = fullfile(p.figures,'func_conn',seedRoiName);
if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

%% do it

i=1; j=1; k=1;
for i=1:numel(subjects)  % subject loop
       
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
    
    
j=1;
for j=1:numel(roiNames)
    
    d{1}=Z{j}(gi==0,:); % Z scores for controls correlations
    d{2}=Z{j}(gi==1,:); % " " for patients
    
    dName=['Z-transformed corr coefficients'];
   
    titleStr = [strrep(seedRoiName,'_','') '-' roiNames{j} ' func connectivity; TRs ' sprintf(repmat('%d',1,numel(TRi)),TRi)];
    
    savePath = fullfile(saveDir,[roiNames{j} '_TRs' sprintf(repmat('%d',1,numel(TRi)),TRi)]); 
    
    [fig,leg] = plotNiceBars(d,dName,stims,groupNames,cols,plotSig,titleStr,1,savePath,0);
    
    
end


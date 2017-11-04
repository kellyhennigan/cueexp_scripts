% script to calculate correlation some self-report/behavioral measure and
% brain activity from an ROI on a trial by trial basis

% to run this script, "saveRoiTimeCourses_signletrial_script" should be run
% first so that roi estimates of single trial activity are saved out.


clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects(task);

% stim name
stims = {'stim','drugs','food','neutral'};

%%%%%%%%%%%%%% behavioral/self-report data
behDataName = ['pa_%s_trials']; % name of data for getCueData()
behDataLabel = ['pa_%s']; % name for output


%%%%% omit subs? 
omit_subs={'nd150921','ds170728','rc170730'};
idx=ismember(subjects,omit_subs);
subjects(idx)=[]; gi(idx)=[];


%%%%%%%%%%%%%% brain data
seedRoiName = 'nacc_desai';

% name of dir to save to where %s is: subject, roi, stim
inFile = fullfile(dataDir,'%s',['single_trial_' task '_timecourses'],'%s','%s');

% TRi = 4:7; % index of which TR to extract (TR1 is at trial onset, etc.)
TRi = 4; % index of which TR to extract (TR1 is at trial onset, etc.)
TR = 2; % 2 sec TR
ti = (TRi-1).*TR; % time at the indexed TR



% figure to save out plots to
saveDir = fullfile(p.figures,'brain_sr_corr',seedRoiName);
% saveDir = fullfile(p.figures,'func_conn',seedRoiName);
if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

%% do it



k=1;
for k=1:numel(stims)

% behavior/self-report measure
behData = getCueData(subjects,sprintf(behDataName,stims{k}));

i=1;
for i=1:numel(subjects)  % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    %     for k = 1:numel(stims)
    
    % this subject's brain data
    seed = dlmread(sprintf(inFile,subject,seedRoiName,stims{k})); seed = mean(seed(:,TRi),2);
    
    % this subjects behavior/self-report data
    beh = behData(i,:)';
    
    % correlate per-trial brain-behavior activity
    r(i,k) = corr(seed,beh);
    
    
end

end % stims

% Fisher  transform the correlation coefficients
% Z = cellfun(@(x) .5.*log((1+x)./(1-x)),r,'uniformoutput',0);
Z = .5.*log((1+r)./(1-r));

%% rearrange by group and plot

groupNames = {'controls','patients'};
plotSig = [1 1];
cols=getCueExpColors(numel(groupNames));


d{1}=Z(gi==0,:); % Z scores for controls correlations
d{2}=Z(gi==1,:); % " " for patients

dName=['Z-transformed corr coefficients'];

titleStr = [strrep(seedRoiName,'_','') '-' sprintf(behDataLabel,stims{k}) ' correlation; TRs ' sprintf(repmat('%d',1,numel(TRi)),TRi)];

savePath = fullfile(saveDir,[sprintf(behDataLabel,stims{k}) '_TRs' sprintf(repmat('%d',1,numel(TRi)),TRi)]);

[fig,leg] = plotNiceBars(d,dName,stims,groupNames,cols,plotSig,titleStr,1,savePath,0);

    


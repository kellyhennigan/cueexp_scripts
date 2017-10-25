% script to save out roi time courses. This script does the following:

% load event onset files: each file should be a text file with a column
% vector of 0s and 1s to signify an event onset. Length of the vector should be
% equal to the # of acquired TRs.

% load roi binary mask files: volumes w/value of 1 signifying which voxels
% are in the roi mask; otherwise 0 values

% load pre-processed functional data & get averaged roi time courses

% get stim-locked time series based on event onset files

% plot each trial separately (this should be noisy but potentially useful
% for diagnosing movement, something weird, etc.)

% for each subject, for each roi, for each event type, get the average time
% course & save out in text file


clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task = 'cue';

[subjects,gi]=getCueSubjects('cue');
subjects={'jh160702'};

 afniStr = '_afni';
% afniStr = ''; % to use ants version

% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir, ['%s/func_proc/pp_' task '_tlrc' afniStr '.nii.gz']);



% file path to onset time files (1st %s is subject and 2nd %s is stimNames)
stims = {'drugs','food','neutral'};
stimFilePath = fullfile(dataDir,'%s','regs','%s_cue_cue.1D');

% roi directory
roiDir = fullfile(dataDir,'ROIs');

% get list of rois to potentially process
a=dir([roiDir '/*_func.nii']);
allRoiNames = cellfun(@(x) strrep(x,'_func.nii',''), {a(:).name},'uniformoutput',0);
disp(allRoiNames');
fprintf('\nwhich ROIs to process? \n');
roiNames = input('enter roi name(s), or hit return for all ROIs above: ','s');
if isempty(roiNames)
    roiNames = allRoiNames;
else
    roiNames = splitstring(roiNames);
end

% name of dir to save to;  %s is task and then roiName
outDir = fullfile(dataDir,'%s/single_trial_cue_timecourses/%s');

nTRs = 8; % # of TRs to extract
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot


%% do it

% get roi masks
roiFiles = cellfun(@(x) [x '_func.nii'], roiNames,'UniformOutput',0);
rois = cellfun(@(x) niftiRead(fullfile(roiDir,x)), roiFiles,'uniformoutput',0);


i=1;
for i=1:numel(subjects); % subject loop
    
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
    
    j=1;
    for j=1:numel(rois)
        
        % create out directory if it doesn't already exist
        thisOutDir = sprintf(outDir,subject,roiNames{j});
        if ~exist(thisOutDir,'dir')
            mkdir(thisOutDir);
        end
        
        % this roi time series
        roi_ts = roi_mean_ts(func.data,rois{j}.data);
        
        
        % nan pad the end in case there aren't enough TRs for the last
        % trial
        roi_ts = [roi_ts;nan(nTRs,1)];
        
        
        for k=1:numel(stims)
            
            
            % get stim onset times
            onsetTRs = find(dlmread(sprintf(stimFilePath,subject,stims{k})));
            
            % get array of indices of which TRs to get data for
            this_stim_TRs = repmat(onsetTRs,1,nTRs)+repmat(0:nTRs-1,numel(onsetTRs),1);
            
            % single trial time courses for this stim
            this_stim_tc=roi_ts(this_stim_TRs);
            
            dlmwrite(fullfile(thisOutDir,stims{k}),this_stim_tc)
            
        end % stims
        
    end % rois
    
end % subjects

    %      system(sprintf('3dbucket -prefix %s -fbuc %s',outNameStr,[outNameStr,'.nii.gz']));
    %     system(sprintf('3drefit -view ''tlrc'' %s+orig.',outNameStr));
    %     system(sprintf('3drefit -sublabel 0 %s -sublabel 1 %s -substatpar 1 fitt %d %s+tlrc.',...
    %         ['mean_',outNameStr],['Tstat_',outNameStr],N-1,outNameStr));




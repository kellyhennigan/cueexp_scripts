
% script to extract time courses averaged across ROIs. ROIs are defined
% from binary masks that are in the same space as functional data.

% load onset files and get indices of volumes to extract

% load roi time course (from mask or 1d file)

% get stim-locked time series

% plot each trial separately (this should be noisy but potentially useful
% for diagnosing movement, something weird, etc.)

% take mean time series for that roi for all subjects




%%
% clear all
% close all


%%%%%%%%%%%%%%   define relevant variables and filepaths  %%%%%%%%%%%%%%%%% 
% subjects = getCueSubjects();
subjects = getCueSubjects(1);

subjectStr = 'patients'; %controls, patients, or all



% filepath to pre-processed functional data where %s is subject
baseDir = getCueBaseDir;
funcFilePath = fullfile(baseDir,'data','%s','func_proc_cue','cue_mbnf.nii');




% directory w/regressor time series (NOT convolved)
% regs cell array lists all the stim times to plot
stimDir =  '/Users/Kelly/cueexp/data/%s/regs';

stimFiles =  {'cue_strong_dontwant.1D',...
    'cue_somewhat_dontwant.1D',...
    'cue_somewhat_want.1D',...
    'cue_strong_want.1D',...
    'cue_alcohol.1D',...
    'cue_drugs.1D',...
    'cue_food.1D',...
    'cue_neutral.1D'};
    
stimStrs =  {'strong_dontwant',...
    'somewhat_dontwant',...
    'somewhat_want',...
    'strong_want',...
    'alcohol',...
    'drugs',...
    'food',...
    'neutral'};
% 
%%%%%%%% to look at individual trials for identifying spikes:
% stimFiles =  {'cue.1D'};
% stimStrs =  {'cue'};



% roi directory
roiDir = '/Users/Kelly/cueexp/data/ROIs';
roiFiles = {'nacc8mm_func.nii.gz',...
    'acing_func.nii.gz',...
    'dlpfc_func.nii.gz',...
    'mpfc_func.nii.gz',...
    'caudate_func.nii.gz',...
    'ins_func.nii.gz'};
roiStrs = {'nacc','ac','dlpfc','mpfc','caudate','insula'};

% roiFiles = {'nacc_func.nii'};
% roiStrs = {'nacc'};


nTRs = 12; % # of TRs to extract

outDir = fullfile(baseDir,'data','timecourses');

TS = cell(numel(roiStrs),numel(stimStrs)); % out data cell array

saveOut = 1; % 1 to save out time courses, otherwise 0

%% do it

rois = cellfun(@(x) niftiRead(fullfile(roiDir,x)), roiFiles,'uniformoutput',0);

for i=1:numel(subjects); % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
    % get roi time series
    roi_ts = cellfun(@(x) roi_mean_ts(func.data,single(x.data)), rois, 'uniformoutput',0);
    
    % nan pad the end of the time series for the case of the last trial
    roi_ts = cellfun(@(x) [x;nan(nTRs,1)], roi_ts, 'uniformoutput',0);
    
    % get stim onset times
    onsetTRs = cellfun(@(x) find(dlmread(fullfile(sprintf(stimDir,subject),x))), stimFiles, 'uniformoutput',0);
    
    for j=1:numel(roiStrs)
        
        for k=1:numel(stimStrs)
            
            % get each trial of stim-locked roi time series for this subject
            this_stim_ts = [];
            
            if ~isempty(onsetTRs{k})
                for n=1:numel(onsetTRs{k})
                    this_stim_ts(n,:) = roi_ts{j}(onsetTRs{k}(n):onsetTRs{k}(n)+nTRs-1);
                end
                TS{j,k}(i,:) = nanmean(this_stim_ts);
            else
                TS{j,k}(i,:) = nan(1,nTRs);
            end
            
            %             plot individual trials - prob only useful for diagnosing weird time
%             %             points due to movement or scanner hardware
            figure
            set(gca,'fontName','Arial','fontSize',12)
            plot(this_stim_ts','linewidth',1.5)
            xlabel('TR')
            ylabel('% BOLD change')
            set(gca,'box','off');
            set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
            colormap(solarizedColors)
            title([subject ' ' roiStrs{j} ' ' stimStrs{k}])
            
% %             take the average across trials for this subject
            
            
        end % stims
        
    end % rois
    
end % subject loop


%%  save out time courses

if saveOut
    for j=1:numel(roiStrs)
        
        % roi specific directory
        thisOutDir = fullfile(outDir,roiStrs{j});
        if ~exist(thisOutDir,'dir')
            mkdir(thisOutDir);
        end
        
        for k=1:numel(stimStrs)
            dlmwrite(fullfile(thisOutDir,[stimStrs{k} '_' subjectStr]),TS{j,k});
        end
    end
end












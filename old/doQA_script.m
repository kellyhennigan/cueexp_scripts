
%%%%%%%% do QA on motion on data from cue fmri experiment

clear all
close all

p = getCuePaths();
dataDir = p.data;

task = input('cue, mid, midi, or dti (or just hit return for no task)? ','s');

[subjects,gi]=getCueSubjects('');
% subjects = {'ps160508'};

doSubjPlots = input('plot & save out SINGLE SUBJECT QA plots? (1=yes 0=no) ');

doGroupPlot = input('plot & save out GROUP QA plot? (1=yes 0=no) ');

figDir = fullfile(p.figures,'QA',task);


%% 

% define file with task motion params based on task
switch task
    
    case 'dti'
        
        mp_file = [dataDir '/%s/dti96trilin/dwi_aligned_trilin_ecXform.mat']; % func data dir, %s is subject id
        
        vox_mm = 2; % dti voxel dimensions are 2mm isotropic
        
        en_thresh = 5; % euclidean norm threshold for calling a TR "bad"
        
        % what percentage of bad volumes should lead to excluding a subject for
        % motion?
        percent_bad_thresh = .9;
        
        roi_str = 'wmMask';
        roits_file = [dataDir '/%s/dti96trilin/' roi_str '_ts'];
        
    otherwise % for fmri tasks
        
        mp_file = [dataDir '/%s/func_proc/' task '_vr.1D']; % motion param file where %s is task
        
        en_thresh = 1;
        percent_bad_thresh = 1;
        
        roi_str = 'nacc_afni';
        roits_file = [dataDir '/%s/func_proc/' task '_' roi_str '.1D']; % roi time series file to plot where %s is task
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(figDir,'dir') && savePlots
    mkdir(figDir);
end

nBad = []; % vector noting the # of bad volumes for each subject
omit_idx = []; % 1 if receommended to omit a subject, otherwise 0

for s = 1:numel(subjects)
    
    subject = subjects{s};
    fprintf(['\nworking on subject ' subject '...\n\n']);
    
    mp = []; % this subject's motion params
    
    % get task motion params
    switch task
        
        case 'dti'
            
            try
                load(sprintf(mp_file,subject)); % loads a structural array, "xform"
                mp=vertcat(xform(:).ecParams);
                mp = mp(:,[1:3 5 4 6]); % rearrange to be in order dx,dy,dz,roll,pitch,yaw
                mp(:,1:3) = mp(:,1:3).*vox_mm; % change displacement to be in units of mm
                mp(:,4:6) = mp(:,4:6)/(2*pi)*360; % convert rotations to units of degrees
            catch
                warning(['couldnt get motion params for subject ' subject ', so skipping...'])
            end
            
        otherwise  % for fmri tasks
            
            try
                mp = dlmread(sprintf(mp_file,subject));
                mp = mp(:,[6 7 5 2:4]); % rearrange to be in order dx,dy,dz,roll,pitch,yaw
            catch
                 warning(['couldnt get motion params for subject ' subject ', so skipping...'])
            end
    end
    
    if isempty(mp)
        max_en(s,1)=nan; max_TR(s,1)=nan; nBad(s,1)=nan; omit_idx(s,1)=nan;
    else
        
        % plot motion params, if desired
        if doSubjPlots
            fig = plotMotionParams(mp);
            outName = [subject '_mp'];
            print(gcf,'-dpng','-r300',fullfile(figDir,outName));
        end
        
        
        % calculate euclidean norm (head motion distance roughly in mm units)
        en = [0;sqrt(sum(diff(mp).^2,2))];
        
        
        % determine this subject's max movement
        [max_en(s,1),max_TR(s,1)]=max(en);
        
        
        % calculate # of bad images based on en_thresh
        nBad(s,1) = numel(find(en>en_thresh));
        fprintf('\n%s has %d bad image, which is %.2f percent of %s vols\n\n',...
            subject,nBad(s),100.*nBad(s,1)/numel(en),task);
        
        
        % determine whether to omit subject or not, based on percent_bad_thresh
        if 100.*nBad(s)/numel(en)>percent_bad_thresh
            omit_idx(s,1) = 1;
        else
            omit_idx(s,1) = 0;
        end
        
        
        % plot, if desired
        if doSubjPlots
            
            if ~isempty(roits_file)
                ts = dlmread(sprintf(roits_file,subject));
            else
                ts = ''; roi_str = '';
            end
            
            fig = plotEnMotionThresh(en,en_thresh,ts,roi_str);
            
            % if a time series is plotted for diffusion data, ignore the b0 volumes
            % (it messes up the plot scale)
            if strcmp(task,'dti')
                subplot(2,1,2)
                ylim([min(ts)-1 max(ts(10:end))+1])
            end
            
            outName = [subject '_mp2'];
            
            print(gcf,'-dpng','-r300',fullfile(figDir,outName));
            
            
        end % doSubjPlots
        
    end % isempty(mp)
    
end % subjects



%% plot histogram of bad volume count

fig=setupFig;
hist(nBad,numel(subjects));

xlabel(['# of TRs with head movement > euc dist of ' num2str(en_thresh)])
ylabel('# of subjects')
title(['head movement during ' task ' task'])

if doGroupPlot
    print(gcf,'-dpng','-r300',fullfile(figDir,['subj hist of head movement during ' task ' task']));
end

%% calculate tSNR

%% show where censored TRs are



%%
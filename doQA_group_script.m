
%%%%%%%% do QA on motion on data from cue fmri experiment

clear all
close all

p = getCuePaths();
dataDir = p.data;

task = input('cue, mid, midi, or dti (or just hit return for no task)? ','s');

[subjects,gi]=getCueSubjects('');

% % temporarily omit subs without MFB tracts
% oidx=[   15
%     25
%     28
%     79
%     93
%    112
%    126
%    128];
% subjects(oidx)=[];
% gi(oidx)=[];

savePlots = 1; % 1 to save plots, otherwise 0

figDir = fullfile(p.figures,'QA',task);

motion_metric = 'euclideannorm';
% motion_metric = 'displacement';
% motion_metric = 'fwdisplacement';

%%

% define file with task motion params based on task
switch task
    
    case 'dti'
        
        mp_file = [dataDir '/%s/dti96trilin/dwi_aligned_trilin_ecXform.mat']; % func data dir, %s is subject id
        
        vox_mm = 2; % dti voxel dimensions are 2mm isotropic
        
        thresh = [2 3 4]; % threshold for calling a TR "bad"
        
        % what percentage of bad volumes should lead to excluding a subject for
        % motion?
        percent_bad_thresh = [5 5 5];
        
        mean_thresh = 2; % threshold for determining who to exclude based on mean vol-to-vol motion
        
    otherwise % for fmri tasks
        
        mp_file = [dataDir '/%s/func_proc/' task '_vr.1D']; % motion param file where %s is task
        
        %         thresh = [.5 1 2];
        %         percent_bad_thresh = [5 1 .5];
        %
        %         mean_thresh = .5; % threshold for determining who to exclude based on mean vol-to-vol motion
        thresh = [.5 .5 .5];
        percent_bad_thresh = [5 3 2];
        
        mean_thresh = .5; % threshold for determining who to exclude based on mean vol-to-vol motion
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(figDir,'dir') && savePlots
    mkdir(figDir);
end

% define vectors and matrices to be filled in
max_motion = nan(numel(subjects),1); % max movement from 1 vol to the next
max_TR = nan(numel(subjects),1); % TR w/max movement
mean_motion = nan(numel(subjects),1); % mean vol-to-vol motion
nBad = nan(numel(subjects),numel(thresh)); % # of vols w/movement > thresh
omit_idx = nan(numel(subjects),numel(thresh)); % 1 to suggest omitting, otherwise 0


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
            
              % mid and midi have 2 runs that are concatenated;
        % use this variable to index which volume # is the first
        % vol of the 2nd run so that it's motion can be assigned to 0
        if strcmp(task,'mid')
            run2vol1idx=257;
        elseif strcmp(task,'midi')
            run2vol1idx=293;
        end
        
    end
    
    if ~isempty(mp)
        
        switch motion_metric
            
            case 'euclideannorm'
                
                m = computeAfniEuclideanNorm(mp); 
                
            case 'displacement'
                
                m = computeHeadDisplacement(mp(:,1:3)); 
                
            case 'fwdisplacement'
                
                m = computeFrameWiseHeadDisplacement(mp);
                
        end
        
         if exist('run2vol1idx','var')
             m(run2vol1idx)=0; % there's no "motion" in the 1st vol of the 2nd run; correctly assign motion to 0
         end
         
        % determine this subject's max movement
        [max_motion(s,1),max_TR(s,1)]=max(m);
        mean_motion(s,1)=mean(m);
        
        for i=1:numel(thresh)
            
            % calculate # of bad vols based on thresh
            nBad(s,i) = numel(find(m>thresh(i)));
            
            fprintf('\n%s has %d vols with motion > %.1f, which is %.2f percent of %s vols\n\n',...
                subject,nBad(s,i),thresh(i),100.*nBad(s,i)/numel(m),task);
            
            
            % determine whether to omit subject or not, based on
            % percent_bad_thresh and mean motion
            if 100.*nBad(s,i)/numel(m)>percent_bad_thresh(i) || mean_motion(s) > mean_thresh
                omit_idx(s,i) = 1;
            else
                omit_idx(s,i) = 0;
            end
            
        end
        
    end % isempty(mp)
    
end % subjects



%% plot histogram of bad volume count

for i=1:numel(thresh)
    
    fig=setupFig;
    hist(nBad(:,i),numel(subjects));
    
    xlabel(['# of TRs with head movement > euc dist of ' num2str(thresh(i))])
    ylabel('# of subjects')
    title(['head movement during ' task ' task'])
    
    hold on
    yl=ylim;
    h2=plot([floor(numel(m).*percent_bad_thresh(i)./100) floor(numel(m).*percent_bad_thresh(i)./100)],[yl(1) yl(2)],'k--');
    
    legend(h2,{['percent bad thresh=' num2str(percent_bad_thresh(i))]})
    legend('boxoff')
    
    if savePlots
        figPath = fullfile(figDir,['subj_hist_thresh' num2str(thresh(i)) '.png']);
        print(gcf,'-dpng','-r300',figPath)
    end
    
end

% plot histogram showing mean motion metric

fig=setupFig;
hist(mean_motion,numel(subjects));

xlabel(['mean vol-to-vol motion (' motion_metric ')'])
ylabel('# of subjects')
title(['mean ' motion_metric ' during ' task ' task'])

if savePlots
    figPath = fullfile(figDir,['subj_hist_mean_' motion_metric '.png']);
    print(gcf,'-dpng','-r300',figPath)
end


%% calculate tSNR

%% show where censored TRs are



%%
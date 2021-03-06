
%%%%%%%% do QA on motion on data from cue fmri experiment

clear all
close all

p=getCuePaths();
task=whichCueTask(); 

task_subjects = getCueSubjects('');
fprintf('\n');
subj_list=cellfun(@(x) [x ' '], task_subjects, 'UniformOutput',0)';
disp([subj_list{:}]);
fprintf('\nwhich subjects to process? \n');
subjects = input('enter sub ids, or hit return for all subs above: ','s');
if isempty(subjects)
    subjects = task_subjects;
else
    subjects = splitstring(subjects)';
end

dataDir = p.data;

figDir = fullfile(p.figures,'QA',task);

savePlots = 1; % 1 to save plots, otherwise 0

motion_metric = 'euclideannorm'; 
% motion_metric = 'displacement'; 
% motion_metric = 'fwdisplacement'; 

%%

% define file with task motion params based on task
switch task
    
    case 'dti'
        
        mp_file = [dataDir '/%s/dti96trilin/dwi_aligned_trilin_ecXform.mat']; % func data dir, %s is subject id
        
        vox_mm = 2; % dti voxel dimensions are 2mm isotropic
        
        thresh = 3; % threshold for calling a TR "bad"
        
        % what percentage of bad volumes should lead to excluding a subject for
        % motion? 
%         1% threshold means excluding for 2 bad volumes or more (there are
%         105 vols)
        percent_bad_thresh = 1;
        
        roi_str = 'wmMask';
        roits_file = [dataDir '/%s/dti96trilin/' roi_str '_ts'];
      
    otherwise % for fmri tasks
        
        mp_file = [dataDir '/%s/func_proc/' task '_vr.1D']; % motion param file where %s is task
        
        thresh = .5; % threshold for calling a TR "bad"
        percent_bad_thresh = 3;
        
        roi_str = 'nacc_afni';
        roits_file = [dataDir '/%s/func_proc/' task '_' roi_str '.1D']; % roi time series file to plot where %s is task
        
        % mid and midi have 2 runs that are concatenated;
        % use this variable to index which volume # is the first
        % vol of the 2nd run so that it's motion can be assigned to 0
        if strcmp(task,'mid')
            run2vol1idx=257;
        elseif strcmp(task,'midi')
            run2vol1idx=293;
        end
    
        
end % task
            
        



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
        max_motion(s,1)=nan; max_TR(s,1)=nan; nBad(s,1)=nan; omit_idx(s,1)=nan;
    else
        
        % plot motion params & save if desired
%        fig = plotMotionParams(mp);
%         if savePlots
%             outName = [subject '_mp'];
%             print(gcf,'-dpng','-r300',fullfile(figDir,outName));
%         end
%         
         switch motion_metric        
            case 'euclideannorm'
                m = computeAfniEuclideanNorm(mp); 
            case 'displacement'
                m = computeHeadDisplacement(mp(:,1:3)); 
            case 'fwdisplacement'
                m = computeFrameWiseDisplacement(mp);
         end
              
         if exist('run2vol1idx','var')
             m(run2vol1idx)=0; % there's no "motion" in the 1st vol of the 2nd run; correctly assign motion to 0
         end
         
        % determine this subject's max movement
        [max_motion(s,1),max_TR(s,1)]=max(m);
        
        
        % calculate # of bad images based on thresh
        nBad(s,1) = numel(find(m>thresh));
        fprintf('\n%s has %d bad image, which is %.2f percent of %s vols\n\n',...
            subject,nBad(s),100.*nBad(s,1)/numel(m),task);
        
        
        % determine whether to omit subject or not, based on percent_bad_thresh
        if 100.*nBad(s)/numel(m)>percent_bad_thresh
            omit_idx(s,1) = 1;
        else
            omit_idx(s,1) = 0;
        end
        
        
        % plot, if desired
        if ~isempty(roits_file) && exist(sprintf(roits_file,subject),'file')
            ts = dlmread(sprintf(roits_file,subject));
        else
            ts = zeros(numel(m),1); roi_str = '';
        end     
       fig = plotEnMotionThresh(m,thresh,ts,strrep(roi_str,'_',' '),1);
        
        % if a time series is plotted for diffusion data, ignore the b0 volumes
        % (it messes up the plot scale)
        if strcmp(task,'dti')
            subplot(2,1,2)
            ylim([min(ts)-1 max(ts(10:end))+1])
        end
        
        if savePlots
            outName = [subject '_mp2'];
            print(gcf,'-dpng','-r300',fullfile(figDir,outName));
        end
        
    end % isempty(mp)
    
end % subjects



%% calculate tSNR

%% show where censored TRs are



%%
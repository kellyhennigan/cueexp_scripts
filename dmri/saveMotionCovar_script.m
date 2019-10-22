
%%%%%%%% do QA on motion on data from cue fmri experiment

clear all
close all

p = getCuePaths();
dataDir = p.data;

subjects=getCueSubjects('dti');


% filepath to motion params .mat file, saved out during pre-processing
mp_filepath = [dataDir '/%s/dti96trilin/dwi_aligned_trilin_ecXform.mat']; %s is subject id

vox_mm = 2; % dti voxel dimensions are 2mm isotropic

outFilePath = fullfile(dataDir,'dwimotion.csv');

% motion_metric = 'euclideannorm'; 
motion_metric = 'displacement'; 
% motion_metric = 'fwdisplacement'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


for s = 1:numel(subjects)
    
    subject = subjects{s};
    fprintf(['\nworking on subject ' subject '...\n\n']);
    
    mp = []; % this subject's motion params
    
    if ~exist(sprintf(mp_filepath,subject),'file')
        
        warning(['couldnt get motion params for subject ' subject ', so skipping...'])
        
        dwimotion(s,1)=nan;
        
    else
        
        load(sprintf(mp_filepath,subject)); % loads a structural array, "xform"
        mp=vertcat(xform(:).ecParams);
        mp = mp(:,[1:3 5 4 6]); % rearrange to be in order dx,dy,dz,roll,pitch,yaw
        mp(:,1:3) = mp(:,1:3).*vox_mm; % change displacement to be in units of mm
        mp(:,4:6) = mp(:,4:6)/(2*pi)*360; % convert rotations to units of degrees
        
        
        switch motion_metric
            case 'euclideannorm'
                m = computeAfniEuclideanNorm(mp);
            case 'displacement'
                m = computeHeadDisplacement(mp(:,1:3));
            case 'fwdisplacement'
                m = computeFrameWiseDisplacement(mp);
        end
         
        % define subject motion covariate as mean metric across all
         % volumes
        dwimotion(s,1) = mean(m);
      
        
    end
    
end % subjects



%% save out as a csv file

subjid = cell2mat(subjects);

T=table(subjid,dwimotion);

% save out
writetable(T,outFilePath); 



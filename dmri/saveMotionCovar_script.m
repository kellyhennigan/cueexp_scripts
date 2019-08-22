
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
        
         
        % get the euclidean norm of volume-to-volume motion 
        enorm = [0;sqrt(sum(diff(mp).^2,2))];
      
        % mean motion 
%         meandisplacement = computeHeadDisplacement(mp(:,1:3));
%         
%         % mean framewise displacement
%         meanfwd =  computeFrameWiseMeanDisplacement(mp);
%         
        % max enorm 
        maxenorm = max(enorm);
        
        %%% decide here which summary measure to use
        
         % define subject motion covariate as mean of all motion params
        dwimotion(s,1) = mean(enorm);
      
        
    end
    
end % subjects



%% save out as a csv file

subjid = cell2mat(subjects);

T=table(subjid,dwimotion);

% save out
writetable(T,outFilePath); 



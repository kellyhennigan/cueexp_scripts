% resample a fiber group into N nodes for a set of subjects and calculate
% diffusion properties for each node (e.g., md, fa, etc.) and save out a
% .mat file with these measures.

clear all
close all

p = getCuePaths;
task = 'dti';
[subjects,gi] = getCueSubjects('dti',0);


dataDir = p.data;


% filepaths relative to each subject's directory
dt6file = 'dti96trilin/dt6.mat';
% dt6file = 'dti80trilin/dt6.mat';



% define fiber group to load
% method = 'conTrack';
method = 'mrtrix_fa';


% nNodes = 20; % number of nodes for fiber tract
nNodes = 100; % number of nodes for fiber tract

fgMLabels = {'FA','MD','RD','AD'};


% left and/or right hemisphere?
% LorR = ['L','R'];
LorR = ['R'];

combineLR = 1; % 1 to combine L and R, otherwise, 0


%%%%%%%%%%%%%%%%%%%%%%
% define seed, target, & version string to ID each fiber group to loop over
% seeds = {'DA';
%     'DA';
%     'DA'
%     'DA'
%     'DA'};
% 
% targets = {'nacc';
%     'nacc';
%     'nacc'
%     'caudate';
%     'putamen'};
% %
% versionStrs = {'belowAC_autoclean';
%     'aboveAC_autoclean';
%     'autoclean';
%     'autoclean';
%     'autoclean'};

seeds = {'DA'};

targets = {'nacc'};

versionStrs = {'belowAC_dil2_autoclean'};


% versionStrs = {'autoclean';
%     'autoclean';
%     'autoclean';

% seeds = {'DA'};
%     'DA';
%     'DA';
%     'DA';
%     'DA';
%     'nacc'};
%
% targets = {'nacc'};
%     'caudate';
%     'putamen';
%     'nacc';
%     'nacc';
%     'PVT'};
%
% versionStrs = {'autoclean';
%     'autoclean';
%     'autoclean';
%     'autoclean_cl1';
%     'autoclean_cl2';
%     'autoclean'};
%
% seeds = {'nacc'};
%
% targets = {'PVT'};
%

% fiber group file string
fgStr = '%s%s_%s%s_%s.pdb'; %s: seed,lr,target,lr,versionStr

% out file name string
outStr = '%s%s_%s%s_%s.mat'; %s: seed,lr,target,lr,versionStr


outDir = fullfile(dataDir, 'fgMeasures',method);


%% do it

for j=1:numel(targets) % target rois loop
    
    % get seed, target, and version string for this fg
    seed = seeds{j};
    target = targets{j};
    versionStr = versionStrs{j};
    
    
    for lr=LorR  % L/R loop
        
        fgName = sprintf(fgStr,seed,lr,target,lr,versionStr); %  fg file name
        
        err_subs = {}; % keep track of which subjects throw an error on dtiCompute... function
        
        for i = 1:numel(subjects)
            
            subject = subjects{i};
            
            fprintf(['\n\nworking on subject ',subject,'\n\n']);
            
            subjDir = fullfile(dataDir,subject);
            cd(subjDir);
            
            fgPath = fullfile('fibers',method,fgName);
            
            if ~exist(fgPath,'file')
                
                err_subs=[err_subs {subject}];
                eigVals(i,:,:) = nan(1,nNodes,3);
                fgMeasures{1}(i,:) = nan(1,nNodes);
                fgMeasures{2}(i,:) = nan(1,nNodes);
                fgMeasures{3}(i,:) = nan(1,nNodes);
                fgMeasures{4}(i,:) = nan(1,nNodes);
                
            else
                
                % load dt6 file
                dt = dtiLoadDt6(dt6file);
                %     [fa,md] = dtiComputeFA(dt.dt6);
                
                
                % load ROIs
                roi1 = roiNiftiToMat(['ROIs/' seed lr '.nii.gz']);
                roi2 = roiNiftiToMat(['ROIs/' target lr '.nii.gz']);
                
                
                % load fibers
                fg = mtrImportFibers(fgPath);
                
                
                % reorient to start in DA ROI and clip to DA and target ROIs
                %     (this may be already done but do it again just in case)
                fg = AFQ_ReorientFibers(fg,roi1,roi2);
                
                
                %  get fa and md measures for correlation test
%                 try
%                     [fa, md, rd, ad, cl, subjSuperFiber,fgClipped,~,~,fgResampled,subjEigVals]=...
%                         dtiComputeDiffusionPropertiesAlongFG_with_eigs(fg,dt,roi1,roi2,nNodes,[]);
%                     
                    % for a few subjects, the call to clip the fg between the rois
                    % is leaving no pathways; if this happens, dont pass ROIs,
                    % which means the pathways won't be clipped.
%                 catch ME
                    %                 if strcmp(ME.message,'Index exceeds matrix dimensions.')
%                     err_subs=[err_subs {subject}];
                    [fa, md, rd, ad, cl, subjSuperFiber,fgClipped,~,~,fgResampled,subjEigVals]=...
                        dtiComputeDiffusionPropertiesAlongFG_with_eigs(fg,dt,[],[],nNodes,[]);
                    %                 end
%                 end
                %         [fa, md, rd, ad, cl, fgvol{i}, TractProfiles(i)] = AFQ_ComputeTractProperties(fg, dt,nNodes, 0);
                
                
                fgMeasures{1}(i,:) = fa;
                fgMeasures{2}(i,:) = md;
                fgMeasures{3}(i,:) = rd;
                fgMeasures{4}(i,:) = ad;
                eigVals(i,:,:) = permute(subjEigVals,[3 1 2]);
                SuperFibers(i)=subjSuperFiber;
                
                clear fa md rd ad cl dt t1 roi1 roi2
                
            end
            
        end % subjects
        
        
        %% save out fg measures
        
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        
        outName = sprintf(outStr,seed,lr,target,lr,versionStr);
        outPath = fullfile(outDir,outName);
        
        if exist('gi','var')
            save(outPath,'subjects','gi','seed','target','lr',...
                'fgName','nNodes','fgMeasures','fgMLabels','SuperFibers','eigVals','err_subs');
        else
            save(outPath,'subjects','seed','target','lr',...
                'fgName','nNodes','fgMeasures','fgMLabels','SuperFibers','eigVals','err_subs');
        end
        
        fprintf(['\nsaved out file ' outName '\n\n']);
        
        clear fgMeasures SuperFibers eigVals
        
    end % L/R
    
end % targets


%% combine L and R

if combineLR
    
    for j=1:numel(targets) % target rois loop
        
        % get seed, target, and version string for this fg
        seed = seeds{j};
        target = targets{j};
        versionStr = versionStrs{j};
        
        outNameL = sprintf(outStr,seed,'L',target,'L',versionStr);
        outNameR = sprintf(outStr,seed,'R',target,'R',versionStr);
        outNameLR = sprintf(outStr,seed,'LR',target,'LR',versionStr);
        
        combineLRFgMeasures(fullfile(outDir,outNameL),fullfile(outDir,outNameR),...
            fullfile(outDir,outNameLR));
        
    end
    
end
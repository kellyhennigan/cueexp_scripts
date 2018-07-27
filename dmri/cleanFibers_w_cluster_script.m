% this script does the following:

% import fibers defined from intersecting 2 rois,
% reorients fibers so they all start from roi1 (roi1),
% performs kmeans clustering on pathways before iterative
% pruning step.
% clean the groups iteratively using AFQ_removeFiberOutliers(),
% and saves out cleaned L, R fiber groups
% also saves out a .mat file that has info on the parameters used to
% determine outliers in the cleaning procedure.

% this script performs kmeans clustering on pathways before iterative
% pruning step.

% define variables, directories, etc.
clear all
close all


% get experiment-specific paths and cd to main data directory
[p,~,subjects]=whichCueSubjects('stim','dti');

dataDir = p.data;


seed = 'DA';  % define seed roi

target = 'nacc';

% LorR = ['L','R'];
LorR = upper(input('L, R, or both?','s'));
if strcmp(LorR,'BOTH')
    LorR='LR';
end

doPlot = 1; % 1 to plot & save out figs, otherwise 0


% method = 'conTrack';
% lmax = '';

method = 'mrtrix_fa';
lmax = 'lmax8';


% out file name for pruned fibers
% outFgStr = [seed '%s_' target '%s_' lmax '_autoclean']; %s: LorR, LorR # NOTE: '_cl1' or 2 will be appended to end
outFgStr = [seed '%s_' target '%s_autoclean']; %s: LorR, LorR # NOTE: '_cl1' or 2 will be appended to end


plotToScreen = 0; % 1 to plot to screen, otherwise 0

%% get pruning params based on tractography method

switch method
    
    case 'conTrack'
        
        %         fgStr = ['scoredFG_' seed '%s_' target '%s_top1000.pdb']; %s: LorR, LorR
        fgStr = ['scoredFG_' seed '%s_' target '%s_top1000.pdb']; %s: LorR, LorR
        box_thresh = 8;
        maxIter = 5;
        
    case {'mrtrix','mrtrix_orig','mrtrix_fa','mrtrix_tournier'}
        
        fgStr = [seed '%s_' target '%s_' lmax '.tck']; % %s: LorR, LorR
        box_thresh = 5;
        maxIter = 5;  %
        
end

% additional non-method specific pruning params
maxDist=4;
maxLen=4;
numNodes=100;
M='mean';
count = 0;
show = 0; % 1 to plot each iteration, 0 otherwise



%% DO IT

for lr=LorR
    
    fgName=sprintf(fgStr,lr,lr);
    outFgName = sprintf(outFgStr,lr,lr);
    
    if doPlot
        figDir = fullfile(p.figures,'dti',method,outFgName);
        if ~exist(figDir,'dir')
            mkdir(figDir);
        end
    end
    
    
    fprintf('\n\n working on %s fibers for roi %s%s...\n\n',method,target,lr);
    i=1
    for i=1:numel(subjects)
        
        subject = subjects{i};
        fprintf(['\n\nworking on subject ' subject '...\n\n'])
        subjDir = fullfile(p.data,subject);
        cd(subjDir);
        
        % load seed and target rois
        roi1 = roiNiftiToMat(['ROIs/' seed lr '.nii.gz']);
        roi2 = roiNiftiToMat(['ROIs/' target lr '.nii.gz']);
        
        
        % load fiber group
        cd(fullfile(subjDir,'fibers',method));
        fg = fgRead(fgName);
        
        
        if numel(fg.fibers)<2
            fprintf(['\n\nfiber group is empty for subject, ' subject '\n\n']);
        else
            
            % reorient fibers so they all start in DA ROI
            [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
            
            
            % remove crazy fibers that deviate outside area defined by box_thresh
            fg = pruneFG(fg,roi1,roi2,0,box_thresh);
            
            if numel(fg.fibers)<2
                fprintf(['\n\nfiber group is empty for subject, ' subject '\n\n']);
            else
                
                
                % do kmeans clustering to omit fibers above the AC, if desired
                [cluster_fgs{1},cluster_fgs{2},cl_means{i}]=clusterDANAccFibers(fg,0);
                
                
                % now cycle through the 2 k-means clustered fiber groups; 1st one goes
                % under AC, 2nd one goes above AC
                for j=1:2
                    
                    fg = cluster_fgs{j};
                    
                    % remove outliers and save out cleaned fiber group
                    %     if ~isempty(fg.fibers)
                    
                    [~, keep,niter]=AFQ_removeFiberOutliers(fg,...
                        maxDist,maxLen,numNodes,M,count,maxIter,show);     % remove outlier fibers
                    
                    cleanfg{j} = getSubFG(fg,find(keep),[outFgName '_cl' num2str(j)]);
                    
                    nFibers_clean(i,j) = numel(cleanfg{j}.fibers); % keep track of the final # of fibers
                    
                    fprintf('\n\n final # of %s cleaned fibers: %d\n\n',cleanfg{j}.name, nFibers_clean(i,j));
                    
                    mtrExportFibers(cleanfg{j},cleanfg{j}.name);  % save out cleaned fibers
                    
                end
                
                
                % plot, if desired
                if doPlot
                    AFQ_RenderFibers(cleanfg{2},'tubes',0,'color',[0 0 1],'plottoscreen',plotToScreen);
                    AFQ_RenderFibers(cleanfg{1},'tubes',0,'color',[1 0 0],'newfig',0,'plottoscreen',plotToScreen);
                    title([subject ' fg1 in red, fg2 in blue'])
                    print(gcf,'-dpng','-r300',fullfile(figDir,[subject '_clustered_fgs']));
                end
                
                close all
                
            end % empty fibers
            
        end % empty fibers
        
    end % subjects
    
end % LorR


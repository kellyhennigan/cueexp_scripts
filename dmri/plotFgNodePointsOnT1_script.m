
clear all
close all


[p,task,subjects,gi]=whichCueSubjects('stim','dti');
p=getCuePaths();
task='dti';
[subjects,gi]=getCueSubjects(task,0);
dataDir = p.data;

t1Path = fullfile(dataDir,'templates','TT_N27.nii');

method = 'mrtrix_fa';
fgMDir = fullfile(dataDir,'fgMeasures',method);
fgMStr = '_belowAC_dil2_autoclean';

LorR = ['L'];

% targets = {'nacc','caudate','putamen'};
targets = {'nacc'};

% define subject-specific filepaths for affine & warp xforms from native to tlrc space
xform_aff=fullfile(dataDir,'%s','t1','t12tlrc_xform_Affine.txt');
xform_invWarp=fullfile(dataDir,'%s','t1','t12tlrc_xform_InverseWarp.nii.gz');

node = 65;

outDir = fullfile(dataDir,'fg_densities',method);
if ~exist(outDir,'dir')
    mkdir(outDir);
end

%% get coords from desired node of fiber group & convert to tlrc space

t1=niftiRead(t1Path); % load background image

for lr=LorR
    
    for j=1:numel(targets)
        
        target = targets{j};
        
        fgMName = ['DA' lr '_' target lr fgMStr];
        
        load(fullfile(fgMDir,[fgMName '.mat']));
        
        ol = createNewNii(t1,[fgMName '_node' num2str(node)]); % create overlay with all zeros for data
        
        % node_coords_tlrc=dlmread('/Users/Kelly/cueexp/data/fgMeasures/DA_naccR_node11_coords_tlrc');
        % node_coords_tlrc=dlmread('/Users/Kelly/cueexp/data/fgMeasures/DA_naccL_node11_coords_tlrc');
        
        
        for i=1:size(subjects)
            
            subject = subjects{i};
            
            fprintf('\nworking on subject %s...\n',subject)
            
            % % get subject's node coords in tlrc space
            node_coords_tlrc(i,:) = round(xformCoordsANTs(SuperFibers(i).fibers{1}(:,node),...
                sprintf(xform_aff,subject),...
                sprintf(xform_invWarp,subject)));
            
            % get img coords for a sphere around mean coord w/2 voxel radius
            a=dtiBuildSphereCoords(mrAnatXformCoords(ol.qto_ijk,node_coords_tlrc(i,:)),2);
            
            % get index for those sphere coords
            idx=sub2ind(size(t1.data),a(:,1),a(:,2),a(:,3));
            
            % add a +1 to those coords in the overlay
            ol.data(idx)=ol.data(idx)+1;
            
            
            fprintf('\ndone.\n')
            
        end % subject loop
        
        cd(outDir)
        writeFileNifti(ol);
        
    end % targets
    
end % LorR

%% plot overlay

% 
% caud = [238,178,35]./255;       % yellow
% nacc = [250 24 29]./255;        % red
% putamen = [33, 113, 181]./255;  % blue
% dTier = [244 101 7]./255;       % orange
% vTier = [44, 129, 162]./255;    % blue (different from putamen blue)
% daRoi = [28 178 5]./255;       % green
% 
% colors = [caud; nacc; putamen; dTier; vTier; daRoi]; % needs to match the number of elements in area vector
% 
%  0.925 0.528 0.169 1 % nice purple complimentary to the caudate yellow

%  0.916 0.010 0.458 %% GREAT hot pink!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fiber density colors:
% yellow
% yellow = [
%     252, 244, 200
%     250, 223, 150
%     244, 199, 92
%     caud.*255
%     221, 151, 28]./255;

% % red
% red = [
%     254   224   210
%     252   140   114
%     251    91    74
%     nacc.*255
%     200    15    21]./255;


% blue
% blue = [
%     158, 202, 225
%     107, 174, 214
%     66, 146, 198
%     putamen.*255
%     8, 69, 148]./255;
%


% 
% % [imgRgbs,olMasks,olVals,h,acpcSlices] = plotOverlayImage(nii,t1,cmap,c_range,plane,acpcSlices,doPlot,autoCrop,plotCBar,plotToScreen)
% plotOverlayImage(ol,t1,autumn,[1 round(quantile(ol.data(ol.data~=0),.9))],1)
% plotOverlayImage(ol,t1,autumn(max(ol.data(:))),[1 max(ol.data(:))],2)
% [imgRgbs,olMasks,olVals,h,acpcSlices]=plotOverlayImage(ol,t1,autumn(max(ol.data(:))),[1 max(ol.data(:))],3)
% 











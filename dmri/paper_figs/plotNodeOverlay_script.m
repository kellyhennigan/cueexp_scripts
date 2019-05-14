clear all
close all
% [p,task,subjects,gi]=whichCueSubjects('stim','dti');
p=getCuePaths();
task='dti';
dataDir = p.data;
figDir=p.figures_dti;
group='controls';
t1Path = fullfile(dataDir,'templates','TT_N27.nii');
method = 'mrtrix_fa';
fgMDir = fullfile(dataDir,'fgMeasures',method);
fgMStr = '_belowAC_dil2_autoclean';
lr = 'L';
% targets = {'nacc','caudate','putamen'};
target = 'nacc';
node = 65;
inDir = fullfile(dataDir,'fg_densities',method);

outDir=fullfile(figDir,'highestcorrnode_overlay');
if ~exist(outDir,'dir')
    mkdir(outDir)
end

%% get coords from desired node of fiber group & convert to tlrc space
t1=niftiRead(t1Path); % load background image
fgMName = ['DA' lr '_' target lr fgMStr];
ol=niftiRead(fullfile(inDir,[fgMName '_node' num2str(node) '.nii.gz']))
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
% colors for fiber density maps:
fd_nacc = [linspace(252,221,8)',linspace(244,151,8)',linspace(200,28,8)']./255; % yellow
cmap=fd_nacc
% cmap=''
plane=2;
acpcSlices=-6
plotToScreen=1
[t1halfmm, newXform] = mrAnatResliceSpm(t1.data, inv(t1.qto_xyz),[], [.5 .5 .5],[1 1 1 0 0 0]);
[imgRgbs,olMasks,olVals,h,acpcSlices] = plotOverlayImage(ol,t1,cmap,[],plane,acpcSlices,1,[],[],plotToScreen)
% plotOverlayImage(ol,t1,autumn,[1 round(quantile(ol.data(ol.data~=0),.9))],1)
% plotOverlayImage(ol,t1,autumn(max(ol.data(:))),[1 max(ol.data(:))],2)
% [imgRgbs,olMasks,olVals,h,acpcSlices]=plotOverlayImage(ol,t1,autumn(max(ol.data(:))),[1 max(ol.data(:))],3)
%
print(gcf,'-dpng','-r300',fullfile(outDir,['DAL_naccL_belowAC_dil2_node65']));
acpcSlices=''
[imgRgbs,olMasks,olVals,h,acpcSlices] = plotOverlayImage(ol,t1,cmap,[],plane,acpcSlices,1,[],[],plotToScreen)

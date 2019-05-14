%% define variables for calling createOverlayImages


%%

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getCuePaths;
p2 = getSkew32Paths;
dataDir=p.data;
dataDir2=p2.data;
cd(dataDir);

% filepath to background image
% bg = niftiRead(fullfile(dataDir,'templates','TT_N27.nii'));
bg = niftiRead(fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii'));

% hypothalamus atlas mask
hyp=niftiRead(fullfile(dataDir,'templates','CIT168toMNI152_prob_atlas_bilat_1mm_hypothalamus.nii.gz'));
% hyp=niftiRead(fullfile(dataDir,'templates','CIT168toMNI152_prob_atlas_bilat_1mm_putamen.nii.gz'));
hyp.data(hyp.data>=.25)=1;
hyp.data(hyp.data<.25)=0;
hyp.qto_xyz=hyp.sto_xyz;
hyp.qto_ijk=hyp.sto_ijk;

fgStr = 'DAL_naccL_belowAC_dil2_autoclean';

fd=niftiRead(fullfile(dataDir,'fibers_mni',[fgStr '_group_mni.nii.gz']));
fd.data(fd.data~=0)=1;

fd2=niftiRead(fullfile(dataDir2,'fibers_mni',[fgStr '_group_mni.nii.gz']));
fd2.data(fd2.data~=0)=1;


% sampleNum='1';

fd_nacc = [linspace(252,221,8)',linspace(244,151,8)',linspace(200,28,8)']./255; % yellow


% fdcol=[ 0.0235    0.1373    0.1882
%     0.0510    0.1843    0.3569
%     0.1098    0.2078    0.5373
%     0.2824    0.2039    0.6392
%     0.3882    0.2549    0.5922
%     0.4941    0.3020    0.5608
%     0.6000    0.3294    0.5412
%     0.6980    0.3647    0.5176
%     0.8118    0.4039    0.4471
%     0.9020    0.4510    0.3843
%     0.9373    0.5255    0.3412
%     0.9961    0.6196    0.2510
%     0.9922    0.7333    0.2627
%     0.9804    0.8510    0.2784
%     0.9059    0.9686    0.3333];

fdcol=[
    0.0510    0.1843    0.3569
    0.1098    0.2078    0.5373
    0.2824    0.2039    0.6392
    0.3882    0.2549    0.5922
    0.4941    0.3020    0.5608
    0.6000    0.3294    0.5412
    0.6980    0.3647    0.5176
    0.8118    0.4039    0.4471
    0.9020    0.4510    0.3843
    0.9373    0.5255    0.3412
    0.9961    0.6196    0.2510
    0.9922    0.7333    0.2627
    0.9804    0.8510    0.2784];


cmap=fdcol;
% filepath to mask, if desired
% maskFilePath = fullfile(dataDir,'ROIs','DA.nii');
% cmap=autumn(64);

scale = 0; % 1 to scale, otherwise 0

q_crange=[.1 .9]; % min/max quantiles of data values to determine color range


plane=2;
acpcSlices=-6


ac=[]; % auto-crop images? inf means no cropping

plotCBar = 0;

saveFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]

figDir = [p.figures_dti '/bestnode_2samples'];

figPrefix = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

fdXform = fd.qto_xyz;


% if acpcSlices isn't defined, plot center of mass coords
if notDefined('acpcSlices') || isempty('acpcSlices')
    coords = round(getNiiVolStat(fd.data,fdXform,'com'));
    acpcSlices = unique(coords(:,plane))';
end


% determine c_range for each overlay
c_range=quantile(fd.data(fd.data~=0),[q_crange]);
%     c_range{j}=[.2 1];


% plot fiber density overlay
% [imgRgbs,olMasks,olVals,h,acpcSlices] = plotOverlayImage(nii,t1,cmap,c_range,plane,acpcSlices,doPlot,autoCrop,plotCBar)
doPlot=1;
plotCBar=1;
cmap=[1 0 0];
c_range=[.5 10];
[imgRgbs] = plotOverlayImage(fd,bg,cmap,c_range,plane,acpcSlices,...
    doPlot,[],plotCBar);
print(gcf,'-dpng','-r300',fullfile(figDir,'_colorbar'))

plotFDMaps(imgRgbs{1},plane,acpcSlices,saveFigs,figDir,['sample' sampleNum]);


% doPlot=1;
% plotCBar=1
% [imgRgbs, olMasks,olVals(j,:),~,acpcSlicesOut] = plotOverlayImage(fd,bg,cmap,c_range{j},plane,acpcSlices,...
%     doPlot,ac,plotCBar);
% print(gcf,'-dpng','-r300',fullfile(figDir,'_colorbar'))



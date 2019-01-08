function saveOutSubjFGMeasures(fg,dt,roi1,roi2,outDir)
% -------------------------------------------------------------------------
% usage: resample a fiber group into N nodes, calculate
% diffusion properties for each node (e.g., md, fa, etc.), and save out a
% .mat file with these measures.

%
% INPUT:
%   fg - fiber group
%   dt - dt6 file (in mrvista diffusion software format)

% OUTPUT:
%   var1 - etc.
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 14-Sep-2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load fiber group, dt6file, and rois if they are input  if fg input is a filename
if isstr(fg)
    fg = fgRead(fg);
end

% load dt6file if input dt is a filename
if isstr(dt)
    dt = dtiLoadDt6(dt);
end

if isstr(roi1)
    roi1 = roiNiftiToMat(roi1);
end

if isstr(roi2)
    roi2 = roiNiftiToMat(roi2);
end

if notDefined(outDir)
    outDir=pwd;
end

% nNodes = 20; % number of nodes for fiber tract
nNodes = 100; % number of nodes for fiber tract


%%  do it

% %  get fa and md measures for correlation test
% try
%     [fa, md, rd, ad, cl, SuperFiber,fgClipped,~,~,fgResampled,eigVals]=...
%         dtiComputeDiffusionPropertiesAlongFG_with_eigs(fg,dt,roi1,roi2,nNodes,[]);
%     
    % for a few subjects, the call to clip the fg between the rois
    % is leaving no pathways; if this happens, dont pass ROIs,
    % which means the pathways won't be clipped.
% catch ME
    [fa, md, rd, ad, cl, SuperFiber,fgClipped,~,~,fgResampled,eigVals]=...
        dtiComputeDiffusionPropertiesAlongFG_with_eigs(fg,dt,[],[],nNodes,[]);
    %                 end
% end
%         [fa, md, rd, ad, cl, fgvol{i}, TractProfiles(i)] = AFQ_ComputeTractProperties(fg, dt,nNodes, 0);


%% save out fg measures

if ~exist(outDir,'dir')
    mkdir(outDir)
end

outPath = fullfile(outDir,fg.name);

save(outPath,'fa','md','rd','ad','SuperFiber','eigVals')

fprintf(['\nsaved out .mat file ' outPath '\n\n']);


% xform subject's superfiber coordinates to tlrc space


clear all
close all


% [p,task,subjects,gi]=whichCueSubjects('stim','dti');
p=getCuePaths();
task='dti';
dataDir = p.data;


group='controls';

method = 'mrtrix_fa';
fgMDir = fullfile(dataDir,'fgMeasures',method);
fgMStr = '_belowAC_autoclean';
lr = ['L'];
target = 'nacc';
fgMName = ['DA' lr '_' target lr fgMStr];
fgMFile=fullfile(fgMDir,[fgMName '.mat']);

t1Path = fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii');

% define subject-specific filepaths for affine & warp xforms from native to tlrc space
xform_aff=fullfile(dataDir,'%s','t1','t12tlrc_xform_Affine.txt');
xform_invWarp=fullfile(dataDir,'%s','t1','t12tlrc_xform_InverseWarp.nii.gz');
xform_aff2=fullfile(dataDir,'templates','tlrc2mni_xform_Affine.txt');
xform_invWarp2=fullfile(dataDir,'templates','tlrc2mni_xform_InverseWarp.nii.gz');


outDir = fullfile(dataDir,'fibers_mni');
if ~exist(outDir,'dir')
    mkdir(outDir);
end

%% get coords from desired node of fiber group & convert to tlrc space

t1=niftiRead(t1Path); % load background image

[fgMeasures,fgMLabels,scores,subjects,gi,SuperFibers]=loadFGBehVars(...
    fgMFile,'',group);


outName=[fgMName '_group_allfibers_mni' ];

allfibers={};

i=1;
for i=1:size(subjects)
    
    subject = subjects{i};
    
    fprintf('\nworking on subject %s...\n',subject)
    
    fg=fgRead(fullfile(dataDir,subject,'fibers',method,[fgMName '.pdb']));
    
    % % get subject's node coords in group space
%     fgcoords_tlrc = xformCoordsANTs(SuperFibers(i).fibers{1},...
%         sprintf(xform_aff,subject),...
%         sprintf(xform_invWarp,subject))';
%     

% take just 100 fibers for each subject
nfibers=numel(fg.fibers);
if nfibers>100
    fi=randperm(nfibers,100); % fiber index
    fg.fibers=fg.fibers(fi);
end

fgcoords_tlrc = cellfun(@(x) xformCoordsANTs(x,...
        sprintf(xform_aff,subject),...
        sprintf(xform_invWarp,subject)),fg.fibers,'uniformoutput',0);
    

    fgcoords_mni = cellfun(@(x) xformCoordsANTs(x,xform_aff2,xform_invWarp2), fgcoords_tlrc,'uniformoutput',0);
    
    fgcoords_mni=cellfun(@(x) x', fgcoords_mni,'uniformoutput',0);
    
    allfibers(end+1:end+numel(fgcoords_mni),1)=fgcoords_mni;
    
    fprintf('\ndone.\n')
    
end % subject loop

% save out as fiber group
fg = dtiNewFiberGroup(outName, [],[],1,allfibers);
mtrExportFibers(fg,fullfile(outDir,outName));

% save out as density map
%fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,0);

% save new fiber density file
ni=createNewNii(t1,fd,fullfile(outDir,outName),'fiber density');
writeFileNifti(ni);

% save out coords as .mat file
save(fullfile(outDir,[outName '.mat']),'fgcoords_mni');



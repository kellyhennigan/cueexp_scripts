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
fgMStr = '_belowAC_dil2_autoclean';
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

      
            olName=[fgMName '_group_mni' ];
     
        
        ol = createNewNii(t1,olName); % create overlay with all zeros for data
        
         
        % node_coords_tlrc=dlmread('/Users/Kelly/cueexp/data/fgMeasures/DA_naccR_node11_coords_tlrc');
        % node_coords_tlrc=dlmread('/Users/Kelly/cueexp/data/fgMeasures/DA_naccL_node11_coords_tlrc');
  
        i=1
        for i=1:size(subjects)
            
            subject = subjects{i};
            
            fprintf('\nworking on subject %s...\n',subject)
            
            % % get subject's node coords in tlrc space
            fgcoords_tlrc = xformCoordsANTs(SuperFibers(i).fibers{1},...
                sprintf(xform_aff,subject),...
                sprintf(xform_invWarp,subject))';
            
            fgcoords_mni{i,1} = xformCoordsANTs(fgcoords_tlrc,xform_aff2,xform_invWarp2)';
              
            
            fprintf('\ndone.\n')
            
        end % subject loop
        
        fg = dtiNewFiberGroup(olName, [],[],1,fibers
        
        cd(outDir)
        writeFileNifti(ol);
        dlmwrite([olName '_subjtlrccoords'],node_coords_tlrc);
        
        
    end % targets
    
end % LorR
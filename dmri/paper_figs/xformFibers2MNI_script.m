% xform fiber groups to group space


clear all
close all


p=getCuePaths();
dataDir = p.data;


subjects=getCueSubjects('dti',0);


method = 'mrtrix_fa';


seed = 'DA';

% targets = {'nacc','nacc','caudate','putamen'};
%
% % string to identify fiber group files (must correspond to targets cell array)
% fgFileStrs = {'belowAC_autoclean',...
%     'aboveAC_autoclean',...
%     'autoclean',...
%     'autoclean'};
%
% LorR=['L','R'];

targets = {'nacc'}

% string to identify fiber group files (must correspond to targets cell array)
fgFileStrs = {'belowAC_autoclean'};

LorR=['L'];


t1Path = fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii');

% define subject-specific filepaths for affine & warp xforms from native to tlrc space
xform_aff=fullfile(dataDir,'%s','t1','t12mni_xform_Affine.txt');
xform_warp=fullfile(dataDir,'%s','t1','t12mni_xform_Warp.nii.gz');


outDir = fullfile(dataDir,'fibers_mni_v2');
if ~exist(outDir,'dir')
    mkdir(outDir);
end


%% get coords from desired node of fiber group & convert to tlrc space

t1=niftiRead(t1Path); % load background image

for lr=LorR
    
    for j=1:numel(targets)
        
        target=targets{j};
        
        fgName = [seed lr '_' target lr '_' fgFileStrs{j}];
        
        outName=[fgName '_group_allfibers_mni' ];
        
        allfibers={};
        
        i=1;
        for i=1:size(subjects)
            
            subject = subjects{i};
            
            fprintf('\nworking on subject %s...\n',subject)
            
            fg=fgRead(fullfile(dataDir,subject,'fibers',method,[fgName '.pdb']));
            
            % take just 100 fibers for each subject
            nfibers=numel(fg.fibers);
            if nfibers>100
                fi=randperm(nfibers,100); % fiber index
                fg.fibers=fg.fibers(fi);
            end
            
            fgcoords_mni = cellfun(@(x) xformCoordsANTs(x,...
                sprintf(xform_aff,subject),...
                sprintf(xform_warp,subject)),fg.fibers,'uniformoutput',0);
            
            fgcoords_mni=cellfun(@(x) x', fgcoords_mni,'uniformoutput',0);
            
            allfibers(end+1:end+numel(fgcoords_mni),1)=fgcoords_mni;
            
            fprintf('\ndone.\n')
            
        end % subject loop
        
        % save out as fiber group
        fg = dtiNewFiberGroup(outName, [],[],1,allfibers);
        mtrExportFibers(fg,fullfile(outDir,outName));
        
        % save out as density map
        fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,0);
        ni=createNewNii(t1,fd,fullfile(outDir,outName),'fiber density');
        writeFileNifti(ni);
        
        % make density map of just seed endpoints
        outName_seed = [outName, '_' seed 'endpts'];
        fg_seed=fg;
        fg_seed.fibers = cellfun(@(x) x(:,1), fg_seed.fibers,'UniformOutput',0);
        fd = dtiComputeFiberDensityNoGUI(fg_seed, t1.qto_xyz,size(t1.data),1,1,0);
        ni=createNewNii(t1,fd,fullfile(outDir,outName),'fiber density');
        writeFileNifti(ni);
        
        % make density map of just striatum endpoints
        outName_target = [outName, '_striatumendpts'];
        fg_target=fg;
        fg_target.fibers = cellfun(@(x) x(:,end), fg_target.fibers,'UniformOutput',0);
        fd = dtiComputeFiberDensityNoGUI(fg_seed, t1.qto_xyz,size(t1.data),1,1,0);
        ni=createNewNii(t1,fd,fullfile(outDir,outName),'fiber density');
        writeFileNifti(ni);
        
        
    end % targets

end % LorR
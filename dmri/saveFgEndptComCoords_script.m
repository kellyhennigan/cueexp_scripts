
clear all
close all


p=getCuePaths();
dataDir = p.data;


subjects=getCueSubjects('dti',0);
% subjects={'ph161104'};

method = 'mrtrix_fa';


seed = 'DA';

targets = {'nacc','nacc','caudate','putamen'};

% string to identify fiber group files (must correspond to targets cell array)
fgFileStrs = {'belowAC_autoclean',...
    'aboveAC_autoclean',...
    'autoclean',...
    'autoclean'};

LorR=['L','R'];

% targets = {'nacc'}
%
% % string to identify fiber group files (must correspond to targets cell array)
% fgFileStrs = {'belowAC_autoclean'};
%
% LorR=['L'];


% define subject-specific filepaths for affine & warp xforms from native to tlrc space
xform_aff=fullfile(dataDir,'%s','t1','t12mni_xform_Affine.txt');
xform_invwarp=fullfile(dataDir,'%s','t1','t12mni_xform_InverseWarp.nii.gz');

outDir = fullfile(dataDir,'fgendpt_com_coords');
if ~exist(outDir,'dir')
    mkdir(outDir);
end

%%

for lr=LorR
    
    for j=1:numel(targets)
        
        target=targets{j};
        
        fprintf('\nworking on target %s...\n',target)
        
        fgName = [seed lr '_' target lr '_' fgFileStrs{j}];
        
       
        seedCoM_mni=[]; targetCoM_mni=[];
        for i=1:size(subjects)
            
            subject = subjects{i};
            
            fprintf('\nworking on subject %s...\n',subject)
            
            fg=fgRead(fullfile(dataDir,subject,'fibers',method,[fgName '.pdb']));
            
            % get mean coord for endpoints
            seedCoM(i,:)=mean(cell2mat(cellfun(@(x) x(:,1), fg.fibers,'UniformOutput',0)'),2)';
            targetCoM(i,:)=mean(cell2mat(cellfun(@(x) x(:,end), fg.fibers,'UniformOutput',0)'),2)';
            
            endptCoM_mni = xformCoordsANTsMovingToFixed([seedCoM(i,:);targetCoM(i,:)],...
                sprintf(xform_aff,subject),...
                sprintf(xform_invwarp,subject));
            
            seedCoM_mni(i,:)=endptCoM_mni(1,:);
            targetCoM_mni(i,:)=endptCoM_mni(2,:);
            
            fprintf('\ndone.\n')
            
        end % subject loop
        
        %% save out com coords w/subject ids
       
        % native space seed endpt
        T = table([subjects],seedCoM);
        CoMfile=[fgName '_DAendpts_CoM_nativespace.txt'];
        writetable(T,fullfile(outDir,CoMfile),'WriteVariableNames',0);
        
        % mni space seed endpt
        T = table([subjects],seedCoM_mni);
        CoMfile=[fgName '_DAendpts_CoM_mni.txt'];
        writetable(T,fullfile(outDir,CoMfile),'WriteVariableNames',0);
        
        % native space target endpt
        T = table([subjects],targetCoM);
        CoMfile=[fgName '_striatumendpts_CoM_nativespace.txt'];
        writetable(T,fullfile(outDir,CoMfile),'WriteVariableNames',0);
        
        % mni space target endpt
        T = table([subjects],targetCoM_mni);
        CoMfile=[fgName '_striatumendpts_CoM_mni.txt'];
        writetable(T,fullfile(outDir,CoMfile),'WriteVariableNames',0);
        
    end % targets
    
end % LorR



% createQuenchState_script

% this script calls function createQST() to create quench state files for
% easier, less-mouse-clicking viewing of subjects' fiber tracts in Quench.

% createQST():
% createQST(qsDir,templatefile,volPaths,fgPaths,fgColors,outfilename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

p = getCuePaths; cd(p.data);


subs = {'ph161104'};

qsDir = '/Users/kelly/cueexp/quench_states'; % directory to house the quench state file

% templatefile = ['quench_state_template.qst']; % example quench state file to use as a template
templatefile = ['template_mid_sag.qst']; % example quench state file to use as a template


% define paths to volumes, fiber groups, etc.
% paths must be *relative to the directory of the quench state out file.
% use %s for subject string

% Volumes
volPaths = {'../data/%s/t1/t1_fs.nii.gz'}; % *relative* path to t1 volume

% % FGs
% fgPaths = {
%     '../data/%s/fibers/mrtrix_fa/DAL_putamenL_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAL_caudateL_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAL_naccL_aboveAC_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAL_naccL_belowAC_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAR_putamenR_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAR_caudateR_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAR_naccR_aboveAC_autoclean.pdb',...
%     '../data/%s/fibers/mrtrix_fa/DAR_naccR_belowAC_autoclean.pdb'};
% % 
% 
% fgColors=[0.1725    0.5059    0.6353
%     0.9804    0.0941    0.1137
%     0.9569    0.3961    0.0275
%     0.9333    0.6980    0.1373
%     0.1725    0.5059    0.6353
%     0.9804    0.0941    0.1137
%     0.9569    0.3961    0.0275
%     0.9333    0.6980    0.1373];

fgPaths = {
    '../data/%s/fibers/mrtrix_fa/mpfc8mmL_naccL_autoclean23.pdb',...
    '../data/%s/fibers/mrtrix_fa/mpfc8mmR_naccR_autoclean23.pdb',...
    '../data/%s/fibers/mrtrix_fa/asginsL_naccL_autoclean.pdb',...
    '../data/%s/fibers/mrtrix_fa/asginsR_naccR_autoclean.pdb',...
    '../data/%s/fibers/mrtrix_fa/amygdalaL_naccL_autoclean.pdb',...
    '../data/%s/fibers/mrtrix_fa/amygdalaR_naccR_autoclean.pdb'};


fgColors=[0.0588    0.8196    0.8588
    0.0588    0.8196    0.8588
   0.8863    0.0941    0.0078
   0.8863    0.0941    0.0078
   0.9922    0.6275         0
   0.9922    0.6275         0];



vis_idx = ones(numel(fgPaths),1);

% out file name
% outfilename = ['%s_NCP_mid_sag.qst'];
outfilename = ['%s_LRfg.qst'];

i=1

for i=1:numel(subs)
    
    % subject
    subj = subs{i};
    
    this_volPaths=cellfun(@sprintf,volPaths,repmat({subj},1,numel(volPaths)),'UniformOutput',0);
    this_fgPaths=cellfun(@sprintf,fgPaths,repmat({subj},1,numel(fgPaths)),'UniformOutput',0);
    this_outfilename = sprintf(outfilename,subj);
   
    
%% call createQST()


createQST(qsDir,templatefile,this_volPaths,this_fgPaths,fgColors,vis_idx,this_outfilename);


end

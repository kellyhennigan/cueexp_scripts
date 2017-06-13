
% script to plot and save motion parameter estimates output from afni's
% 3dvolreg function

clear all
close all

cd /home/hennigan/cueexp_claudia/scripts

p = getCuePaths_Claudia
% subjects = getCueSubjects_Claudia;

subjects ={'290','291','293','294','301'};


dataDir = p.data;
figDir = fullfile(p.figures,'motion_params')
if ~exist(figDir,'dir')
    mkdir(figDir)
end


%%
cd(dataDir)


for s = 1:numel(subjects)
    
    subject = subjects{s};
    
    mp = dlmread(fullfile(subject,'func_proc_cue','vr1.1D'));
    mp = mp(:,2:7);
    
    fig = plotMotionParams(mp)
    
    a=get(fig,'Children');
    title(a(6),subject)
    
    outName = [subject '_cue'];
    
    print(gcf,'-dpng','-r600',fullfile(figDir,outName));
    
end


% script to plot and save motion parameter estimates output from afni's
% 3dvolreg function

clear all
close all

% cd /home/hennigan/cueexp/scripts


subjects ={'rf160313'
    'jw160316'
    'as160317'
    'pk160319'
    'jc160320'
    'jc160321'};


p=getCuePaths;
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


clear all
close all

% 		'-stim_file 1 "'+func_dir+'/vr1.1D[1]" -stim_base 1 -stim_label 1 roll '
% 		'-stim_file 2 "'+func_dir+'/vr1.1D[2]" -stim_base 2 -stim_label 2 pitch '
% 		'-stim_file 3 "'+func_dir+'/vr1.1D[3]" -stim_base 3 -stim_label 3 yaw '
% 		'-stim_file 4 "'+func_dir+'/vr1.1D[4]" -stim_base 4 -stim_label 4 dS ' 
% 		'-stim_file 5 "'+func_dir+'/vr1.1D[5]" -stim_base 5 -stim_label 5 dL ' 
% 		'-stim_file 6 "'+func_dir+'/vr1.1D[6]" -stim_base 6 -stim_label 6 dP ' 
% 		'-stim_file 7 '+func_dir+'/csf1.1D -stim_base 7 -stim_label 7 csf ' 
% 		'-stim_file 8 '+func_dir+'/wm1.1D -stim_base 8 -stim_label 8 wm ' 
% 		'-stim_file 9 regs/cuec.1D -stim_label 9 cue '
% 		'-stim_file 10 regs/imgc.1D -stim_label 10 img ' 
% 		'-stim_file 11 regs/choicec.1D -stim_label 11 choice '
% 		'-stim_file 12 regs/cue_rtc.1D -stim_label 12 cue_rt ' 
% 		'-stim_file 13 regs/choice_rtc.1D -stim_label 13 choice_rt ' 
% 		'-stim_file 14 regs/img_alcoholc.1D -stim_label 14 alcohol ' 
% 		'-stim_file 15 regs/img_drugsc.1D -stim_label 15 drugs ' 
% 		'-stim_file 16 regs/img_foodc.1D -stim_label 16 food ' 
% 		'-stim_file 17 regs/img_neutralc.1D -stim_label 17 neutral ' 
% 		'-stim_file 18 regs/choice_strong_dontwantc.1D -stim_label 18 strong_dontwant ' 
% 		'-stim_file 19 regs/choice_somewhat_dontwantc.1D -stim_label 19 somewhat_dontwant ' 
% 		'-stim_file 20 regs/choice_somewhat_wantc.1D -stim_label 20 somewhat_want '
% 		'-stim_file 21 regs/choice_strong_wantc.1D -stim_label 21 strong_want ' 

subjects = {'aa151010','ag151024','wr151127','zl150930'};
% subjects = {'aa151010'};

data_dir = getDataDir;


for s=1:4
    
subj = subjects{s};

cd(data_dir)
cd(subj)
cd func_proc_cue

%% get baseline regs

vr = dlmread('vr1.1D'); vr = vr(1:432,:);
% vr = vr - repmat(mean(vr),size(vr,1),1); % de-mean 
wm = dlmread('wm1.1D'); wm = wm(1:432);
csf = dlmread('csf1.1D'); csf = csf(1:432);

regs_base = modelBaseline(432,2); % equivalent of polort=2
regs_base = [regs_base, vr(:,2:7), csf, wm];

regBaseLabels = {'poly0','poly1','poly2',...
    'roll','pitch','yaw','dS','dL','dP','csf','wm'};

%% get regs of interest


regFiles = {'cuec.1D','imgc.1D','choicec.1D','cue_rtc.1D','choice_rtc.1D',...
    'img_alcoholc.1D','img_drugsc.1D','img_foodc.1D','img_neutralc.1D',...
    'choice_strong_dontwantc.1D','choice_somewhat_dontwantc.1D',...
    'choice_somewhat_wantc.1D','choice_strong_wantc.1D'};

regLabels = {'cue','img','choice','cue_rt','choice_rt',...
    'alcohol','drugs','food','neutral',...
    'strong_dontwant','somewhat_dontwant','somewhat_want','strong_want'};



cd ../regs

regs_oi = []; % regs of interest 

for r=1:numel(regFiles)
    reg = dlmread(regFiles{r})
    reg = reg(1:432);
    regs_oi = [regs_oi,reg]
end

%% save out design matrix 

regIdx = [zeros(1,size(regs_base,2)),ones(1,size(regFiles,2))];

regLabels = [regBaseLabels regLabels]; 

X = [regs_base,regs_oi];

cd ../design_mats

save('glm.mat','X','regLabels','regIdx')

end
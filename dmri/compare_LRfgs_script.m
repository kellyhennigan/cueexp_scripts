% compare diffusivity measurements for left and right fiber groups


% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;

% directory & filename of fg measures
method = 'mrtrix_fa';

targets={'vlpfc'};

fgMatStrsL = {'sginsL_%sL_autoclean23'};

fgMatStrsR = {'sginsR_%sR_autoclean23'};
    

group = {'controls'};
% group = {'all'}; 

omit_subs={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it



j=1;
for j=1:numel(fgMatStrsL)
    
    fgMatStrL=sprintf(fgMatStrsL{j},targets{j});
    fgMatStrR=sprintf(fgMatStrsR{j},targets{j});
    
    
    %%%%%%%%%%%% get fiber group measures
    [fgMeasuresL,fgMLabels,~,subjects,gi]=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStrL '.mat']),'',[group{:}],omit_subs);
    nNodes = size(fgMeasuresL{1},2);
    
    %%%%%%%%%%%% get fiber group measures
    [fgMeasuresR,fgMLabels,~,subjects,gi]=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStrR '.mat']),'',[group{:}],omit_subs);
    
    % ttest for FA differences
    faL=mean(fgMeasuresL{1}(:,26:75),2);
    faR=mean(fgMeasuresR{1}(:,26:75),2);
    [h,p,~,stats]=ttest(faL,faR);
    fprintf('\nttest for FA differences in L and R %s: t(%d)=%.2f, p=%.3f\n\n\n',fgMatStrL,stats.df,stats.tstat,p);
    
    % ttest for MD differences
    mdL=mean(fgMeasuresL{2}(:,26:75),2);
    mdR=mean(fgMeasuresR{2}(:,26:75),2);
    [h,p,~,stats]=ttest(mdL,mdR);
    fprintf('\nttest for MD differences in L and R %s: t(%d)=%.2f, p=%.3f\n\n\n',fgMatStrL,stats.df,stats.tstat,p);
    
    
end % fiber groups (fgMatStrs)






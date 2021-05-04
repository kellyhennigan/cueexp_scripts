
% Hyp: MSSD in the NAcc is related to MFB tract coherence 


% steps: 

% 1) calculate MSSD in NAcc (left and right separately) in MID 
% 2) are left and right correlated? if so, perhaps combine them
% 3) if not, calculate this separately 


clear all
close all

[subjects,gi]=getCueSubjects('mid');

p=getCuePaths;

dataDir=p.data;

doCensor=1; % 1 to censor out timepoints with bad motion, otherwise 0

rmOutliers=0; % 1 to remove subjects with >X SD away from mean mssd scores
ol_thresh=3; % SD threshold for determining outliers


%% do it


i=1;


for i=1:numel(subjects)
    
    subject=subjects{i};
    
    tsL=dlmread(fullfile(dataDir,subject,'func_proc','mid_naccL_ts.1D'));
    tsR=dlmread(fullfile(dataDir,subject,'func_proc','mid_naccR_ts.1D'));
    
    censor=dlmread(fullfile(dataDir,subject,'func_proc','mid_censor.1D'));
    
    % censor bad motion timepoints if desired 
    if doCensor
        tsL=tsL.*censor;
        tsR=tsR.*censor;
    end
    
    % correlation between left and right nacc
    r_ts(i,1)=corr(tsL,tsR);
    
    % calculate mean squared successive differences (Samanez-Larkin et al.,
    % 2010)
    mssdL(i,1) = mean(diff(tsL).^2);
    mssdR(i,1) = mean(diff(tsR).^2);

end


% is MSSD correlated between left and right nacc? YES, highly. So average
% them

mssd=mean([mssdL mssdR],2);

%% remove outliers if desired 

if rmOutliers

    idx=find(abs(zscore(mssd))>ol_thresh);
    if ~isempty(idx)
       
        mssdL(idx)=[];
        mssdR(idx)=[];
        mssd(idx)=[];    
        subjects(idx)=[];
        gi(idx)=[];
    end 
end
%
%%
% 
%     %% is there an association between mssd and age? Yes! about r=.28
%    
    age=getCueData(subjects,'age');
    corr(mssd,age)
    plotCorr([],age,mssd,'age','mssd','rp')
%     
%     
%     
%     %% " " for patients v controls? Yes! though when controlling for age, this effect becomes marginal
%     
%     gi(gi>0)=1; % set epiphany patients with gi=2 to be gi=1 (so gi is 1 for all patients)
%     
%     [h,p,~,stats]=ttest2(mssd(gi==0),mssd(gi==1));
%     stats
%     
%     % controlling for age 
%     fitglm([age mssd],gi,'Distribution','binomial')
%     
%   
%     %% what about relapse? nope...
%     
%     rel=getCueData(subjects,'relapse_6months');
%       [h,p,~,stats]=ttest2(mssd(rel==0),mssd(rel==1));
%       
%       
%       %% save it out as a table
%       
%       cd /home/span/lvta/cueexp/data/mssd_mid_measures
%        T=table(subjects,gi,rel,mssd,age);
%        writetable(T,'mssd_mid.csv')
%        
%       
      %%%%%%%%%%%%

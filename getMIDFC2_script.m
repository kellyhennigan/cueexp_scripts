% is reduced FA in MFB a sign of reduced coherence?

% supporting evidence for this view would be if functional connectivity
% between NAcc and VTA was positively correlated with FA. This would
% suggest that lower FA > less functional communication between VTA and
% NAcc


%


clear all
close all

%% define initial stuff

p = getCuePaths;
dataDir = p.data;

task='mid';

[subjects,gi]=getCueSubjects(task);

Xbasefname=['pp_' task '_tlrc_afni_nuisance_designmat.txt'];

seedtsfname=[task '_VTA_afni.1D']; % seed ROI time series

targettsfname=[task '_nacc_afni.1D']; % time series for target ROI

conds = {'gain5','gain0'}; % conditions to contrast

regfileStr=fullfile(dataDir,'%s','regs',['%s_trial_mid.1D']); %s is subject, conds

censorTRs=1; % 1 to censor out bad motion TRs, otherwise 0

censorFilePath = fullfile(dataDir, '%s','func_proc',[task '_censor.1D']);

TR=2;

fcTRs=[1:7]; % which TRs to use for func connectivity calculation?
% This should be relative to trial onset, e.g., TRs=[3 4]


%% do it

cd(dataDir);

for s=1:numel(subjects)
    
    subject=subjects{s};
    
    cd(subject); cd func_proc;
    
    % load baseline model that includes all baseline regs
    Xbase=readtable(sprintf(Xbasefname,subject));
    baseNames = Xbase.Properties.VariableNames;
    Xbase=table2array(Xbase);
    
    seedts=dlmread(seedtsfname);
    targetts=dlmread(targettsfname);
    
    % regress out baseline regs
    seed_errts=glm_fmri_fit(seedts,Xbase,[],'err_ts');
    target_errts=glm_fmri_fit(targetts,Xbase,[],'err_ts');
    
    % if censoring TRs, set censored TRs to nan
    if censorTRs
        censorVols = find(dlmread(sprintf(censorFilePath,subject))==0);
        seedts(censorVols)=nan; seed_errts(censorVols)=nan;
        targetts(censorVols)=nan; target_errts(censorVols)=nan;
    end
    
    % method 1: straight up correlation
    r_restingstate(s,1)=nancorr(seedts,targetts);
    
    % method 2: correlation, partialling out nuisance regs
    %         note: this returns the same r as doing
    %         partialcorr(targets,seedts,Xbase), but nancorr() can handle nan
    %         values
    r_restingstate_partial(s,1)=nancorr(seed_errts,target_errts);
    
    
    %% contrast functional connectivity between gain5 vs gain0 trials
    
    for j=1:numel(conds)
        
        onsetTRs=find(dlmread(sprintf(regfileStr,subject,conds{j})));
        
        TRs=repmat(onsetTRs,1,fcTRs(end))+repmat(0:fcTRs(end)-1,size(onsetTRs,1),1);
        TRs=TRs(:,fcTRs);
        
        if ~censorVols
            
            % correlation between seed and target during cond{j}
            r_cond{j}(s,:)=diag(corr(seedts(TRs),targetts(TRs)));
            
            % also do it on data with nuisance regs regressed out
            r_cond_partial{j}(s,:)=diag(corr(seed_errts(TRs),target_errts(TRs)));
            
        else
            
            % if censorVols, have to do this the slower way with a loop:
            for k=1:numel(fcTRs)
                r_cond{j}(s,k)=nancorr(seedts(TRs(:,k)),targetts(TRs(:,k)));
                r_cond_partial{j}(s,k)=nancorr(seed_errts(TRs(:,k)),target_errts(TRs(:,k)));
            end
            
        end
        
    end % cond loop
    
    cd(dataDir);

end % subject loop



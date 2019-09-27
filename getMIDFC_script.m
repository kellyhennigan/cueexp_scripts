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

% subjects=getCueSubjects(task);
subjects=getCueSubjects('dti',0);

Xbasefname=['pp_' task '_tlrc_afni_nuisance_designmat.txt'];

seedtsfname=[task '_VTA_afni.1D']; % seed ROI time series

targettsfname=[task '_nacc_afni.1D']; % time series for target ROI

reg1file=fullfile(dataDir,'%s','regs','gain5_trial_mid.1D');
reg2file=fullfile(dataDir,'%s','regs','gain0_trial_mid.1D');


censorTRs=1; % 1 to censor out bad motion TRs, otherwise 0

censorFilePath = fullfile(dataDir, '%s','func_proc',[task '_censor.1D']);


TR=2; 

fcTRs=[3]; % which TRs to use for func connectivity calculation?
% This should be relative to trial onset, e.g., TRs=[3 4] 

%% do it

cd(dataDir);

for s=1:numel(subjects)
    
    subject=subjects{s};
    
    cd(subject); cd func_proc;
    
    % load baseline model that includes all baseline regs
    
    if exist(Xbasefname,'file')
        
        Xbase=readtable(sprintf(Xbasefname,subject));
        baseNames = Xbase.Properties.VariableNames;
        Xbase=table2array(Xbase);
        
        targetts=dlmread(targettsfname);
        seedts=dlmread(seedtsfname);
        
        % regress out baseline regs
        target_errts=glm_fmri_fit(targetts,Xbase,[],'err_ts');
        seed_errts=glm_fmri_fit(seedts,Xbase,[],'err_ts');
       
        % method 1: err ts then correlate
        d1(s,1)=corr(target_errts,seed_errts);
        
        % method 2: partial corr
        d2(s,1)=partialcorr(targetts,seedts,Xbase);
        
        % method 3: regression with Xbase and seed ts as predictors
        stats=glm_fmri_fit(targetts,[Xbase seedts],[zeros(1,size(Xbase,2)) 1]);
        d3(s,1)=stats.B(end);
        
        
        %% do gain5 vs gain0 functional connectivity 
        
      
        % do gain5 vs gain0 anticipation
        onsetTRs1=find(dlmread(sprintf(reg1file,subject)));
        onsetTRs2=find(dlmread(sprintf(reg2file,subject)));
        
          % get array of indices of which TRs to get data for
          TRs1=repmat(onsetTRs1,1,fcTRs(end))+repmat(0:fcTRs(end)-1,size(onsetTRs1,1),1);
          TRs1=TRs1(:,fcTRs);
          TRs1=reshape(TRs1',[],1);
          
          TRs2=repmat(onsetTRs2,1,fcTRs(end))+repmat(0:fcTRs(end)-1,size(onsetTRs2,1),1);
          TRs2=TRs2(:,fcTRs); 
          TRs2=reshape(TRs2',[],1);
          
          if censorTRs
              censorVols = find(dlmread(sprintf(censorFilePath,subject))==0);
              TRs1(ismember(TRs1,censorVols))=nan;
              TRs2(ismember(TRs2,censorVols))=nan;
          end
            
          TRs1=TRs1(~isnan(TRs1));
          TRs2=TRs2(~isnan(TRs2));
          
          % method 1: use error time series
          r1(s,1)=corr(seed_errts(TRs1),target_errts(TRs1));
          r2(s,1)=corr(seed_errts(TRs2),target_errts(TRs2));
         
          % method 2: use regular time series
          r21(s,1)=corr(seedts(TRs1),targetts(TRs1));
          r22(s,1)=corr(seedts(TRs2),targetts(TRs2));
         
         
    else
        
        d1(s,1)=nan;
        d2(s,1)=nan;
        d3(s,1)=nan;
        
        r1(s,1)=nan;
        r2(s,1)=nan;
        
        r21(s,1)=nan;
        r22(s,1)=nan;
        
    end
    
    cd(dataDir)
    
end % subject loop


fc1=r1-r2;
fc2=r21-r22;


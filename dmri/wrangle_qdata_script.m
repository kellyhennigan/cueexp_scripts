% save out data for dti comparisons


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

task='dti';
% group = 'controls';
% group = 'patients_complete';
group='patients';
% group='';

[subjects,gi] = getCueSubjects(task,group); 


% filepath for saving out table of variables
outDir=fullfile(dataDir,'q_demo_data');
outPath = fullfile(outDir,['data_' group '_' datestr(now,'yymmdd') '.csv']);

omit_subs={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


if ~exist(outDir,'dir')
    mkdir(outDir)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  variables of interest

% for both groups 
vars = {
    'relapse',...
    'days2relapse',...
    'relapse_1month',...
    'relapse_3months',...
    'relapse_4months',...
    'relapse_6months',...
    'observedtime',...
    'censored',...
    'age',...
    'gender',...
    'education',...
    'dwimotion',...
    'BIS',...
    'BIS_attn',...
    'BIS_motor',...
    'BIS_nonplan',...
    'discount_rate',...
    'BDI',...
    'tipi_extra',...
    'tipi_agree',...
    'tipi_consci',...
    'tipi_emostab',...
    'tipi_open',...
    'digitspan',...
    'basdrive',...
    'basfunseek',...
    'basrewardresp',...
    'bisbas_bis',...
    'smoke',...
    'craving',...
    'years_of_use',...
    'first_use_age'};

% % for just controls 
% vars = {
%     'age',...
%     'gender',...
%     'education',...
%     'dwimotion',...
%     'BIS',...
%     'BIS_attn',...
%     'BIS_motor',...
%     'BIS_nonplan',...
%     'discount_rate',...
%     'BDI',...
%     'tipi_extra',...
%     'tipi_agree',...
%     'tipi_consci',...
%     'tipi_emostab',...
%     'tipi_open',...
%     'digitspan',...
%     'basdrive',...
%     'basfunseek',...
%     'basrewardresp',...
%     'bisbas_bis'
%     };


%%%%%%%%%%%%%%%%%%%%%%%% relapse data

Tvars = table(); % table of demographic data
for i=1:numel(vars)
    Tvars=[Tvars array2table(getCueData(subjects,vars{i}),'VariableNames',vars(i))];
end
Tvars.discount_rate=log(Tvars.discount_rate); % get log(k)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% brain data

% 
% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','pvt','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};

roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains'};

% 
% roiNames = {'nacc_desai','ins_desai','mpfc','VTA'};
% roiVarNames = {'nacc','insula','mpfc','vta'};
% % 
% 
bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names
% % 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
stims = {'gain5','gain0','gain5-gain0','gainwin','gainmiss'};
% 
tcPath = fullfile(dataDir,['timecourses_mid_afni'],'%s','%s.csv'); %s is roiNames, stims
% % % tcPath = fullfile(dataDir,['timecourses_' task '_afni_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
% % % 
TRs = [3:7];
aveTRs = []; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
% aveTRs = [1 2]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
% % 
for j=1:numel(roiNames)
%          
    for k = 1:numel(stims)
%         
%         % if there's a minus sign, assume desired output is stim1-stim2
        if strfind(stims{k},'-')
            stim1 = stims{k}(1:strfind(stims{k},'-')-1);
            stim2 = stims{k}(strfind(stims{k},'-')+1:end);
            thistc1=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim1),subjects,TRs);
            thistc2=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim2),subjects,TRs);
            thistc=thistc1-thistc2;
        
        % otherwise just load stim timecourses
        else
            thistc=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stims{k}),subjects,TRs);
        end
        bd = [bd thistc];
%         
        % update var names
        for ti = 1:numel(TRs)
            bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' num2str(TRs(ti))];
        end
%         
        % if averaging over TRs is desired, include it
        if ~isempty(aveTRs)
            bd = [bd mean(thistc(:,aveTRs),2)];
            bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' strrep(num2str(TRs(aveTRs)),' ','') 'mean'];
        end
%             
    end % stims
%    
end % rois
% % 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI BETAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%  
betastims = {'gvnant','gvnout'};

betaPath = fullfile(dataDir,['results_mid_afni'],'roi_betas','%s','%s.csv'); %s is roiName, stim

for j=1:numel(roiNames)

      for k = 1:numel(betastims)
          
          this_bfile = sprintf(betaPath,roiNames{j},betastims{k}); % this beta file path
          if exist(this_bfile,'file')
              B = loadRoiTimeCourses(this_bfile,subjects);
              bd = [bd B];
              bdNames = [bdNames [roiVarNames{j} '_' strrep(betastims{k},'-','') '_beta']];
          end
            
      end % betastims
      
end % roiNames

% brain data
Tbrain = array2table(bd,'VariableNames',bdNames);


%% dwi data


% directory & filename of fg measures
method = 'mrtrix_fa';

% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
fgMatStrs = {'DALR_naccLR_belowAC_autoclean',...
    'DALR_naccLR_aboveAC_autoclean',...
    'DAL_naccL_belowAC_autoclean',...
    'DAL_naccL_aboveAC_autoclean',...
    'DAR_naccR_belowAC_autoclean',...
    'DAR_naccR_aboveAC_autoclean'};


fgOutStrs={'inf_NAcc',...
    'sup_NAcc',...
    'inf_NAccL',...
    'sup_NAccL',...
    'inf_NAccR',...
    'sup_NAccR'};


% fgMatStrs = {'DALR_naccLR_belowAC_autoclean',...
%     'DAL_naccL_belowAC_autoclean',...
%     'DAR_naccR_belowAC_autoclean',...
%     'DALR_naccLR_aboveAC_autoclean',...
%     'DAL_naccL_aboveAC_autoclean',...
%     'DAR_naccR_aboveAC_autoclean',...
%     'DALR_caudateLR_autoclean',...
%     'DAL_caudateL_autoclean',...
%     'DAR_caudateR_autoclean',...
%     'DALR_putamenLR_autoclean',...
%     'DAL_putamenL_autoclean',...
%     'DAR_putamenR_autoclean',...
%     'mpfc8mmL_naccL_autoclean',...
%     'mpfc8mmR_naccR_autoclean',...
%     'mpfc8mmLR_naccLR_autoclean'};
% 
% fgOutStrs={'inf_NAcc',...
%     'inf_NAccL',...
%     'inf_NAccR',...
%     'sup_NAcc',...
%     'sup_NAccL',...
%     'sup_NAccR',...
%     'caudate',...
%     'caudateL',...
%     'caudateR',...
%     'putamen',...
%     'putamenL',...
%     'putamenR',...
%     'mpfcL_naccL',...
%     'mpfcR_naccR',...
%     'mpfcLR_naccLR'};
% 
% fgMatStrs = {'mpfc8mmL_naccL_autoclean23',...
%     'mpfc8mmR_naccR_autoclean23',...
%     'mpfc8mmLR_naccLR_autoclean23',...
%     'amygdalaL_naccL_autoclean_max5',...
%     'amygdalaR_naccR_autoclean_max5',...
%     'bmAmygL_naccL_autoclean',...
%     'bmAmygR_naccR_autoclean',...
%     'asginsL_naccL_clip_autoclean',...
%     'asginsR_naccR_clip_autoclean'...
%     'asginsL_naccL_autoclean',...
%     'asginsR_naccR_autoclean'};
% 
% fgOutStrs={'mpfcL_naccL',...
%     'mpfcR_naccR',...
%     'mpfc_nacc',...
%     'amygdalaL_naccL_autoclean_max5',...
%     'amygdalaR_naccR_autoclean_max5',...
%     'bmAmygL_naccL_autoclean',...
%     'bmAmygR_naccR_autoclean',...
%     'asginsL_naccL_clip_autoclean',...
%     'asginsR_naccR_clip_autoclean'...
%     'asginsL_naccL_autoclean',...
%     'asginsR_naccR_autoclean'};
%     



   %%%%%%%%%%%% get fiber group measures & behavior scores
   
   fgms=[]; % fg measures
   fgNames=[];
   f=1
   for f=1:numel(fgMatStrs)
       
       fgMFile=fullfile(dataDir,'fgMeasures',method,[fgMatStrs{f} '.mat']);
       [fgMeasures,fgMLabels,scores,dwisubs,~]=loadFGBehVars(fgMFile,'',group,omit_subs);
       if ~isequal(dwisubs,subjects)
           error('hold up - subjects dont match up.');
       end
       fa = mean(fgMeasures{1}(:,26:75),2);
       md = mean(fgMeasures{2}(:,26:75),2);
       rd = mean(fgMeasures{3}(:,26:75),2);
       ad = mean(fgMeasures{4}(:,26:75),2);
       
       % controlling for age and head motion
       fa_controllingagemotion=glm_fmri_fit(fa,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
       md_controllingagemotion=glm_fmri_fit(md,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
       rd_controllingagemotion=glm_fmri_fit(rd,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
       ad_controllingagemotion=glm_fmri_fit(ad,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
     
       fgms=[fgms fa md rd ad fa_controllingagemotion md_controllingagemotion rd_controllingagemotion ad_controllingagemotion];
      
       fgNames{end+1} = [fgOutStrs{f} '_fa'];
       fgNames{end+1} = [fgOutStrs{f} '_md'];
       fgNames{end+1} = [fgOutStrs{f} '_rd'];
       fgNames{end+1} = [fgOutStrs{f} '_ad'];
       
       fgNames{end+1} = [fgOutStrs{f} '_fa_controllingagemotion'];
       fgNames{end+1} = [fgOutStrs{f} '_md_controllingagemotion'];
       fgNames{end+1} = [fgOutStrs{f} '_rd_controllingagemotion'];
       fgNames{end+1} = [fgOutStrs{f} '_ad_controllingagemotion'];
       
       
   end
   
   % dti data
Tdti = array2table(fgms,'VariableNames',fgNames);

% bis_controllingagemotion=glm_fmri_fit(Tvars.BIS,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
% dx=gi; dx(dx>0)=1;
% dx_controllingagemotion=glm_fmri_fit(dx,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
      

%% get voxel counts for ROIs 
% 
% % first, run: saveOutRoiNVoxels_script.m to save out voxel counts into a
% % table array 
% 
% inPath=fullfile(dataDir,'q_demo_data','nroivoxels.csv');
% Tnvox=readtable(inPath);
% 
% if strcmp(group,'controls')
%     Tnvox(Tnvox.gi>0,:)=[];
% elseif strcmp(group,'patients')
%     Tnvox(Tnvox.gi==0,:)=[];
% end
% 
% if ~isequal(subjects,Tnvox.subjid)
%     error('hold up - the subject ids for the roi voxel counts dont match up with the subject list');
% end
% 
% % take out the subject ids and group index variables
% Tnvox(:,1:2)=[];
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate relapse, demographic, behavioral, & brain data into 1 table

% subject ids
subjid = cell2mat(subjects);
Tsubj = table(subjid);
Tgroupindex=table(gi);
% Tcontrollingagemotion=table(bis_controllingagemotion,dx_controllingagemotion);
% Tcontrollingagemotion=table(bis_controllingagemotion);

% concatenate all data into 1 table
T=table();
% T = [Tsubj Tgroupindex Tvars Tbrain Tdti Tnvox];

T = [Tsubj Tgroupindex Tdti Tvars Tbrain];
% T = [Tsubj Tgroupindex Tvars Tdti Tcontrollingagemotion];

% save out
writetable(T,outPath); 

% done 












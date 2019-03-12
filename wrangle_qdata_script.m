% save out predictors for cue relapse prediction 


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

task='dti';
group = 'controls';
% group = 'patients_complete';

[subjects,gi] = getCueSubjects(task,group); 


% filepath for saving out table of variables
outDir=fullfile(dataDir,'q_demo_data');
outPath = fullfile(outDir,['data_' group '_' datestr(now,'yymmdd') '.csv']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


if ~exist(outDir,'dir')
    mkdir(outDir)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  variables of interest

% for both groups 
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
%     'bisbas_bis',...
%     'smoke',...
%     'craving',...
%     'relapse',...
%     'days2relapse',...
%     'relapse_1month',...
%     'relapse_3months',...
%     'relapse_6months'
%     };

% for just controls 
vars = {
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
    'bisbas_bis'
    };


%%%%%%%%%%%%%%%%%%%%%%%% relapse data




Tvars = table(); % table of demographic data
for i=1:numel(vars)
    Tvars=[Tvars array2table(getCueData(subjects,vars{i}),'VariableNames',vars(i))];
end
Tvars.discount_rate=log(Tvars.discount_rate); % get log(k)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% brain data


% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','pvt','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};

roiNames = {'nacc_desai','ins_desai','mpfc','VTA'};
roiVarNames = {'nacc','insula','mpfc','vta'};


bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names


%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stims = {'gain5','gain0','gain5-gain0','gainwin','gainmiss'};

tcPath = fullfile(dataDir,['timecourses_mid_afni'],'%s','%s.csv'); %s is roiNames, stims
% % tcPath = fullfile(dataDir,['timecourses_' task '_afni_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
% 
TRs = [3:8];
aveTRs = []; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
% 
for j=1:numel(roiNames)
         
    for k = 1:numel(stims)
        
        % if there's a minus sign, assume desired output is stim1-stim2
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
        
        % update var names
        for ti = 1:numel(TRs)
            bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' num2str(TRs(ti))];
        end
        
        % if averaging over TRs is desired, include it
        if ~isempty(aveTRs)
            bd = [bd mean(thistc(:,aveTRs),2)];
            bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' strrep(num2str(TRs(aveTRs)),' ','') 'mean'];
        end
            
    end % stims
   
end % rois


%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI BETAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
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
fgMatStrs = {'DALR_naccLR_belowAC_dil2_autoclean';...
    'DALR_naccLR_aboveAC_dil2_autoclean';...
    'DALR_caudateLR_dil2_autoclean';...
    'DALR_putamenLR_dil2_autoclean',...
    'DAL_naccL_belowAC_dil2_autoclean';...
    'DAL_naccL_aboveAC_dil2_autoclean';...
    'DAL_caudateL_dil2_autoclean';...
    'DAL_putamenL_dil2_autoclean',...
    'DAR_naccR_belowAC_dil2_autoclean';...
    'DAR_naccR_aboveAC_dil2_autoclean';...
    'DAR_caudateR_dil2_autoclean';...
    'DAR_putamenR_dil2_autoclean'};

fgOutStrs={'nacc_inferior',...
    'nacc_superior',...
    'caudate',...
    'putamen',...
    'nacc_inferiorL',...
    'nacc_superiorL',...
    'caudateL',...
    'putamenL',...
    'nacc_inferiorR',...
    'nacc_superiorR',...
    'caudateR',...
    'putamenR'};

   %%%%%%%%%%%% get fiber group measures & behavior scores
   
   fgms=[]; % fg measures
   fgNames=[];
   f=1
   for f=1:numel(fgMatStrs)
       
       fgMFile=fullfile(dataDir,'fgMeasures',method,[fgMatStrs{f} '.mat']);
       [fgMeasures,fgMLabels,scores,dwisubs,~]=loadFGBehVars(fgMFile,'',group);
       if ~isequal(dwisubs,subjects)
           error('hold up - subjects dont match up.');
       end
       fa = mean(fgMeasures{1}(:,26:75),2);
       md = mean(fgMeasures{2}(:,26:75),2);
       fgms=[fgms fa md];
       fgNames{end+1} = [fgOutStrs{f} '_fa'];
       fgNames{end+1} = [fgOutStrs{f} '_md'];
   end
   
   % dti data
Tdti = array2table(fgms,'VariableNames',fgNames);


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate relapse, demographic, behavioral, & brain data into 1 table

% subject ids
subjid = cell2mat(subjects);
Tsubj = table(subjid);
Tgroupindex=table(gi);

% concatenate all data into 1 table
T=table();
T = [Tsubj Tgroupindex Tvars Tbrain Tdti];


% save out
writetable(T,outPath); 

% done 












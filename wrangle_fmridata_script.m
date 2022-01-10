% save out data for dti comparisons


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

group='controls';

task='cue';

% get list of subjects with dwi data 
[subjects,groupindex]=getCueSubjects('dti');


% filepath for saving out table of variables
outDir=fullfile(dataDir,'cuedti_data');
outPath = fullfile(outDir,['data_' task '_' group '_' datestr(now,'yymmdd') '.csv']);

omit_subs={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


if ~exist(outDir,'dir')
    mkdir(outDir)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  variables of interest

% for just controls
vars = {
    'age',...
    'gender',...
    'education',...
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


Tvars = table(); % table of demographic data
for i=1:numel(vars)
    Tvars=[Tvars array2table(getCueData(subjects,vars{i}),'VariableNames',vars(i))];
end
% Tvars.discount_rate=log(Tvars.discount_rate); % get log(k)

%% behavioral data

Tbeh = table(); % table of demographic data

% 
if strcmp(task,'mid')
    
    % add mid behavioral data here
    behvars={'pa_cue_mid',...
        'na_cue_mid',...
        'valence_cue_mid',...
        'arousal_cue_mid'};
    
elseif strcmp(task,'cue')
    % for just controls
%     behvars = {
%         'cuert_alcohol',...
%         'cuert_drugs',...
%         'cuert_food',...
%         'cuert_neutral',...
%         'choicert_alcohol',...
%         'choicert_drugs',...
%         'choicert_food',...
%         'choicert_neutral',...
%         'pref_alcohol',...
%         'pref_drugs',...
%         'pref_food',...
%         'pref_neutral',...
%         'pa_alcohol',...
%         'pa_drugs',...
%         'pa_food',...
%         'pa_neutral',...
%         'na_alcohol',...
%         'na_drugs',...
%         'na_food',...
%         'na_neutral'
%         };

behvars = {
    'pa_alcohol',...
    'pa_drugs',...
    'pa_food',...
    'pa_neutral'};
    
end

for i=1:numel(behvars)
    Tbeh=[Tbeh array2table(getCueData(subjects,behvars{i}),'VariableNames',behvars(i))];
end


%% brain data

%
% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','pvt','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};

roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','insL_desai','insR_desai','dlpfc','dlpfcL','dlpfcR'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','ainsL','ainsR','dlpfc','dlpfcL','dlpfcR'};

bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names

if strcmp(task,'mid')
    
    % MID data
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    stims = {'gain5','gain0','gainwin','gainmiss'};
    %
    tcPath = fullfile(dataDir,['timecourses_mid_afni'],'%s','%s.csv'); %s is roiNames, stims
    % % % tcPath = fullfile(dataDir,['timecourses_' task '_afni_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
    % % %
    TRs = [3:7];
    aveTRs = [1:5]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
    % aveTRs = [1 2]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
    aveTRs=[];
    
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
    
    betastims = {'gvnant','gvnout','ant','out'};
    
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
    
    
    % cue data
elseif strcmp(task,'cue')
    
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    stims = {'alcohol','drugs','food','neutral'};
    %
    tcPath = fullfile(dataDir,['timecourses_cue_afni'],'%s','%s.csv'); %s is roiNames, stims
    % % % tcPath = fullfile(dataDir,['timecourses_' task '_afni_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
    % % %
    TRs = [3:7];
%     aveTRs = [1:5]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
    % aveTRs = [1 2]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
    aveTRs=[];
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
    
    betastims = {'alcohol','drugs','food','neutral'};
    
    betaPath = fullfile(dataDir,['results_cue_afni'],'roi_betas','%s','%s.csv'); %s is roiName, stim
    
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
    
end % task


% brain data
Tbrain = array2table(bd,'VariableNames',bdNames);


%% 
%% dwi data


% directory & filename of fg measures
method = 'mrtrix_fa';

% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
fgMatStrs = {'DALR_naccLR_belowAC_autoclean',...
    'DAL_naccL_belowAC_autoclean',...
    'DAR_naccR_belowAC_autoclean'};
% 
% 
fgOutStrs={'inf_NAcc',...
    'inf_NAccL',...
    'inf_NAccR'};

% fgMatStrs = {'mpfc8mmLR_naccLR_autoclean23',...
%     'mpfc8mmL_naccL_autoclean23',...
%     'mpfc8mmR_naccR_autoclean23'};
% 
% 
% fgOutStrs={'mpfc_nacc',...
%     'mpfc_naccL',...
%     'mpfc_naccR'};



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
       
%        % controlling for age and head motion
%        fa_controllingagemotion=glm_fmri_fit(fa,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
%        md_controllingagemotion=glm_fmri_fit(md,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
%        rd_controllingagemotion=glm_fmri_fit(rd,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
%        ad_controllingagemotion=glm_fmri_fit(ad,[ones(numel(subjects),1) Tvars.age Tvars.dwimotion],[],'err_ts');
%      
%        fgms=[fgms fa md rd ad fa_controllingagemotion md_controllingagemotion rd_controllingagemotion ad_controllingagemotion];
      
       fgms=[fgms fa md rd ad]
    
       fgNames{end+1} = [fgOutStrs{f} '_fa'];
       fgNames{end+1} = [fgOutStrs{f} '_md'];
       fgNames{end+1} = [fgOutStrs{f} '_rd'];
       fgNames{end+1} = [fgOutStrs{f} '_ad'];
       
%        fgNames{end+1} = [fgOutStrs{f} '_fa_controllingagemotion'];
%        fgNames{end+1} = [fgOutStrs{f} '_md_controllingagemotion'];
%        fgNames{end+1} = [fgOutStrs{f} '_rd_controllingagemotion'];
%        fgNames{end+1} = [fgOutStrs{f} '_ad_controllingagemotion'];
%        
       
   end
   
   % dti data
Tdti = array2table(fgms,'VariableNames',fgNames);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate demographic, behavioral, & brain data into 1 table

% subject ids
subjid = cell2mat(subjects);
Tsubj = table(subjid);
Tgroupindex=table(groupindex);
% Tcontrollingagemotion=table(bis_controllingagemotion,dx_controllingagemotion);
% Tcontrollingagemotion=table(bis_controllingagemotion);

% concatenate all data into 1 table
T=table();
T = [Tsubj Tgroupindex Tvars Tbeh Tbrain Tdti];

% save out
writetable(T,outPath);

% done












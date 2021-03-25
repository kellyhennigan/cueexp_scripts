% save out all individual diff data for dti, mid, midi, cue comparison


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

group=''; % all subjects 

% get list of subjects with dwi data
[subjects,groupindex]=getCueSubjects('dti');


% filepath for saving out table of variables
outDir=fullfile(dataDir,'dti_data');
outPath = fullfile(outDir,['data_' datestr(now,'yymmdd') '.csv']);

omit_subs={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


if ~exist(outDir,'dir')
    mkdir(outDir)
end


%% relapse vars

relapse = getCueData(subjects,'relapse');

days2relapse = getCueData(subjects,'days2relapse');

relIn1Mos = getCueData(subjects,'relapse_1month');

relIn3Mos = getCueData(subjects,'relapse_3months');

relIn6Mos = getCueData(subjects,'relapse_6months');


% set nan relapse vals to zero...
% relapse(isnan(relapse))=0;

[obstime,censored,notes]=getCueRelapseSurvival(subjects);


% Trelapse = table(relapse,days2relapse,obstime,censored,relIn6Mos);

Trelapse = table(relapse,days2relapse,obstime,relIn1Mos,relIn3Mos,relIn6Mos);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% demographic & clinical vars
%

demVars = {'years_of_use',...
    'first_use_age',...
    'days_sober',...
    'days_in_rehab',...
    'primary_meth',...
    'primary_cocaine',...
    'primary_crack',...
    'auditscore4orgreater',...
    'opioidusedisorder',...
    'cannabisuse',...
    'poly_drug_dep',...
    'smoke',...
    'depression_diag',...
    'anxiety_diag',...
    'ptsd_diag',...
    'education',...
    'age',...
    'gender',...
    'bdi',...
    'bis',...
    'bis_attn',...
    'bis_motor',...
    'bis_nonplan',...
    'discount_rate',...
    'tipi_extra',...
    'tipi_agree',...
    'tipi_consci',...
    'tipi_emostab',...
    'tipi_open',...
    'digitspan',...
    'forwarddigitspan',...
    'backwarddigitspan',...
    'basdrive',...
    'basfunseek',...
    'basrewardresp',...
    'bisbas_bis'};


Tdem = table(); % table of demographic data
for i=1:numel(demVars)
    Tdem=[Tdem array2table(getCueData(subjects,demVars{i}),'VariableNames',demVars(i))];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bam data


% BAM q1 ("In the past 30 days, would you say your physical health has
% been?")
bam_q1 = getBAMData(subjects,'q1');


% BAM q2 ("In the past 30 days, how many nights did you have trouble
% falling asleep or staying asleep?")
bam_q2 = getBAMData(subjects,'q2');


% BAM q3 ("In the past 30 days, how many days have you felt depressed,
% anxious, angry or very upset throughout most of the day?")
bam_q3 = getBAMData(subjects,'q3');

bam_q4 = getBAMData(subjects,'q4');
bam_q5 = getBAMData(subjects,'q5');
bam_q6 = getBAMData(subjects,'q6');
bam_q7a = getBAMData(subjects,'q7a');
bam_q7b = getBAMData(subjects,'q7b');
bam_q7c = getBAMData(subjects,'q7c');
bam_q7d = getBAMData(subjects,'q7d');
bam_q7e = getBAMData(subjects,'q7e');
bam_q7f = getBAMData(subjects,'q7f');
bam_q7g = getBAMData(subjects,'q7g');

bam_q8 = getBAMData(subjects,'q8');
bam_q9 = getBAMData(subjects,'q9');
bam_q10 = getBAMData(subjects,'q10');
bam_q11 = getBAMData(subjects,'q11');
bam_q12 = getBAMData(subjects,'q12');
bam_q13 = getBAMData(subjects,'q13');
bam_q14 = getBAMData(subjects,'q14');
bam_q15 = getBAMData(subjects,'q15');
bam_q16 = getBAMData(subjects,'q16');
bam_q17 = getBAMData(subjects,'q17');


% define table of behavioral predictors
Tbam = table(bam_q1,bam_q2,bam_q3,bam_q4,bam_q5,bam_q6,...
    bam_q7a,bam_q7b,bam_q7c,bam_q7d,bam_q7e,bam_q7f,bam_q7g,...
    bam_q8,bam_q9,bam_q10,bam_q11,bam_q12,...
    bam_q13,bam_q14,bam_q15,bam_q16,bam_q17);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% behavioral data

Tbeh = table(); % table of demographic data

%     % add mid behavioral data here
%     behvars={'pa_cue_mid',...
%         'na_cue_mid',...
%         'valence_cue_mid',...
%         'arousal_cue_mid',};

% elseif strcmp(task,'cue')
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
    'pa_neutral',...
    'na_alcohol',...
    'na_drugs',...
    'na_food',...
    'na_neutral'};

% end

for i=1:numel(behvars)
    Tbeh=[Tbeh array2table(getCueData(subjects,behvars{i}),'VariableNames',behvars(i))];
end


%% brain data

%
% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','pvt','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};

roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','insL_desai','insR_desai','dlpfc','dlpfcL','dlpfcR','caudate','amygL','amygR'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','ainsL','ainsR','dlpfc','dlpfcL','dlpfcR','caudate','amygL','amygR'};

bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names


%%%% MID data

% %%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
stims = {'gain0','gain1','gain5','gainwin','gainmiss','loss0','loss1','loss5','losswin','lossmiss'};
%
tcPath = fullfile(dataDir,['timecourses_mid_afni'],'%s','%s.csv'); %s is roiNames, stims
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


%%%%% cue data


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



% brain data
Tbrain = array2table(bd,'VariableNames',bdNames);


%%
%% dwi data


% directory & filename of fg measures
method = 'mrtrix_fa';

% fgMatStr = 'naccLR_PVTLR_autoclean'; %'.mat' will be added to end
fgMatStrs = {'DAL_naccL_belowAC_autoclean';...
    'DAR_naccR_belowAC_autoclean';...
    'DAL_naccL_aboveAC_autoclean';...
    'DAR_naccR_aboveAC_autoclean';...
    'asginsL_naccL_autoclean';...
    'asginsR_naccR_autoclean';...
    'mpfc8mmL_naccL_autoclean23';...
    'mpfc8mmR_naccR_autoclean23'};


fgOutStrs={'inf_NAccL';...
    'inf_NAccR';...
    'sup_NAccL';...
    'sup_NAccR';...
    'asginsL_naccL';...
    'asginsR_naccR';...
    'mpfcL_naccL';...
    'mpfcR_naccR'};

% which nodes to average over? 2 entries for each fiber group: 1 node -
% last node to average over (e.g., [26 75] will average over nodes 26:75)
aveNodes=[26 75;
    26 75;
    26 75;
    26 75;
    11 41;
    11 41;
    26 75;
    26 75];

aveNodeStrs={'mid50';
    'mid50';
    'mid50';
    'mid50';
    'nodes11_41';
    'nodes11_41';
    'mid50';
    'mid50'};


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
    
    theseNodes=aveNodes(f,:);
    fa = mean(fgMeasures{1}(:,theseNodes(1):theseNodes(2)),2);
    imd = 1-mean(fgMeasures{2}(:,theseNodes(1):theseNodes(2)),2);
    ird = 1-mean(fgMeasures{3}(:,theseNodes(1):theseNodes(2)),2);
    ad = mean(fgMeasures{4}(:,theseNodes(1):theseNodes(2)),2);
    
     
    fgms=[fgms fa imd ird ad];
    
    fgNames{end+1} = [fgOutStrs{f} '_fa_' aveNodeStrs{f}];
    fgNames{end+1} = [fgOutStrs{f} '_imd_' aveNodeStrs{f}];
    fgNames{end+1} = [fgOutStrs{f} '_ird_' aveNodeStrs{f}];
    fgNames{end+1} = [fgOutStrs{f} '_ad_' aveNodeStrs{f}];
    
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
T = [Tsubj Tgroupindex Trelapse Tdem Tbam Tbeh Tbrain Tdti];

% save out
writetable(T,outPath);

% done












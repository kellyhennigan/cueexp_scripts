% save out predictors for cue relapse prediction 


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

task = 'cue';

% subjects = getCueSubjects(task); % stim patients
subjects = getCueSubjects(task,1); % stim patients


% filepath for saving out table of variables
% outPath = fullfile(dataDir,'relapse_data',['relapse_data_' datestr(now,'yymmdd') '_allsubs.csv']);
outPath = fullfile(dataDir,'relapse_data',['relapse_data_' datestr(now,'yymmdd') '.csv']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relapse vars

relapse = getCueData(subjects,'relapse');
days2relapse = getCueData(subjects,'days2relapse');

relIn6Mos = getCueData(subjects,'relapse_6months');

% set nan relapse vals to zero...
% relapse(isnan(relapse))=0;

[obstime,censored,notes]=getCueRelapseSurvival(subjects);

Trelapse = table(relapse,days2relapse,obstime,censored,relIn6Mos);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% demographic & clinical vars

demVars = {'years_of_use',...
    'first_use_age',...
    'days_sober',...
    'days_in_rehab',...
    'alc_dep',...
    'poly_drug_dep',...
    'smoke',...
    'depression_diag',...
    'bdi',...
    'anxiety_diag',...
    'ptsd_diag',...
    'education',...
    'age'};


Tdem = table(); % table of demographic data
for i=1:numel(demVars)
    Tdem=[Tdem array2table(getCueData(subjects,demVars{i}),'VariableNames',demVars(i))];
end

% make anxiety, ptsd, and depression diagnosis vars binary 
Tdem.ptsd_diag=strcmp(Tdem.ptsd_diag,'yes');
Tdem.depression_diag=strcmp(Tdem.depression_diag,'yes');
Tdem.anxiety_diag=strcmp(Tdem.anxiety_diag,'yes');
Tdem.clinical_diag = (Tdem.ptsd_diag | Tdem.depression_diag | Tdem.anxiety_diag); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% behavioral data


% pref ratings for drugs, food, and neutral stim
pref_stim = getCueData(subjects,'pref_stim');
pref_drug = pref_stim(:,2); pref_food = pref_stim(:,3); pref_neut = pref_stim(:,4);


% PA ratings for drugs, food, and neutral stim
pa_stim=getCueData(subjects,'pa_stim');
pa_drug= pa_stim(:,2); pa_food = pa_stim(:,3); pa_neut = pa_stim(:,4);


% PA ratings for drugs, food, and neutral cues
pa_cue=getCueData(subjects,'pa_cue');
pa_drugcue = pa_cue(:,2); pa_foodcue = pa_cue(:,3); pa_neutcue = pa_cue(:,4);


% craving (BAM response)
craving = getCueData(subjects,'craving');


% BAM q3 ("In the past 30 days, how many days have you felt depressed,
% anxious, angry or very upset throughout most of the day?") 
bam_upset = getBAMData(subjects,'q3');


% recent stim use
a1 = getBAMData(subjects,'q7c');
a2 = getBAMData(subjects,'q7d');
bam_stimuse = a1+a2;


% risky situations 
bam_riskysituations = getBAMData(subjects,'q11');


% BIS data
bis = getCueData(subjects,'bis');


% Kirby discounting 
Kirbyk = getCueData(subjects,'discount_rate');


% define table of behavioral predictors
Tbeh = table(pref_drug,pref_food,pref_neut,...
    pa_drug,pa_food,pa_neut,...
    pa_drugcue,pa_foodcue,pa_neutcue,...
    craving,bam_upset,bam_stimuse,bam_riskysituations,bis,Kirbyk);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% brain data

roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains'};

% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acing','ains','pvt'};

% stims = {'drugs','food','neutral','drugs-neutral','drugs-food'};
stims = {'drugs','food','neutral'};


bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names


%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tcPath = fullfile(dataDir,['timecourses_' task '_afni'],'%s','%s.csv'); %s is roiNames, stims
% tcPath = fullfile(dataDir,['timecourses_' task '_afni_woOutliers'],'%s','%s.csv'); %s is roiNames, stims

TRs = [3:7];
aveTRs = [3:5]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)

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
 
betaPath = fullfile(dataDir,['results_' task '_afni'],'roi_betas','%s','%s.csv'); %s is roiName, stim

for j=1:numel(roiNames)

      for k = 1:numel(stims)
          
          this_bfile = sprintf(betaPath,roiNames{j},stims{k}); % this beta file path
          if exist(this_bfile,'file')
              B = loadRoiTimeCourses(this_bfile,subjects);
              bd = [bd B];
              bdNames = [bdNames [roiVarNames{j} '_' strrep(stims{k},'-','') '_beta']];
          end
            
      end % stims
      
end % roiNames

% brain data
Tbrain = array2table(bd,'VariableNames',bdNames);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate relapse, demographic, behavioral, & brain data into 1 table

% subject ids
subjid = cell2mat(subjects);
Tsubj = table(subjid);


% concatenate all data into 1 table
T=table();
T = [Tsubj Trelapse Tdem Tbeh Tbrain];


% save out
writetable(T,outPath); 

% done 












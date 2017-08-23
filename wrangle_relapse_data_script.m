% save out predictors for cue relapse prediction 


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

subjects = getCueSubjects('cue',1); % stim patients


% filepath for saving out table of variables
outPath = fullfile(dataDir,'relapse_data',['relapse_data_' datestr(now,'yymmdd') '.csv']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relapse vars

relapse = getCueData(subjects,'relapse');
days2relapse = getCueData(subjects,'days2relapse');

Trelapse = table(relapse,days2relapse);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% demographic & clinical vars

demVars = {'years_of_use',...
    'days_sober',...
    'poly_drug_dep',...
    'smoke',...
    'depression_diag',...
    'ptsd_diag',...
    'education'};

Tdem = table(); % table of demographic data
for i=1:numel(demVars)
    Tdem=[Tdem array2table(getCueData(subjects,demVars{i}),'VariableNames',demVars(i))];
end


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
bamq3 = getBAMData(subjects,'q3');


% recent stim use
a1 = getBAMData(subjects,'q7c');
a2 = getBAMData(subjects,'q7d');
bamstimuse = a1+a2;


% risky situations 
bamq11 = getBAMData(subjects,'q11');


% BIS data
bis = getCueData(subjects,'bis');


% define table of behavioral predictors
Tbeh = table(pref_drug,pref_food,pref_neut,...
    pa_drug,pa_food,pa_neut,...
    pa_drugcue,pa_foodcue,pa_neutcue,...
    craving,bamq3,bamstimuse,bamq11,bis);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% brain data

roiNames = {'nacc','mpfc','VTA','VTA_clust','vstriatumL_clust','vstriatumR_clust'};
roiVarNames = {'nacc','mpfc','vta','VTA_clust','vsL_clust','vsR_clust'};

stims = {'drugs','food','neutral','drugs-neutral','drugs-food'};

tcPath = fullfile(dataDir,'timecourses_cue_afni','%s','%s.csv'); %s is roiNames, stims

TRs = [5:7];

tcNames = {}; tc = [];
for j=1:numel(roiNames)
    for k = 1:numel(stims)
        % if there's a minus sign, assume desired output is stim1-stim2
        if strfind(stims{k},'-')
            stim1 = stims{k}(1:strfind(stims{k},'-')-1);
            stim2 = stims{k}(strfind(stims{k},'-')+1:end);
            thistc1=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim1),subjects,TRs);
            thistc2=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim2),subjects,TRs);
            thistc=thistc1-thistc2;
        else
            thistc=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stims{k}),subjects,TRs);
        end
        tc = [tc thistc mean(thistc,2)];
        for ti = 1:numel(TRs)
            tcNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' num2str(TRs(ti))];
        end
        tcNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TRmean'];
    end
end


% brain data
Tbrain = array2table(tc,'VariableNames',tcNames);



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












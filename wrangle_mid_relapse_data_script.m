% save out predictors for cue relapse prediction 


clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

task = 'mid';

% group = 'patients';
group = '';

[subjects,gi] = getCueSubjects(task,group); 


% filepath for saving out table of variables
% outPath = fullfile(dataDir,'relapse_data',['relapse_data_' datestr(now,'yymmdd') '_allsubs.csv']);
outPath = fullfile(dataDir,'relapse_data',['relapse_data_' task '_' datestr(now,'yymmdd') '.csv']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%% other non-stimulant drug use (alcohol, cannabis, etc.)

% responses from followup BAM(s) regarding past month use (yes or no) of 
% substances other than stimulants
% 
% duVarStrs = {'alcuse','bingealcuse','thcuse','sedativeuse','opiateuse',...
%     'inhalantuse','otherdruguse'};
% qStrs = {'q4','q5','q7a','q7b','q7e','q7f','q7g'}; % question numbers corresponding to above variables
% 
% du = zeros(numel(subjects),numel(duVarStrs)); % drug use matrix
% 
% d=getBAMFollowupData(); % BAM from followups 
% header=d(1,:);
% d(1,:)=[];
% subjs=d(:,1);

% % omit responses from last follow-up (only look at responses from 1-month
% and 3 months post-treatment)
% ci = find(strcmp('Followup number',header)); % column index
% thisd=str2num(cell2mat(d(:,ci)));
% omitidx=find(thisd>2)
% d(omitidx,:)=[];
% subjs(omitidx)=[];

% for q=1:numel(qStrs)
%     ci = find(strcmp(qStrs{q},header)); % column index
%     thisd=str2num(cell2mat(d(:,ci)));
%     thesesubjs=unique(subjs(find(thisd>1)));
%     for s=1:numel(thesesubjs)
%         du(ismember(subjects,thesesubjs{s}),q)=1;
%     end
% end
% 
% duVarStrs=cellfun(@(x) ['post3mos_' x], duVarStrs,'uniformoutput',0);
% Totherdruguse = array2table(du,'VariableNames',duVarStrs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% brain data
% 
% % roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};
% % roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','pvt','dlpfc','dlpfcL','dlpfcR','ifgL','ifgR','vlpfcL','vlpfcR'};
% 
% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','ins_desai','insL_desai','insR_desai'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','ains','ainsL','ainsR'};
% 
% % roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','PVT'};
% % roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acing','ains','pvt'};
% 
% % stims = {'drugs','food','neutral','drugs-neutral','drugs-food'};
% stims = {'alcohol','drugs','food','neutral'};
% 
% 
% bd = [];  % array of brain data values
% bdNames = {};  % brain data predictor names
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tcPath = fullfile(dataDir,['timecourses_' task '_afni'],'%s','%s.csv'); %s is roiNames, stims
% % % tcPath = fullfile(dataDir,['timecourses_' task '_afni_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
% % 
% TRs = [3:7];
% aveTRs = []; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
% % 
% for j=1:numel(roiNames)
%          
%     for k = 1:numel(stims)
%         
%         % if there's a minus sign, assume desired output is stim1-stim2
%         if strfind(stims{k},'-')
%             stim1 = stims{k}(1:strfind(stims{k},'-')-1);
%             stim2 = stims{k}(strfind(stims{k},'-')+1:end);
%             thistc1=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim1),subjects,TRs);
%             thistc2=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim2),subjects,TRs);
%             thistc=thistc1-thistc2;
%         
%         % otherwise just load stim timecourses
%         else
%             thistc=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stims{k}),subjects,TRs);
%         end
%         bd = [bd thistc];
%         
%         % update var names
%         for ti = 1:numel(TRs)
%             bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' num2str(TRs(ti))];
%         end
%         
%         % if averaging over TRs is desired, include it
%         if ~isempty(aveTRs)
%             bd = [bd mean(thistc(:,aveTRs),2)];
%             bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' strrep(num2str(TRs(aveTRs)),' ','') 'mean'];
%         end
%             
%     end % stims
%    
% end % rois
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI BETAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%  
% betaPath = fullfile(dataDir,['results_' task '_afni'],'roi_betas','%s','%s.csv'); %s is roiName, stim
% 
% for j=1:numel(roiNames)
% 
%       for k = 1:numel(stims)
%           
%           this_bfile = sprintf(betaPath,roiNames{j},stims{k}); % this beta file path
%           if exist(this_bfile,'file')
%               B = loadRoiTimeCourses(this_bfile,subjects);
%               bd = [bd B];
%               bdNames = [bdNames [roiVarNames{j} '_' strrep(stims{k},'-','') '_beta']];
%           end
%             
%       end % stims
%       
% end % roiNames
% 
% % brain data
% Tbrain = array2table(bd,'VariableNames',bdNames);
% 
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate relapse, demographic, behavioral, & brain data into 1 table

% subject ids
subjid = cell2mat(subjects);
Tsubj = table(subjid);
Tgi=table(gi);

% concatenate all data into 1 table
T=table();
% T = [Tsubj Trelapse Tdem Tbeh Tbrain Totherdruguse];
T = [Tsubj Tgi Trelapse Tdem Tbam];

% save out
writetable(T,outPath); 

% done 












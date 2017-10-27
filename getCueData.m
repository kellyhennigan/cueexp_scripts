function data = getCueData(subjects,measure)
% -------------------------------------------------------------------------
% usage: catch-all function for loading data from the cue fmri experiment.
%
% INPUT:
%   subjects - cell array of subject ids to return scores for
%   measure - string specifying the desired measure to return scores for
%
% OUTPUT:
%   data - subject scores for the desired measure
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 20-Apr-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check inputs
if notDefined('subjects')
    subjects = {};
end

if notDefined('measure')
    measure = 'null';
end

% make sure input var subjects is a cell array
if ischar(subjects)
    subjects = splitstring(subjects);
end

measure = lower(measure); % make sure measure string is all lower case

data = [];

%% various measures to return:

switch measure
    
    
    case 'age'
        
        data = getAge(subjects);
        
        
    case 'gender'
        
        data = getGender(subjects);
        
        
    case 'bdi'
        
        data = getBDIScores(subjects);
        
        
    case {'bis','bis_attn','bis_motor','bis_nonplan'}
        
        data = getBISScores(subjects,measure);
        
    case 'discount_rate'
        
        % which method for fitting k? Either MLE or Kirby
%         fitk_method = 'Kirby';
 fitk_method = 'MLE';
        
        data = getDiscountingK(subjects,fitk_method); % returns discounting param, k
        
        
    case {'race','ethnicity'}
        
        data = getRace(subjects);
        
        
    case 'smoke'
        
        data = getSmokers(subjects);
        data = data{1}; % 1 for yes, 0 for no
        
        
    case 'smokeperday'
        
        data = getSmokers(subjects);
        data = data{2}; % cell array of strings describing how much smoking per day
        
        
    case 'education'
        
        data = getEducation(subjects);
        data = data{1}; % just return the quantitative var
        
        
    case 'relapse'
        
        [ri,days2relapse,notes]=getCueRelapseData(subjects);
        data = ri;
        
        
    case 'relapse_6months'
        
        [ri,days2relapse,notes]=getCueRelapseData(subjects);
        ri(days2relapse>200) = 0; % set relapse to 0 if it occurred >200 days after participation
        data = ri;
        
        
    case 'days2relapse'
        
        [ri,days2relapse,notes]=getCueRelapseData(subjects);
        data = days2relapse;
        
        
    case {'dop','for_admit_date','for_discharge_date',...
            'first_use_date','most_recent_use_date','primary_stim',...
            'alc_dep','other_drug_dep',...
            'depression_diag','ptsd_diag','other_diag',...
            'meds','dop_drugtest',...
            'days_sober','days_in_rehab','years_of_use'}
        
        data = getPatientData(subjects,measure);
        
        
    case 'poly_drug_dep'
        
        % if dependent on a substance other than stim, (alc or
        % otherwise), classify as polydrug dep
        alc = getPatientData(subjects,'alc_dep');
        
        other_drug = getPatientData(subjects,'other_drug_dep');
        other_drug = cell2mat(cellfun(@(x) str2double(x), other_drug,'uniformoutput',0)); % 0=no other drug, nan=dep on another drug
        other_drug(isnan(other_drug))=1;
        
        % data returns 1 if dependent on alc and/or drug in addition to
        % stim; otherwise 0
        data = alc;
        data(other_drug==1)=1;
        
        
    case 'craving'
        
        qStr = 'q8';
        data = getBAMData(subjects,qStr);
        
        
    case {'pref_stim','pref_alc','pref_drug','pref_food','pref_neut'}
        
        % define path to subject stim file(s)
        p = getCuePaths();
        stimfilepath = cellfun(@(x) sprintf(fullfile(p.data, '%s/behavior/cue_matrix.csv'),x), subjects, 'uniformoutput',0);
        
        % load pref ratings
        [~,~,~,~,~,trial_type,~,~,choice_num]=cellfun(@(x) getCueTaskBehData(x,'short'),...
            stimfilepath, 'uniformoutput',0);
        
        % get matrix of pref & mean pref ratings by trial type w/subjects in rows
        pref = cell2mat(choice_num')';  % pref ratings for each item
        pref_stim = [];
        for i=1:numel(subjects)
            for j=1:4 % # of trial types
                pref_stim(i,j) = nanmean(choice_num{i}(trial_type{i}==j));
            end
        end
        
        % return mean pref ratings for all stim or a specific condition
        switch measure
            
            case 'pref_alc'
                data = pref_stim(:,1); % alcohol is 1st col
            case 'pref_drug'
                data = pref_stim(:,2); % drugs are 2nd col
            case 'pref_food'
                data = pref_stim(:,3); % food is 3rd col
            case 'pref_neut'
                data = pref_stim(:,4); % neutral is 4th col
            otherwise
                data = pref_stim; % return mean pref for all stim types
        end
        
        
    case {'pa_cue','na_cue'}
        
        % define path to stim file(s)
        p = getCuePaths();
        stimfilepath = cellfun(@(x) sprintf(fullfile(p.data, '%s/behavior/cue_ratings.csv'),x), subjects, 'uniformoutput',0);
        
        % load cue pa and na ratings
        [cue_type,pa,na] = cellfun(@(x) getCueVARatings(x), stimfilepath,'uniformoutput',0);
        pa = cell2mat(pa); na = cell2mat(na);
        
        % return mean pref ratings for all stim or a specific condition
        switch measure
            case 'pa_cue'
                data = pa;
            case 'na_cue'
                data = na;
        end
        
        
    case {'pa_stim','na_stim'}
        
        [pa,na] = getStimPANA(subjects);
        
        if strcmp(measure,'pa_stim')
            data = pa;
        elseif strcmp(measure,'na_stim')
            data = na;
        end
        
        
    otherwise
        
        % print out a list of all possible measure options
        C = getCases; % == {'1' '2' '3'}
        C=C'; C=strrep(C,'{','');C=strrep(C,'}','');
        mlist = []; % measure options list
        for i=1:numel(C)
            thisC=C(i);
            if strfind(thisC{1},',')
                thisC=splitstring(thisC{1},',');
            end
            for ii=1:numel(thisC)
                mlist = [mlist sprintf('%s\n',thisC{ii})];
            end
        end
        disp(sprintf('current measure options are:\n%s\n',mlist));
        data=nan(numel(subjects),1);
        
end % switch measure


end % getCueData



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% internal functions to get the measures:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get subject age
function age = getAge(subjects)

age = []; % var to populate with subjects' age

docid = '1wcYTCKhouZ8Cf8omTFQMkekxcJn0lVBKi9ApPHTR3ak'; % doc id for google sheet w/relapse data

% try to load spreadsheet; if it can't be loaded, return age var as empty
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'returning age var as empty...']);
    return
    
end

% assuming spreadsheet is loaded, get desired data
cj = find(strncmp(d(1,:),'age',3)); % column with age data

for i=1:numel(subjects)
    
    ri=find(strncmp(d(:,1),subjects{i},8)); % row w/this subject's data
    
    if isempty(ri)
        age(i,1) = nan;
    else
        age(i,1) = str2double(d{ri,cj});
    end
    
end

end % getAge()



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get subject age
function gender = getGender(subjects)

gender = nan(numel(subjects),1); % var to populate with subjects' age

docid = '1wcYTCKhouZ8Cf8omTFQMkekxcJn0lVBKi9ApPHTR3ak'; % doc id for google sheet w/relapse data

% try to load spreadsheet; if it can't be loaded, return age var as empty
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'returning age var as empty...']);
    return
    
end

% assuming spreadsheet is loaded, get desired data
cj = find(strncmp(d(1,:),'gender',6)); % column with gender data

for i=1:numel(subjects)
    
    ri=find(strncmp(d(:,1),subjects{i},8)); % row w/this subject's data
    
    if isempty(ri)
        gChar(i,1) = nan;
    else
        gChar(i,1) = d{ri,cj};
    end
    
end

gender(gChar=='F')=0;
gender(gChar=='M')=1;


end % getGender()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get BDI scores
function scores = getBDIScores(subjects)

% reference: ??

docid = '1MMYSVW6Grd4sEiw4g2Q1lFFob6Pc3m4k8_vbMU5142U'; % doc id for google sheet w/relapse data

try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end

% if data is loaded, compute scores
if isempty(d)
    scores = [];
else
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,1),subjects{i},8));
        if isempty(idx)
            scores(i,1) = nan;
        else
            scores(i,1) = str2double(d{idx,end}); % last column of bdi has total bdi score
        end
    end % subjects
end

end % getBDIScores



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get BIS scores
function scores = getBISScores(subjects,measure)

% reference: Factor structure of the Barratt impulsiveness scale. Patton JH, Stanford MS, and Barratt ES (1995)
% Journal of Clinical Psychology, 51, 768-774.
% http://www.impulsivity.org/measurement/bis11


docid = '1gFcxI_1luO2TtOwwQRvm9F45qzHPThnKDBTaZm3esoo'; % doc id for google sheet w/relapse data


try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
    % if the google sheet couldn't be accessed, use these values (update as
    % often as possible):
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    
    % NOTE: ADD A WAY TO LOAD GSHEET WHEN OFFLINE HERE...
    %     d=...
    
    d={};
    
end

% if data is loaded, compute bis scores
if isempty(d)
    
    scores = [];
    
else
    
    
    % which items are reverse scored
    reverseArr = [1 7 8 9 10 12 13 15 20 29 30];
    
    attnArr = [5 6 9 11 20 24 26 28];
    motorArr = [2 3 4 16 17 19 21 22 23 25 30];
    nonplanArr = [1 7 8 10 12 13 14 15 18 27 29];
    
    
    for i=1:numel(subjects)
        
        idx=find(strncmp(d(:,1),subjects{i},8));
        
        if ~isempty(idx)
            
            item_scores = str2double(d(idx,2:end));
            item_scores(reverseArr) = 5-item_scores(reverseArr); % reverse score for certain items
            
            % occasionally, a subject will leave 1 question blank. If
            % that's the case, fill in that response with the median response from all the other questions
            if ~isempty(find(isnan(item_scores)))
                item_scores(isnan(item_scores))=nanmedian(item_scores);
            end
            
            bis_score(i,1) = sum(item_scores);
            attn_score(i,1) = sum(item_scores(attnArr));
            motor_score(i,1) = sum(item_scores(motorArr));
            nonplan_score(i,1) = sum(item_scores(nonplanArr));
            
        else
            
            bis_score(i,1) = nan;
            attn_score(i,1) = nan;
            motor_score(i,1) = nan;
            nonplan_score(i,1) = nan;
            
        end
        
    end
    
    switch measure
        
        case 'bis'
            
            scores=bis_score;
            
        case 'bis_attn'
            
            scores=attn_score;
            
        case 'bis_motor'
            
            scores=motor_score;
            
        case 'bis_nonplan'
            
            scores=nonplan_score;
            
    end
    
end

end % getBISScores()



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get discounting k param
function data = getDiscountingK(subjects,fitk_method)

% reference: https://www.phenxtoolkit.org/index.php?pageLink=browse.protocoldetails&id=530301

docid = '1a0nniGFsEm-CO8TSYkSLpRNnsB9O8gOe4BHqWMEj6G0'; % doc id for google sheet w/relapse data

try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end

% if data is loaded, compute scores
if isempty(d)
    choice = [];
else
    for i=1:numel(subjects)
        subjects{i}
        idx=find(strncmp(d(:,1),subjects{i},8));
        if isempty(idx)
            data(i,1) = nan;
        else
            
            choice = str2double(d(idx,2:end))';
            
            % if all choices are nan, set k to nan for this subject
            if all(isnan(choice))
                data(i,1) = nan;
            else
                
                SS = [30 40 67 34 15 32 83 21 48 40 25 65 24 30 53 47 40 50 45 27 16]';
                LL = [85 55 85 35 35 55 85 30 55 65 35 75 55 35 55 60 70 80 70 30 30]';
                delay = [14 25 35 43 10 20 35 75 45 70 25 50 10 20 55 50 20 70 35 35 35]';
                
                % estimate discounting param k using either Kirby or MLE method
                if strcmp(fitk_method,'Kirby')
                    choice(choice==2)=0; % LL choices need to be coded as 0
                    [k, nInconsistent, sorted_data] = FitK_Kirby(SS,LL,delay,choice);
                elseif strcmp(fitk_method,'MLE')
                    [k, m, LL] = FitK([SS zeros(numel(delay),1) LL delay choice]);
                end
                data(i,1) = k;
                
            end
            
        end % isempty(idx)
        
    end % subjects
    
end % isempty(d)

end % getDiscountingK


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get subject race/ethnicity
function racecat = getRace(subjects)

p = getCuePaths();
a = dir(fullfile(p.data,'qualtrics_data','Post_Scan_Survey_*.csv'));
fp = fullfile(p.data,'qualtrics_data',a(end).name); % most recent q data file

d=getQualtricsData(fp,subjects);

racecat = getNIHRaceCategories(d.classify);

% NIH categories:
%     1= American indian/alaska native
%     2= Asian
%     3= Black
%     4= Hispanic/Latino
%     5= Native Hawaiian or Pacific Islander
%     6= White
%     7= Multiracial
%     8= Would rather not say

end % getRace()



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get subject smoking data
function smoke = getSmokers(subjects)

p = getCuePaths();
a = dir(fullfile(p.data,'qualtrics_data','Post_Scan_Survey_*.csv'));
fp = fullfile(p.data,'qualtrics_data',a(end).name); % most recent q data file

d=getQualtricsData(fp,subjects);

smoke{1} = d.smoke;

smoke{2} = d.smoke_perday;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get subject education data
function education = getEducation(subjects)

p = getCuePaths();
a = dir(fullfile(p.data,'qualtrics_data','Post_Scan_Survey_*.csv'));
fp = fullfile(p.data,'qualtrics_data',a(end).name); % most recent q data file

d=getQualtricsData(fp,subjects);

education{1} = d.education;
education{2} = d.education2;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get subject education data
function [stim_pa,stim_na] = getStimPANA(subjects)


% define path to stim file(s)
p = getCuePaths();
a = dir(fullfile(p.data,'qualtrics_data','Post_Scan_Survey_*.csv'));
fp = fullfile(p.data,'qualtrics_data',a(end).name); % most recent q data file

[~,pa,na,~,qimage_type]=getQualtricsData(fp,subjects);

stim_pa = []; stim_na = [];
for j=1:4 % # of trial types
    stim_pa(:,j) = nanmean(pa(:,qimage_type==j),2);
    stim_na(:,j) = nanmean(na(:,qimage_type==j),2);
end


end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get more patient data
% function data = getPatientData(subjects,measure)
%
% if ischar(subjects)
%     subjects = splitstring(subjects);
% end
%
%
% data = [];
%
%
% docid = '1VdKlBKezHcz4VL93ouglqD1bpr7aTo2RGtEXUsyHNGI'; % doc id for google sheet w/relapse data
% try
%     d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
%
%
%     % if the google sheet couldn't be accessed, use these values (update as
%     % often as possible):
% catch
%     warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
%         'Using hard coded values that may not be the most updated...'])
%
%     return
%
% end
%
% % assuming spreadsheet is loaded, column index (cj) for desired data
% switch measure
%
%     case 'dop'
%         cj = find(strncmp(d(1,:),'DOP',3));
%     case 'for_admit_date'
%         cj = find(strncmp(d(1,:),'date of FOR admit',17));
%     case 'for_discharge_date'
%         cj = find(strncmp(d(1,:),'date of FOR discharge',21));
%     case 'first_use_date'
%         cj = find(strncmp(d(1,:),'date of first stim',18));
%     case 'most_recent_use_date'
%         cj = find(strncmp(d(1,:),'most recent stim',16));
%     case 'primary_stim'
%         cj = find(strncmp(d(1,:),'primary stim',12));
%     case 'alc_dep'
%         cj = find(strncmp(d(1,:),'alcohol',7));
%     case 'other_drug_dep'
%         cj = find(strncmp(d(1,:),'other drug',10));
%     case 'depression_diag'
%         cj = find(strncmp(d(1,:),'depression diag',15));
%     case 'ptsd_diag'
%         cj = find(strncmp(d(1,:),'PTSD diag',9));
%     case 'other_diag'
%         cj = find(strncmp(d(1,:),'other diag',10));
%     case 'meds'
%         cj = find(strncmp(d(1,:),'med',3));
%     case 'dop_drugtest'
%         cj = find(strncmp(d(1,:),'results',7));
%     case 'days_sober'
%         cj = find(strncmp(d(1,:),'days sober prior to DOP',23));
%     case 'days_in_rehab'
%         cj = find(strncmp(d(1,:),'days in rehab prior to DOP',26));
%     case 'years_of_use'
%         cj = find(strncmp(d(1,:),'years of use',12)); % column with desired data
% end
%
%
% for i=1:numel(subjects)
%
%     ri=find(strncmp(d(:,1),subjects{i},8)); % row w/this subject's data
%
%     if isempty(ri)
%         data{i,1} = nan;
%     else
%         thisd = d{ri,cj};
%         if isempty(thisd)
%             data{i,1} = nan;
%         else
%             data{i,1} = d{ri,cj};
%         end
%     end
%
% end
%
% % convert from cell array of strings to numeric vector for numeric vars
% if any(strcmpi(measure,{'alc_dep','days_sober','days_in_rehab','years_of_use'}))
%     data=cell2mat(cellfun(@(x) str2double(x), data,'uniformoutput',0));
% end
%
% end % getPatientData





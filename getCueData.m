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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make sure input var subjects is a cell array
if ischar(subjects)
    subjects = splitstring(subjects);
end

data = [];


%% various measures to return:

switch lower(measure)
    
    
    case 'age'
        
        data = getAge(subjects);
        
  
    case 'gender'
        
        data = getGender(subjects);
        
        
    case {'bis','bis_attn','bis_motor','bis_nonplan'}
        
        data = getBISScores(subjects,measure);
        
        
    case 'relapse'
        
        [ri,time2relapse]=getCueRelapseData(subjects);
        
        data = [ri,time2relapse];
        
    otherwise
        
        fprintf(['\ncurrently no function exists to get ' measure ' variable.\n' ...
            'add functionality or ask for something else.\n\n'])
        
end


end % getCueData


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
            
            % compute subject scores for bis & subscales
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
    
    switch lower(measure)
        
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





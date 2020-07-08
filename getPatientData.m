
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get more patient data
function data = getPatientData(subjects,measure)
% function data = getPatientData(subjects,measure)
% -------------------------------------------------------------------------
% usage: load patient data from googlesheet
% 
% INPUT:
%   subjects - cell array of subject ids to return data for 
%   measure - string specifying what measure to return
% 
% OUTPUT:
%   data - data from spreadsheet for desired subjects
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 13-Sep-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ischar(subjects)
    subjects = splitstring(subjects);
end


data = [];


docid = '1VdKlBKezHcz4VL93ouglqD1bpr7aTo2RGtEXUsyHNGI'; % doc id for google sheet w/relapse data
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
    
    % if the google sheet couldn't be accessed, use these values (update as
    % often as possible):
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using hard coded values that may not be the most updated...'])
    
    return
    
end

% assuming spreadsheet is loaded, column index (cj) for desired data
switch measure
    
    case 'dop'
        cj = find(strncmp(d(1,:),'DOP',3));
    case 'admit_date'
        cj = find(strncmp(d(1,:),'date of treatment admit',23));
    case 'discharge_date'
        cj = find(strncmp(d(1,:),'date of treatment discharge',27));
    case 'first_use_date'
        cj = find(strncmp(d(1,:),'date of first stim',18));
    case 'most_recent_use_date'
        cj = find(strncmp(d(1,:),'most recent stim',16));
    case 'primary_stim'
        cj = find(strncmp(d(1,:),'primary stim',12));
    case 'alc_dep'
        cj = find(strncmp(d(1,:),'alcohol',7));
    case 'other_drug_dep'
        cj = find(strncmp(d(1,:),'other drug',10));
  
    
        %%%%%%%%% to get depression, anxiety, PTSD, other diag, and medications
        %%%%%%%%% from screening form:
%     case 'depression_diag'
%         cj = find(strncmp(d(1,:),'depression (from screening form)',32));
%     case 'anxiety_diag'
%         cj = find(strncmp(d(1,:),'anxiety (from screening form)',29));
%     case 'ptsd_diag'
%         cj = find(strncmp(d(1,:),'PTSD (from screening form)',26));
%     case 'other_diag'
%         cj = find(strncmp(d(1,:),'other diag (from screening form)',32));
%     case 'meds'
%         cj = find(strncmp(d(1,:),'meds (from screening form)',26));
%         
        
%         %%%%%%%%% to get depression, anxiety, PTSD, other diag, and
%         %%%%%%%%% medications from VA records:
    case 'depression_diag'
        cj = find(strncmp(d(1,:),'depression (VA records)',23));
    case 'anxiety_diag'
        cj = find(strncmp(d(1,:),'anxiety (VA records)',20));
    case 'ptsd_diag'
        cj = find(strncmp(d(1,:),'PTSD (VA records)',17));
    case 'other_diag'
        cj = find(strncmp(d(1,:),'other diag (VA records)',23));
    case 'meds'
        cj = find(strncmp(d(1,:),'meds (VA records)',17));
   
    case 'post_for_treatment'
        cj = find(strncmp(d(1,:),'post FOR sober living program',29));
        
    case 'dop_drugtest'
        cj = find(strncmp(d(1,:),'results',7));
    case 'days_sober'
        cj = find(strncmp(d(1,:),'days sober prior to DOP',23));
    case 'days_in_rehab'
        cj = find(strncmp(d(1,:),'days in rehab prior to DOP',26));
    case 'years_of_use'
        cj = find(strncmp(d(1,:),'years of use',12)); % column with desired data
   
    
    %% data from Claudia (10/1/18)
    
    case 'auditscore4orgreater'
        cj = find(strncmp(d(1,:),'AUDIT-C >/= 4',13)); % column with desired data
    case 'courtmandated'
        cj = find(strncmp(d(1,:),'Court mandated?',15)); % column with desired data
    case 'opioidusedisorder'
        cj = find(strncmp(d(1,:),'opioid use disorder?',20)); % column with desired data
    case 'cannabisuse'
        cj = find(strncmp(d(1,:),'cannabis use?',13)); % column with desired data
    
    otherwise
        fprintf(['\ndesired measure input: ' measure ' isnt recognized...\n'])
        
        return
end


for i=1:numel(subjects)
    
    ri=find(strncmp(d(:,1),subjects{i},8)); % row w/this subject's data
    
    if isempty(ri)
        data{i,1} = nan;
    else
        thisd = d{ri,cj};
        if isempty(thisd)
            data{i,1} = nan;
        else
            data{i,1} = d{ri,cj};
        end
    end
    
end
  
% convert from cell array of strings to numeric vector for numeric vars
if any(strcmpi(measure,{'alc_dep','days_sober','days_in_rehab','years_of_use','post_for_treatment',...
        'auditscore4orgreater','courtmandated','opioidusedisorder','cannabisuse'}))
    data=cell2mat(cellfun(@(x) str2double(x), data,'uniformoutput',0));
end

% % binarize anxiety, depression, and/or PTSD diagnosis vars
if any(strcmpi(measure,{'anxiety_diag','ptsd_diag','depression_diag'}))
    data=strcmp(data,'yes');
end


end % getPatientData

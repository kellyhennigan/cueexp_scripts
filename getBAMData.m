function data = getBAMData(subjects,qStr)
% -------------------------------------------------------------------------
% usage: load patients' BAM responsese 
% 
% INPUT:
%   subjects - cell array of subject ids
%   qStr - questions to return responses for 
% 
% OUTPUT:
%   data
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 11-Aug-2017
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ischar(subjects)
    subjects = splitstring(subjects);
end


data = [];


docid = '1522nHixYyE_kjxMbAX_BbHAKNVsTRjZbUCmIZqKl0Dw'; % doc id for google sheet w/relapse data
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
    
    % if the google sheet couldn't be accessed, use these values (update as
    % often as possible):
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using hard coded values that may not be the most updated...'])
    
    return
    
end

% assuming spreadsheet is loaded, get data for desired question
cj = find(strcmp(d(1,:),qStr)); % column with desired data


for i=1:numel(subjects)
    
    ri=find(strncmp(d(:,1),subjects{i},8)); % row w/this subject's data
    
    if isempty(ri)
        data(i,1) = nan;
    else
        thisd = str2num(d{ri,cj}); % this subject's response to this question
        if isempty(thisd)
            data(i,1) = nan;
        else
            data(i,1) = str2num(d{ri,cj});
        end
    end
    
end

end % getPatientData

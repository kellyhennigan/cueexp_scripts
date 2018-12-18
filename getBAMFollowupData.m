function data = getBAMFollowupData(subjects)
% -------------------------------------------------------------------------
% usage: load patients' BAM responsese 
% 
% INPUT:
%   subjects - OPTIONAL cell array of subject ids
% 
% OUTPUT:
%   data
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 11-Aug-2017
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 

if notDefined('subjects')
   subjects='all';
end

if ischar(subjects)
    subjects = splitstring(subjects);
end


data = [];


docid = '1QZEj1yWkU-BGdIkRDQ7vqriwusYxQ9C9TVGAb5U-ZhY'; % doc id for google sheet w/relapse data
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
    
    % if the google sheet couldn't be accessed, use these values (update as
    % often as possible):
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using hard coded values that may not be the most updated...'])
    
    return
    
end

% fill in all blank values with 0 (this is a hack to make things work
% better - know that any value of 0 means that the question wasnt
% answered!!!
for di=1:numel(d)
    if isempty(d{di}) 
        d{di}='0';
    elseif isnan(str2num(d{di}))
        d{di}='0';
    end
end
% 
% % assuming spreadsheet is loaded, get data for desired question
% cj = find(strcmp(d(1,:),qStr)); % column with desired data
% 
% 

if strcmp(subjects{1},'all')
    data=d;
    
else
    
    data=d(1,:); % get header
    for i=1:numel(subjects)
        
        ri=find(strncmp(d(:,1),subjects{i},8)); % row w/this subject's data
        
        data = [data; d(ri,:)];
        
    end
end
   

% end % getPatientData

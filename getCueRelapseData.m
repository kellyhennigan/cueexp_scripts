function [ri,days2relapse,notes]=getCueRelapseData(subjects)
% -------------------------------------------------------------------------
% usage: get relapse index for patients from cue fmri experiment.
%
% INPUT:
%   subjects - cell array with subject ids strings of subjects to return
%   relapse index for
%
%
% OUTPUT:
%   ri - index of ones and zeros indicating relapse (1) or non-relapse (0)
%   relapseDate - date of relapse
%   notes - any notes written in spreadsheet

% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 06-Sep-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ischar(subjects)
    subjects = splitstring(subjects);
end

ri = []; % relapse index
days2relapse=[]; % days until relapse event
notes = {}; % subj notes

docid = '1_6dQvMQQuLPFo8ciPSvaaOAcW3RrGHtzpx3uX3oaHWk'; % doc id for google sheet w/relapse data

% try to load spreadsheet; if it can't be loaded, return age var as empty
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'returning output as empty...']);
    return
    
end


% find columns with desired data
cj = find(strncmp(d(1,:),'Relapse',7));
cj_days2relapse = find(strncmp(d(1,:),'days to relapse',15));
cj_notes = find(strncmp(d(1,:),'notes',5));


for i=1:numel(subjects)
    
    
    % get row with this subject id
    idx=find(ismember(d(:,1),subjects{i}));
    
    % if cant find subject id, assign vals to nan
    if isempty(idx)
        ri(i,1) = nan;
        days2relapse(i,1) = nan;
        notes{i,1} = '';
        
        
    else
        
        %  if there's no entered data for this subject, assign vals to nan;
        %         otherwise, get subject's data
        if isempty(d{idx,cj})
            ri(i,1) = nan;
        else
            ri(i,1) = str2num(d{idx,cj});
        end
        
        %  do the same for relapse date
        if isempty(d{idx,cj_days2relapse})
            days2relapse(i,1) = nan;
        else
            days2relapse(i,1) = str2num(d{idx,cj_days2relapse});
        end
        
        %  do the same for notes
        if isempty(d{idx,cj_notes})
            notes{i,1} = '';
        else
            notes{i,1} = d{idx,cj_notes};
        end
        
    end % isempty(idx)
    
    
end % subj loop

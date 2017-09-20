function [obstime,censored,notes]=getCueRelapseSurvival(subjects)
% -------------------------------------------------------------------------
% usage: get relapse data formatted for survival analysis.
%
% INPUT:
%   subjects - cell array with subject ids strings of subjects to return
%              relapse data for
%
%
% OUTPUT:
%   obstime - observed time; this is either days2relapse, or if they didn't
%             relapse, date of last followup
%   censored - 1 if no relapse recorded; otherwise 0
%   notes - any notes written in spreadsheet

% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 06-Sep-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ischar(subjects)
    subjects = splitstring(subjects);
end

obstime = []; % observed time
censored = []; % 1 if NO relapse, otherwise 0
notes = {}; % subj notes


%%
docid = '1_6dQvMQQuLPFo8ciPSvaaOAcW3RrGHtzpx3uX3oaHWk'; % doc id for google sheet w/relapse data


% try to load spreadsheet; if it can't be loaded, return age var as empty
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'returning output as empty...']);
    return
    
end


%% get useful data columns from array


cj_relapse = find(strncmp(d(1,:),'Relapse',7));
cj_days2relapse = find(strncmp(d(1,:),'days to relapse',15));
cj_lastfollowup = find(strncmp(d(1,:),'last',4));
cj_notes = find(strncmp(d(1,:),'notes',5));




%% get desired data for desired subjects

for i=1:numel(subjects)
    
    
    % get row with this subject id
    idx=find(ismember(d(:,1),subjects{i}));
    
    % if cant find subject id, assign vals to nan
    if isempty(idx)
        
        obstime(i,1) = nan; % observed time
        censored(i,1) = nan; % 1 if NO relapse, otherwise 0
        notes{i,1} = ''; % subj notes
        
        
    else
        
        % get days 2 relapse for this subject
        days2relapse = str2num(d{idx,cj_days2relapse});
        
        % if days2relapse is negative, set it to 1 (this means that if a
        % subj relapsed before DOP, act as if they relapsed the day after)
        if days2relapse<0
            days2relapse = 1;
        end
        
        
        % if days2relapse = nan, that means we don't have a relapse event
        % recorded for them. Set obstime to date of last followup and set
        % censored to 1.
        if isnan(days2relapse)
            obstime(i,1) = str2num(d{idx,cj_lastfollowup});
            censored(i,1) = 1;
        else
            obstime(i,1) = days2relapse;
            censored(i,1) = 0;
        end
        
        notes{i,1} = d{idx,cj_notes};
        
    end
    
end % subj loop

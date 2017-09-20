function [tc,subjects]=loadRoiTimeCourses_old(filepath,subjects,TRs)
% usage: import time course data for cuefmri experiment
%
% INPUT:
%   filepath - string specifying path to csv file
%   subjects - cell array of subject id strings specifying which subjects
%              to return data for, or a string indicating which group to
%              return data for (i.e., 'controls' or 'patients'). If not
%              defined, all subjects will be returned.
%   TRs (optional) - integer specifying which TRs to return (e.g., [1:4]
%   will return TRs 1,2,3, and 4. Default is all TRs from each row (12).

% OUTPUT:
%   tc - roi time course data
%   subjects - corresponding subject ids

% note that if there isn't time course data for a specified subject, that
% nothing for that subject will be returned, and the subjects variable
% output will have omitted that subject.

% author: Kelly, kelhennigan@gmail.com, 30-Nov-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize variables


% if group isn't given, return data from all subjects in the text file
if notDefined('subjects')
    subjects = 'all';
end

% if TRs isn't given, return all the TRs per row by default
if notDefined('TRs')
    TRs = [1:12];
end
    

% if subjects is a string, assume its a group name
if isnumeric(subjects)
    subjects = num2str(subjects);
end
if ischar(subjects)
    if strncmpi(subjects,'controls',1) || strcmp(subjects,'0')
        subjects = getCueSubjects('',0);
    elseif strncmpi(subjects,'patients',1) || strcmp(subjects,'1')
        subjects = getCueSubjects('',1);
    elseif strncmpi(subjects,'alcpatients',3) || strcmp(subjects,'2')
        subjects = getCueSubjects_Claudia('cue');
    elseif strncmpi(subjects,'relapsers',3)
        subjects = getCueSubjects('',1);
        ri = getCueRelapseData(subjects);
        subjects = subjects(ri==1);
    elseif strncmpi(subjects,'non-relapsers',3)
        subjects = getCueSubjects('',1);
        ri = getCueRelapseData(subjects);
%        ri(isnan(ri))=0;
        subjects = subjects(ri==0);
        
    end
end



tc = [];  % time series
% subjects = []; % subjects
% gi = []; % group index


%% load the timecourses

% format spec
formatSpec = ['%s' repmat('%f',1,TRs(end)) '%[^\n\r]'];


% Open file, read data, then close it
fileID = fopen(filepath,'r');

% if fileID=-1, this means the file couldn't be opened. Return empty
% values.
if fileID==-1
    return
end

%  Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', ',',  'ReturnOnError', false);


% Close the text file.
fclose(fileID);


%%

% timecourse data
tc = [dataArray{2:end-1}];
tc = tc(:,TRs); % return only desired TRs
tc_subs = dataArray{1}; % subject ids from timecourse file

if strcmp(subjects,'all')
    subjects = tc_subs;
end

idx=ismember(tc_subs,subjects); % get index of rows for desired subjects' data

tc = tc(idx,:);

subjects = tc_subs(idx);

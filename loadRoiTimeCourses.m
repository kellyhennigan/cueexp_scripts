function [tc,subjects,gi]=loadRoiTimeCourses(filepath,group,nTRs)
% usage: import time course data for cuefmri experiment 
% 
% INPUT:
%   filepath - string specifying path to csv file 
%   group (optional) - 0 or 'controls' to return only controls, or
%                      1 or 'patients' to return only patients. Otherwise,
%                      all subjects will be returned.
%                      2 or 'alcpatients' to return only alcohol patients.
%   nTRs (optional) - integer specifying the # of TRs in the text file. 
%                     Default is 12.

% OUTPUT:
%   tc - roi time course data
%   subjects - corresponding subject ids 
%   gi - group index; 0 for controls and 1 for patients

% author: Kelly, kelhennigan@gmail.com, 30-Nov-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize variables 


% if group isn't given, return data from all subjects in the text file
if notDefined('group')
    group = 'all';
end
group = num2str(group); % make sure group is a string


% assume there are 12 TRs in time series
if notDefined('nTRs')
    nTRs = 12;
end

tc = [];  % time series
subjects = []; % subjects
gi = []; % group index 

%% Format specification 

formatSpec = ['%s' repmat('%f',1,nTRs) '%[^\n\r]'];


%% Open file, read data, then close it

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


%% create output variables 

subjects = dataArray{1};
tc = [dataArray{2:end-1}];

[all_subs,all_gi]=getCueSubjects; [all_subs2,all_gi2]=getCueSubjects_Claudia;
all_subs = [all_subs; all_subs2]; all_gi = [all_gi; all_gi2];

gi = all_gi(ismember(all_subs,subjects)); % return group index for subjects w/time course data


%% if group info is given, return data according to group input

% if desired, return only controls data
if strncmpi(group,'controls',1) || strcmp(group,'0') 
    subjects = subjects(gi==0);
    tc = tc(gi==0,:);
    gi = gi(gi==0);

% else if desired, return only patients data
elseif strncmpi(group,'patients',1) || strcmp(group,'1')
   subjects = subjects(gi==1);
    tc = tc(gi==1,:);
    gi = gi(gi==1);

% else if desired, return only alc_patients data
elseif strncmpi(group,'alcpatients',1) || strcmp(group,'2')
   subjects = subjects(gi==2);
    tc = tc(gi==2,:);
    gi = gi(gi==2);

    
end




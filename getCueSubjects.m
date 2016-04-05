function [subjects,group_idx,notes] = getCueSubjects(group)
% -------------------------------------------------------------------------
% usage: returns cell array with subject id strings for this experiment.
% NOTE: this assumes that there is a file named 'subjects' within the exp
% data folder that has a list of the subject ids and a group index (0 for
% controls, 1 for patients). 

% INPUT:
%   group (optional) - 0,'0', or 'controls', to return only subject ids
%   for control subjects; 1,'1', or 'patients' to return addict subject ids
%   to return subject
%       ids for; as of now, its all subjects or nothing.
%
% OUTPUT:
%   subjects - cell array of subject id strings for this experiment
%   group_idx(optional) - if desired, this returns a vector of 0s and 1s
%   indicating the group of the corresponding subject
%   notes - cell array of strings with notes on subjects

% notes:
%

% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if not provided as input, assume user wants all subjects
if notDefined('group')
    group = 'all';
end
group = num2str(group); % make sure group is a string


% get base directory address
baseDir = fullfile(getHomeDir,'cueexp');

% filename that contains a list of subjects and a group index number 
subject_filename = fullfile(baseDir, 'data','subjects');

fileID = fopen(subject_filename,'r');
dataArray = textscan(fileID, '%s%s%[^\n\r]', 'Delimiter', ',', 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);

% excluded commented out lines 
omit_idx = find(~cellfun(@isempty,strfind(dataArray{1},'#')));
if omit_idx
    dataArray{1}(omit_idx) = [];
    dataArray{2}(omit_idx) = [];
end

% define subject id cell array & vector of corresponding group indices
subjects = dataArray{1};
group_idx=str2num(cellfun(@(x) x(1), dataArray{2}));
notes = dataArray{2};


 
    
% return all subjects
if strcmpi(group,'all')
    subjects = subjects;
   
% return only controls
elseif strncmpi(group,'controls',1) || strcmp(group,'0') 
    subjects = subjects(group_idx==0);
    group_idx = group_idx(group_idx==0);
    
% return only patients
elseif  strncmpi(group,'patients',1) || strcmp(group,'1')
    subjects = subjects(group_idx==1);
    group_idx = group_idx(group_idx==1);
    
end






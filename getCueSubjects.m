function [subjects,gi,notes,exc_subj_notes] = getCueSubjects(task,group)
% -------------------------------------------------------------------------
% [subjects,gi,notes,exc_subj_notes] = getCueSubjects(task,group)
% usage: returns cell array with subject id strings for this experiment.
% NOTE: this assumes that there is a file named 'subjects' within the exp
% data folder that has a list of the subject ids and a group index (0 for
% controls, 1 for patients).

% INPUT: 2 optional inputs:
%   task - string that must be either 'cue','mid', or 'midi'. Default is
%   'cue'.
%   group - number specifying to return only subjects from a single group:
%         0, for control subs
%         1 for stimulant dependent patients
%         2 for alcohol dependent patients (eventually)
%
%
% OUTPUT:
%   subjects - cell array of subject id strings for this experiment
%   gi(optional) - if desired, this returns a vector of 0s and 1s
%   indicating the group of the corresponding subject
%   notes - cell array of strings with notes on subjects
%   exc_subj_notes - cell array showing subjects excluded and notes as to why

% notes:
%

% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% return all subjects if task isn't given as input
if notDefined('task')
    task = '';
end

% make group '' by default, which means return all
if notDefined('group')
    group = '';
end

% get subjects_list directory
subjListDir = fullfile(getHomeDir,'cueexp', 'data','subjects_list');

% filename that contains a list of subjects and a group index number
subject_filename = fullfile(subjListDir,'subjects');

fileID = fopen(subject_filename,'r');
d = textscan(fileID, '%s%s\n', 'Delimiter', ',', 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);


% define subject id cell array & vector of corresponding group indices
subjects = d{1};
gi=str2num(cellfun(@(x) x(1), d{2}));
notes = d{2};

% if task is defined, remove subjects to be excluded based on
% omit_subs_[task] file and get notes as to why they are being excluded
if isempty(task)
    exc_subj_notes = [];
    
else
    omit_subs_filename = fullfile(subjListDir, ['omit_subs_' task]);
    
    fileID = fopen(omit_subs_filename,'r');
    d = textscan(fileID, '%s%s%s\n', 'Delimiter', ',', 'HeaderLines' ,1, 'ReturnOnError', false);
    fclose(fileID);
    
    % get subj ids and notes for subjects to be excluded
    exc_subs = d{1};
    exc_subj_notes=[d{1} d{2}];
    
    for i=1:numel(exc_subs)
        gi(strcmp(subjects,exc_subs{i}))=[];
        notes(strcmp(subjects,exc_subs{i}))=[];
        subjects(strcmp(subjects,exc_subs{i}))=[];
    end
    
end


% now get only subjects from one specific group, if desired
if ~isempty(group)
    
    if group==0
        subjects = subjects(gi==0);
        notes = notes(gi==0);
        gi = gi(gi==0);
        
    elseif group==1
        subjects = subjects(gi==1);
        notes = notes(gi==1);
        gi = gi(gi==1);
        
    end
    
end

end






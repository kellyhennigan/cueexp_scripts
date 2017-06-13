function [p,task,subjects,gi]=whichCueSubjects(dset_str,task)
% -------------------------------------------------------------------------
% usage: % function to get user input to determine which subjects & task to
% process

% INPUT: 
%   dstr - (optional) dataset string of either 'stim' or 'alc' specifying
%   whether to use our data or Claudia's data

% OUTPUT:
%   p - structural array of project-specific paths (e.g., datadir, figdir, etc.)
%   task - which task to process
%   subjects - cell array of subjects to process
%   gi - group index of subjects gi=0 for controls, gi=1 for stim patients,
%        gi=2 for alc patients 

% 
% author: Kelly, kelhennigan@gmail.com, 03-May-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% which data set - ours or Claudia's? 

if notDefined('dset_str')
    fprintf('\n\nsubjects from: \n\t1) our data or \n\t2) Claudia''s data?\n\n');
    d = input('select 1 or 2: ');
    
elseif strcmpi(dset_str,'stim')
    d=1; % our data
    
elseif strcmpi(dset_str,'alc')
    d=2; % Claudia's data
   
end

% get paths for the appropriate dataset
if d==1
    p = getCuePaths;
elseif d==2
    p = getCuePaths_Claudia;
end




%% which task to process? 

if ~exist('task','var')
    fprintf('\n');
    task = input('cue, mid, midi, or dti (or just hit return for no task)? ','s');
end


%% which subjects to process? 

if d==1
    [task_subjects,task_gi] = getCueSubjects(task);
elseif d==2
    [task_subjects,task_gi] = getCueSubjects_Claudia(task);
end

fprintf('\n');
subj_list=cellfun(@(x) [x ' '], task_subjects, 'UniformOutput',0)';
disp([subj_list{:}]);

fprintf('\nwhich subjects to process? \n');
subjects = input('enter sub ids, or hit return for all subs above: ','s');

if isempty(subjects)
    subjects = task_subjects;
    gi = task_gi;
else
    subjects = splitstring(subjects)';
    for i=1:numel(subjects)
        gi(i,1) = task_gi(ismember(task_subjects,subjects{i}));
    end
end






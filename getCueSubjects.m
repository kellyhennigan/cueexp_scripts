function [subjects,gi] = getCueSubjects2(task,group)
% -------------------------------------------------------------------------
% [subjects,gi,notes,exc_subj_notes] = getCueSubjects(task,group)
% usage: returns cell array with subject id strings for this experiment.
% NOTE: this assumes that there is a file named 'subjects' within the exp
% data folder that has a list of the subject ids and a group index (0 for
% controls, 1 for patients).

% INPUT: 2 optional inputs:
%   task - string that must be either 'cue','mid', 'midi', or 'dti' or ''
%         (Default is '').
%   group - number or string specifying to return only subjects from a single group:
%         0 or 'controls' for control subs
%         1 or 'patients' for stimulant-dependent patients
%         'relapsers' for patient relapsers
%         'nonrelapsers' for patient nonrelapsers
%
% OUTPUT:
%   subjects - cell array of subject id strings for this experiment
%   gi(optional) - if desired, this returns a vector of 0s and 1s
%   indicating the group of the corresponding subject

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
subjListFileName = fullfile(getCueBaseDir,'data','subjects_list','subjects_list.csv');

T=readtable(subjListFileName);


% define subject id cell array & vector of corresponding group indices
subjects = table2array(T(:,1));
gi=table2array(T(:,2));


% if task is defined, return only good subjects for that task
if ~isempty(task)
    
    taskindex = find(strcmpi(task,T.Properties.VariableNames));
    
    if isempty(taskindex)
        
        fprintf(['\ntask name ' task ' not recognized;\n returning all subjects...\n'])
        
    else
        
        subjects(table2array(T(:,taskindex))==0)=[];
        gi(table2array(T(:,taskindex))==0)=[];
    end
    
end


% now get only subjects from one specific group, if desired
if ~isempty(group)
    
    % return controls
    if strcmpi(group,'controls') || isequal(group,0)
        subjects = subjects(gi==0);
        gi = gi(gi==0);
        
        % return patients (return both VA and epiphany patients)
    elseif strcmpi(group,'patients') || isequal(group,1)
        subjects = subjects(gi>0);
        gi = gi(gi>0);
        
        % return patients with complete followup data (or confirmed relapse before then)
    elseif strcmpi(group,'patients_complete')
        ri=getCueData(subjects,'relapse');
        obs=getCueData(subjects,'observedtime');
        idx=find(ri==1 | obs>150); % either relapsed or followed up for >5 months
        subjects = subjects(idx);
        gi = gi(idx);
        
        % return patients with at least 3 months followup data (or confirmed relapse before then)
    elseif strcmpi(group,'patients_3months')
        ri=getCueData(subjects,'relapse');
        obs=getCueData(subjects,'observedtime');
        idx=find(ri==1 | obs>=90); % either relapsed or followed up for >=3 months
        subjects = subjects(idx);
        gi = gi(idx);
        
        % return relapsers
    elseif strcmpi(group,'relapsers')
        ri=getCueData(subjects,'relapse');
        subjects = subjects(ri==1);
        gi = gi(ri==1);
        
        
        % return nonrelapsers
    elseif strcmpi(group,'nonrelapsers')
        ri=getCueData(subjects,'relapse');
        subjects = subjects(ri==0);
        gi = gi(ri==0);
        
        % return those who relapsed within 3 mos
    elseif any(strcmpi(group,{'relapsers_3months','relapse_3months'}))
        ri=getCueData(subjects,'relapse_3months');
        subjects = subjects(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 3 mos
    elseif any(strcmpi(group,{'nonrelapsers_3months','nonrelapse_3months'}))
        ri=getCueData(subjects,'relapse_3months');
        subjects = subjects(ri==0);
        gi = gi(ri==0);
        
        % return those who relapsed within 4 mos
    elseif any(strcmpi(group,{'relapsers_4months','relapse_4months'}))
        ri=getCueData(subjects,'relapse_4months');
        subjects = subjects(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 4 mos
    elseif any(strcmpi(group,{'nonrelapsers_4months','nonrelapse_4months'}))
        ri=getCueData(subjects,'relapse_4months');
        subjects = subjects(ri==0);
        gi = gi(ri==0);
        
        % return those who relapsed within 6 mos
    elseif any(strcmpi(group,{'relapsers_6months','relapse_6months'}))
        ri=getCueData(subjects,'relapse_6months');
        subjects = subjects(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 6 mos
    elseif any(strcmpi(group,{'nonrelapsers_6months','nonrelapse_6months'}))
        ri=getCueData(subjects,'relapse_6months');
        subjects = subjects(ri==0);
        gi = gi(ri==0);
        
        % return those who relapsed within 8 mos
    elseif any(strcmpi(group,{'relapsers_8months','relapse_8months'}))
        ri=getCueData(subjects,'relapse_8months');
        subjects = subjects(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 8 mos
    elseif any(strcmpi(group,{'nonrelapsers_8months','nonrelapse_8months'}))
        ri=getCueData(subjects,'relapse_8months');
        subjects = subjects(ri==0);
        gi = gi(ri==0);
        
        
        % return only VA patients
    elseif strcmpi(group,'patients_for')
        subjects = subjects(gi==1);
        gi = gi(gi==1);
        
        
        % return only epiphany patients
    elseif strcmpi(group,'patients_epiphany')
        subjects = subjects(gi==2);
        gi = gi(gi==2);
        
        
    end  % group
    
end % if ~isempty(group)

end % function






function [fgMeasures,fgMLabels,scores,subjects,gi,SuperFibers] = ...
    loadFGBehVars(fgMFile,scale,group,omit_subs)
% % 
% function [fgMeasures,fgMLabels,scores,subjects,gi,SuperFibers] = ...
%     loadFGBehVars(fgMFile,scale,group,omit_subs)

% [fgMeasures,fgMLabels,scores,subjects,gi] = loadFGBehVars(fullfile(fgMDir,[fgMatStr '.mat']),scale,group,omit_subs);
% -------------------------------------------------------------------------
% usage: function to load fiber group measures and other measures to correlate
% 
% INPUT:
%   var1 - integer specifying something
%   var2 - string specifying something
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 16-May-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
nargout

% set omit_subs to be an empty cell array if not given
if notDefined('omit_subs')
    omit_subs = {};
end

% no scale is default
if notDefined('scale')
    scale = '';
end

% give all subjects (all groups) as default
if notDefined('group')
    group = '';
end


% load fiber group measures
load(fgMFile); 
% this loads vars: 
    % eigvals
    % err_subs (list of subjects w/problems)
    % fgMeasures
    % fgMLabels
    % fgName
    % gi
    % lr
    % nNodes
    % seed
    % subjects
    % SuperFibers
    % target

    % for some .mat files, they don't have the gi variable. If that's the
    % case, make a vector of nans with numel= to numel(subjects)
    if notDefined('gi')
        gi=nan(numel(subjects),1);
    end
    
    
%% define a "keep index" of desired subjects to return data for

keep_idx = ones(numel(subjects),1);

% if a specific group is desired: 
if strcmpi(group,'controls') || isequal(group,0)
    gi=getCueData(subjects,'groupindex');
    keep_idx=gi==0;
    
elseif strcmpi(group,'patients') || isequal(group,1)
   gi=getCueData(subjects,'groupindex');
    keep_idx=gi>0;
    
elseif strcmpi(group,'relapsers') || strcmpi(group,'relapse') 
    rel = getCueData(subjects,'relapse');
    keep_idx=rel==1;
 
    elseif strcmpi(group,'relapsers_3months') || strcmpi(group,'relapse_3months') 
    rel = getCueData(subjects,'relapse_3months');
    keep_idx=rel==1;

    elseif strcmpi(group,'relapsers_4months') || strcmpi(group,'relapse_4months') 
    rel = getCueData(subjects,'relapse_4months');
    keep_idx=rel==1;

    elseif strcmpi(group,'relapsers_6months') || strcmpi(group,'relapse_6months') 
    rel = getCueData(subjects,'relapse_6months');
    keep_idx=rel==1;

   elseif strcmpi(group,'nonrelapsers') || strcmpi(group,'nonrelapse') 
    rel = getCueData(subjects,'relapse');
    keep_idx=rel==0;
 
    elseif strcmpi(group,'nonrelapsers_3months') || strcmpi(group,'nonrelapse_3months') 
    rel = getCueData(subjects,'relapse_3months');
    keep_idx=rel==0;

    elseif strcmpi(group,'nonrelapsers_4months') || strcmpi(group,'nonrelapse_4months') 
    rel = getCueData(subjects,'relapse_4months');
    keep_idx=rel==0;

    elseif strcmpi(group,'nonrelapsers_6months') || strcmpi(group,'nonrelapse_6months') 
    rel = getCueData(subjects,'relapse_6months');
    keep_idx=rel==0;
 
end
    
% remove any subjects from keep index that arent returned in
% getCueSubjects('dti')
keep_idx(ismember(subjects,getCueSubjects('dti'))==0)=0;


% exclude omit_subs from keep index
keep_idx=logical(keep_idx.*~ismember(subjects,omit_subs));


% exclude any additional subjects that don't have diffusion data 
keep_idx(isnan(fgMeasures{1}(:,1)))=0;


% exclude any subjects that don't have scale data
if ~isempty(scale)
    keep_idx(isnan(getCueData(subjects,scale)))=0;
end


%%  get fg data for just the desired subjects

subjects = subjects(keep_idx);
gi = gi(keep_idx);
fgMeasures = cellfun(@(x) x(keep_idx,:), fgMeasures,'uniformoutput',0);

if iscell(eigVals) % means l and r are saved separately
    eigVals{1}=eigVals{1}(keep_idx,:,:);
    eigVals{2}=eigVals{2}(keep_idx,:,:);
else
eigVals=eigVals(keep_idx,:,:);
end

if size(SuperFibers,2)==2 % means l and r are saved separately
    SuperFibers=SuperFibers(keep_idx,:);
else
    SuperFibers=SuperFibers(keep_idx);
end

% get scores 
if ~isempty(scale)
    scores = getCueData(subjects,scale);
else
    scores='';
end













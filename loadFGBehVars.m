function [fgMeasures,fgMLabels,scores,subjects,gi] = ...
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
    % subjecrts
    % SuperFibers
    % target

%% define a "keep index" of desired subjects to return data for

keep_idx = ones(numel(subjects),1);

% if a specific group is desired: 
if strcmpi(group,'controls') || isequal(group,0)
    keep_idx=gi==0;
elseif strcmpi(group,'patients') || isequal(group,1)
    keep_idx=gi==1;
elseif strcmpi(group,'relapsers') 
    rel = getCueData(subjects,'relapse');
    keep_idx=rel==1;
elseif strcmpi(group,'nonrelapsers') 
    rel = getCueData(subjects,'relapse');
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

% if size(SuperFibers,2)==2 % means l and r are saved separately
%     SuperFibers=SuperFibers(keep_idx,:);
% else
%     SuperFibers=SuperFibers(keep_idx);
% end
% 
% get scores 
if ~isempty(scale)
    scores = getCueData(subjects,scale);
else
    scores='';
end













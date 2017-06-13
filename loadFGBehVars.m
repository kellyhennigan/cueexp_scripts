function [fgMeasures,fgMLabels,scores,subjects,gi] = ...
    loadFGBehVars(fgMFile,scale,group,omit_subs)

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


% load fiber group measures
load(fgMFile);


% get index of desired subjects to return data for based on desired
% group(s)
if strcmpi(group,'controls') || isequal(group,0)
    keep_idx=gi==0;
elseif strcmpi(group,'patients') || isequal(group,1)
    keep_idx=gi==1;
end

% remove omit_subs from keep index
keep_idx=logical(keep_idx.*~ismember(subjects,omit_subs));


% get fg data for just the desired subjects
subjects = subjects(keep_idx);
gi = gi(keep_idx);
fgMeasures = cellfun(@(x) x(keep_idx,:), fgMeasures,'uniformoutput',0);


% get scores 
scores = getCueData(subjects,scale);














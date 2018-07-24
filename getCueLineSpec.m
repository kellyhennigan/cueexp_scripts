function lspec = getCueLineSpec(labels)
% -------------------------------------------------------------------------
% usage: function to return line specs specific for each stim/group in the
% cue experiment
%
% INPUT:
%   labels - cell array of labels (either stim names, groups, etc.)
%
% OUTPUT:
%   lspec - cell array of line specs for plotting
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 17-Nov-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('labels')
    labels = {'controls','patients'};
end

if ~iscell(labels)
    labels = {labels};
end


%% make cell array with line specs

lspec = {};

for i=1:numel(labels)
    
    switch lower(labels{i})
        
        case {'neutral','alcohol','drugs','food',...
                'patients','relapsers','relapsers_3months','relapsers 3months',...
                'strong want','somewhat want'}
            
            lspec{i} = '-';
            
        case {'controls','nonrelapsers','nonrelapsers_3months','nonrelapsers 3months',...
                'somewhat dontwant','strong dontwant'}
            
            lspec{i} = '--';
            
    end
    
end
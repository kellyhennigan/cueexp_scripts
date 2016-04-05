function [stimFiles,stimNames] = getStimFileNames(stims,group)
% -------------------------------------------------------------------------
% usage: returns names of stim files desired for plotting. Basically allows
% shorthand usage for specifying which stim files to plot
%
% INPUT:
%   stims - cell array specifying which stims to plot.
%   group - string specifying either 'controls','patients', or 'both'

%
% OUTPUT:
%   stimFiles - names of stimFiles to plot
%   stimNames - names to use in legend
%   

% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 10-Dec-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% set defaults
if notDefined('stims')
    stims = {'want'};
end
if ischar(stims)
    stims = {stims};
end

if notDefined('group')
    group = 'controls';
end
if iscell(group)
    if numel(group)==2
        group = 'both';
    else
        group = group{1};
    end
end


%%

stimFiles = [];
stimNames = [];

if strcmpi(stims{1},'want')
    stims =  {'strong_dontwant',...
        'somewhat_dontwant',...
        'somewhat_want',...
        'strong_want'};
    
elseif strcmpi(stims{1},'type')
    stims =  {'alcohol',...
        'drugs',...
        'food',...
        'neutral'};
end

if strcmpi(group,'both')
    stimFiles = cellfun(@(x) [x '_controls'], stims, 'uniformoutput',0);
    stimFiles2 = cellfun(@(x) [x '_patients'], stims, 'uniformoutput',0);
    stimFiles = [stimFiles stimFiles2];
    stimNames = cellfun(@(x) strrep(x,'_',' '), stimFiles, 'uniformoutput',0);
else
    stimFiles = cellfun(@(x) [x '_' group], stims, 'uniformoutput',0);
    stimNames = cellfun(@(x) strrep(x,'_',' '), stims, 'uniformoutput',0);
end







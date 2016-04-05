function stimNames = getStimNames(stimCode)
% -------------------------------------------------------------------------
% usage: returns names of stim files desired for plotting. Basically allows
% shorthand usage for specifying which stim files to plot. Unless the input
% stimCode is a recognized code for a category of conditions (i.e., 'want'
% or 'type'), this function will simply return the input.
%
% INPUT:
%   stimCode - either 'want' or 'type' specifying which stimNames to
%              return, or a specific stimName, in which case that stimName
%              is returned.

%
% OUTPUT:
%   stimNames 
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% set defaults
if notDefined('stimCode')
    stimCode = {'want'};
end

if ischar(stimCode)
    stimCode = {stimCode};
end


%%

stimNames = [];

if strcmpi(stimCode{1},'want')
    stimNames =  {'strong_dontwant',...
        'somewhat_dontwant',...
        'somewhat_want',...
        'strong_want'};
    
elseif strcmpi(stimCode{1},'type')
    stimNames =  {'alcohol',...
        'drugs',...
        'food',...
        'neutral'};

else
    stimNames = stimCode;
end







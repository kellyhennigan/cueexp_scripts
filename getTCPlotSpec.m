function [groups,stims,stimStrs]=getTCPlotSpec(task,groupStr)
% -------------------------------------------------------------------------
% usage: define time course plot specifications for plotting VOI time
% courses forcue task, mid, and midi tasks
%
% INPUT:
%   task - % must be either 'cue','mid', or 'midi'
%   groupStr - 'alc' for returning plot specs for claudia's subjects,
%   otherwise nothing
%
% OUTPUT:
%   groups - cell array of groups to plot; each row corresponds to one
%            figure
%   stims - cell array of stims to plot; " "
%   stimStrs - cell array of strings (shorthand for multiple stims) to use
%   for plot title and file name, etc.

% NOTES: for cells that have >1 stim or group, they are separated with a
% space.
%
% author: Kelly, kelhennigan@gmail.com, 05-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% return plot specs for our subjects (as opposed to Claudia's) by default
if notDefined('groupStr')
    groupStr = [];
end

switch task
    
    case 'cue'  % cue fmri task
        

   % corresponding groups:
        groups =  {'controls';
            'controls';
            'patients';
            'patients';
            'controls patients';
            'controls patients';
            'controls patients';
            'controls patients';
            'controls patients';
            'controls patients';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers'
           };
        
        % corresponding stims:
        stims =  {'neutral drugs food';
            'strong_dontwant somewhat_dontwant somewhat_want strong_want';
            'neutral drugs food';
            'strong_dontwant somewhat_dontwant somewhat_want strong_want';
            'alcohol';
            'drugs';
            'food';
            'neutral';
            'drugs-neutral';
            'drugs-food'
            'alcohol';
            'drugs';
            'food';
            'neutral';
            'drugs-neutral';
            'drugs-food'};
        
        % corresponding stim strings to use in figure and file name
        stimStrs =  {'type';
            'want';
            'type';
            'want';
            'alcohol';
            'drugs';
            'food';
            'neutral'; 
            'drugs-neutral';
            'drugs-food'
            'alcohol';
            'drugs';
            'food';
            'neutral'; 
            'drugs-neutral';
            'drugs-food'
            };
     


        
    case 'mid'  % midi fmri task
        
        % corresponding groups:
        groups =  {'controls';
            'controls';
            'controls';
            'patients';
            'patients';
            'patients';
            'controls patients';
            'controls patients';
            'controls patients';
            'controls patients';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers'};
        
         % corresponding stims:
         stims =  {'gain0 gain5 loss0 loss5';
             'gainwin gainmiss';
             'losswin lossmiss';
             'gain0 gain5 loss0 loss5';
             'gainwin gainmiss';
             'losswin lossmiss';
             'gain5-gain0';
             'loss5-loss0'
             'gainwin-gainmiss';
             'losswin-lossmiss';
             'gain5-gain0';
             'loss5-loss0'
             'gainwin-gainmiss';
             'losswin-lossmiss'};
         
         
        % corresponding stim strings to use in figure and file name
        stimStrs =  {'trial type';
            'gain trial outcome';
            'loss trial outcome';
            'trial type';
            'gain trial outcome';
            'loss trial outcome';
            'gain5-0 anticipation';
            'loss5-0 anticipation';
            'gain win-miss outcome';
            'loss win-miss outcome';
            'gain5-0 anticipation';
            'loss5-0 anticipation';
            'gain win-miss outcome';
            'loss win-miss outcome'};
        
        
    case 'midi'  % mid fmri task
        
        % corresponding groups:
        groups =  {'controls';
            'patients'
            'controls relapsers non-relapsers';
            'controls relapsers non-relapsers';};
        
        
        
        % corresponding stims:
        stims =  {'gain5GO gain0GO gain5NOGO gain0NOGO';
            'gain5GO gain0GO gain5NOGO gain0NOGO';
            'gain0GO gain0NOGO';
            'gain5GO gain5NOGO'};
        
        
        
        % corresponding stim strings to use in figure and file name
        stimStrs =  {'Incentivized GO vs NOGO';
            'Incentivized GO vs NOGO';
            'GO vs NOGO control';
            'GO vs NOGO gains'
            };
        
        
        
end


% if returning plot specs for claudia's data, take the specs for plotting
% just subjects, then change the group string to 'alcpatients'
if strcmp(groupStr,'alc')
    
    stims=stims(strcmp(groups,'patients'));
    stimStrs=stimStrs(strcmp(groups,'patients'));
    groups=groups(strcmp(groups,'patients'));
    groups = repmat({'alcpatients'},size(groups));
    
end









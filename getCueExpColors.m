function colors = getCueExpColors(labels,format,set)
% -------------------------------------------------------------------------
% usage: returns rgb values for colors used in cue experiment
%
% INPUT:
%   labels - cell array of stims or groups to return colors for
%   format (optional) - 'cell' will return colors in a cell array format
%   set - either 'gs' or 'color' to return grayscale or colors
%
% OUTPUT:
%   colors - rgb values in rows for colors
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('labels')
    labels = {'controls','patients'};
end

if ~iscell(labels)
    labels = {labels};
end

if notDefined('format')
    format = [];
end

if notDefined('set')
    set = 'grayscale'; % either 'grayscale' or 'color'
end


%%%%%%%%% define colors for all possible stims/groups here %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch set
    
    
    % define grayscale shades for each stim/group
    case 'grayscale'
        
        % stims
        alcohol_color = [75 75 75]./255; % dark gray
        drugs_color = [30 30 30]./255; % grayish black
        food_color = [100 100 100]./255; % mid-gray
        neutral_color = [170 170 170]./255; % light gray
        
        % groups
        controls_color =  [170 170 170]./255; % light gray
        patients_color = [30 30 30]./255; % grayish black
        relapsers_color = [30 30 30]./255; % grayish black
        nonrelapsers_color = [100 100 100]./255; % mid-gray
        
        % want ratings
        strongwant_color =   [30 30 30]./255; % grayish black
        somewhatwant_color =  [77 77 77]./255; % drak gray
        somewhatdontwant_color = [123 123 123]./255; % mid gray
        strongdontwant_color = [170 170 170]./255; % light gray
        
        
        % define colors for each stim/group
    case 'color'
        
        % stims
        alcohol_color = [253 158 33]./255; % orange
        drugs_color = [ 246 97 165]./255; % pink
        food_color = [2 117 180]./255; % blue
        neutral_color = [170 170 170]./255; % light gray
        
        % groups
        controls_color =  [2 117 180]./255; % blue
        patients_color = [ 253 44 20]./255; %  fire-y red
        relapsers_color = [ 253 44 20]./255; % fire-y red
        nonrelapsers_color = [29 186 154]./255; % green
        
        % want ratings
        strongwant_color =  [219 79 106]./255;       % pink
        somewhatwant_color =  [253 158 33]./255;      % orange
        somewhatdontwant_color = [42 160 120]./255;  % green
        strongdontwant_color = [2 117 180]./255;     % blue
        
        
end


%%%%%% determine which colors to return based on input labels %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colors = [];
for i=1:numel(labels)
      
    switch lower(labels{i})
        
        case 'alcohol'
            colors(i,:) = alcohol_color;
            
        case 'drugs'
            colors(i,:) = drugs_color;
            
        case 'food'
            colors(i,:) = food_color;
            
        case 'neutral'
            colors(i,:) = neutral_color;
            
        case 'controls'
            colors(i,:) = controls_color;
            
        case 'patients'
            colors(i,:) = patients_color;
            
        case {'relapsers_6months','relapsers'}
            colors(i,:) = relapsers_color;
            
        case {'nonrelapsers_6months','nonrelapsers'}
            colors(i,:) = nonrelapsers_color;
            
        case 'strong want'
            colors(i,:) = strongwant_color;
            
        case 'somewhat want'
            colors(i,:) = somewhatwant_color;
            
        case 'somewhat dontwant'
            colors(i,:) = somewhatdontwant_color;
            
        case 'strong dontwant'
            colors(i,:) = strongdontwant_color;
            
        otherwise
            colors(i,:) = [30 30 30]./255; % return grayish black
            
    end
    
end


if strcmp(format,'cell')
    colors = mat2cell(colors,[ones(1,size(colors,1))],3);
end

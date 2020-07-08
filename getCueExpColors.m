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
    set = 'color'; % either 'grayscale' or 'color'
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
        somewhatwant_color =  [77 77 77]./255; % dark gray
        somewhatdontwant_color = [123 123 123]./255; % mid gray
        strongdontwant_color = [170 170 170]./255; % light gray
        
        
        % define colors for each stim/group
    case 'color'
        
        % stims
        alcohol_color = [253 158 33]./255; % orange
        drugs_color = [253 44 20]./255; %  fire-y red
        food_color = [2 117 180]./255; % blue
        neutral_color = [100 100 100]./255; % light gray
        
        % groups
        controls_color =  [2 117 180]./255; % blue
        patients_color = [ 253 44 20]./255; %  fire-y red
        relapsers_color = [ 253 44 20]./255; % fire-y red
        nonrelapsers_color = [249 192 50]./255; % yellow
        patients_sample2_color = [ 255 121 3]./255; %  orange
        
        % want ratings
        strongwant_color = [2 117 180]./255;     % blue
        somewhatwant_color = [42 160 120]./255;  % green
        somewhatdontwant_color =  [253 158 33]./255;      % orange
        strongdontwant_color =  [219 79 106]./255;       % pink
        
        
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
            
        case {'patients','patients_sample1','patients sample1',...
                'patients_for','patients for'}
            colors(i,:) = patients_color;
            
            
        case {'patients_sample2','patients sample2'...
                'patients_epiphany','patients epiphany'}
            
            colors(i,:) = patients_sample2_color;
            
            
        case {'relapsers_3months','relapsers 3months',...
                'relapsers_4months','relapsers 4months',...
                'relapsers_6months','relapsers 6months',...
                'relapsers_8months','relapsers 8months',...
                'relapsers',...
                'relapsers_3months_sample1','relapsers 3months sample1',...
                'relapsers_4months_sample1','relapsers 4months sample1',...
                'relapsers_6months_sample1','relapsers 6months sample1',...
                'relapsers_8months_sample1','relapsers 8months sample1',...
                'relapsers_sample1','relapsers sample1',...
                'relapsers_3months_sample2','relapsers 3months sample2',...
                'relapsers_4months_sample2','relapsers 4months sample2',...
                'relapsers_6months_sample2','relapsers 6months sample2',...
                'relapsers_8months_sample2','relapsers 8months sample2',...
                'relapsers_sample2','relapsers sample2',...
                'relapsers_3months_for','relapsers 3months for',...
                'relapsers_4months_for','relapsers 4months for',...
                'relapsers_6months_for','relapsers 6months for',...
                'relapsers_8months_for','relapsers 8months for',...
                'relapsers_for','relapsers for',...
                'relapsers_3months_epiphany','relapsers 3months epiphany',...
                'relapsers_4months_epiphany','relapsers 4months epiphany',...
                'relapsers_6months_epiphany','relapsers 6months epiphany',...
                'relapsers_8months_epiphany','relapsers 8months epiphany',...
                'relapsers_epiphany','relapsers epiphany',...
                }
            colors(i,:) = relapsers_color;
            
        case {'nonrelapsers_3months','nonrelapsers 3months',...
                'nonrelapsers_4months','nonrelapsers 4months',...
                'nonrelapsers_6months','nonrelapsers 6months',...
                'nonrelapsers_8months','nonrelapsers 8months',...
                'nonrelapsers',...
                'nonrelapsers_3months_sample1','nonrelapsers 3months sample1',...
                'nonrelapsers_4months_sample1','nonrelapsers 4months sample1',...
                'nonrelapsers_6months_sample1','nonrelapsers 6months sample1',...
                'nonrelapsers_8months_sample1','nonrelapsers 8months sample1',...
                'nonrelapsers_sample1','nonrelapsers sample1',...
                'nonrelapsers_3months_sample2','nonrelapsers 3months sample2',...
                'nonrelapsers_4months_sample2','nonrelapsers 4months sample2',...
                'nonrelapsers_6months_sample2','nonrelapsers 6months sample2',...
                'nonrelapsers_8months_sample2','nonrelapsers 8months sample2',...
                'nonrelapsers_sample2','nonrelapsers sample2',...
                'nonrelapsers_3months_for','nonrelapsers 3months for',...
                'nonrelapsers_4months_for','nonrelapsers 4months for',...
                'nonrelapsers_6months_for','nonrelapsers 6months for',...
                'nonrelapsers_8months_for','nonrelapsers 8months for',...
                'nonrelapsers_for','nonrelapsers for',...
                'nonrelapsers_3months_epiphany','nonrelapsers 3months epiphany',...
                'nonrelapsers_4months_epiphany','nonrelapsers 4months epiphany',...
                'nonrelapsers_6months_epiphany','nonrelapsers 6months epiphany',...
                'nonrelapsers_8months_epiphany','nonrelapsers 8months epiphany',...
                'nonrelapsers_epiphany','nonrelapsers epiphany',...
                }
            colors(i,:) = nonrelapsers_color;
            
        case 'strong want'
            colors(i,:) = strongwant_color;
            
        case 'somewhat want'
            colors(i,:) = somewhatwant_color;
            
        case 'somewhat dontwant'
            colors(i,:) = somewhatdontwant_color;
            
        case 'strong dontwant'
            colors(i,:) = strongdontwant_color;
            
         
       %%%%%%%% MID conditions
        case {'gain5','gain5-gain0'}
            colors(i,:)=[253 158 33]./255; % orange
       
        case 'gain1'
            colors(i,:)=[200 120 100]./255; % orange-pink
            
        case 'gain0'
            colors(i,:)=[246 97 165]./255; % pink
            
        case {'loss5','loss5-loss0'}
            colors(i,:)=[2 117 180]./255; % blue
       
        case 'loss1'
            colors(i,:)=[20 150 170]./255; % blue-green
            
        case 'loss0'
            colors(i,:)=[29 186 154]./255; % green
            
        case {'gainwin','gainwin-gainmiss','gainhit'}
            colors(i,:)=[253 158 33]./255; % orange
            
        case 'gainmiss'
            colors(i,:)=[246 97 165]./255; % pink
            
        case {'losswin','losswin-lossmiss','losshit'}
            colors(i,:)=[2 117 180]./255; % blue
            
        case 'lossmiss'
            colors(i,:)=[29 186 154]./255; % green
          
      
            
            
            %%%%%%%% MIDI conditions
        case {'gain5go','gain5go-gain0go'}
            colors(i,:)=[253 158 33]./255; % orange
            
        case 'gain0go'
            colors(i,:)=[253 158 33]./255; % orange
            
        case {'gain5nogo','gain5nogo-gain0nogo'}
            colors(i,:)=[2 117 180]./255; % blue
            
        case 'gain0nogo'
            colors(i,:)=[2 117 180]./255; % blue
            
        case {'loss5go','loss5go-loss0go'}
            colors(i,:)=[29 186 154]./255; % green
            
        case 'loss0go'
            colors(i,:)=[29 186 154]./255; % green
            
        case {'loss5nogo','loss5nogo-loss0nogo'}
            colors(i,:)=[246 97 165]./255;  % pink
            
        case 'loss0nogo'
            colors(i,:)=[246 97 165]./255;  % pink
            
            
        otherwise
            colors(i,:) = [30 30 30]./255; % return grayish black
            
    end
    
end


if strcmp(format,'cell')
    colors = mat2cell(colors,[ones(1,size(colors,1))],3);
end

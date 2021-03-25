function col = getCueExpColors(stim,colset)
% -------------------------------------------------------------------------
% usage: returns rgb values for colors used in cue experiment
%
% INPUT:
%   stim - string specifying a condition relevant to the cue experiment
%   colset (optional) - either 'gs' or 'color' to return grayscale or colors;
%   default is color
%
% OUTPUT:
%   col - rgb values for a color
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('stim')
    stim = '';
end

% default is to use colors
if notDefined('colset')
    colset = 'color';
end


% rgb color values
if strcmp(colset,'color')
    
    switch lower(stim)
        
        % add/edit as desired!!!
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%  mid conditions %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        case 'gain5'
            
            col=  [37,52,148]./255; % dark blue
            
            
        case 'gain5-gain0'
            
            col=[5,112,176]./255; % blue
            
            
        case 'gain1'
            
            col=[5,112,176]./255; % blue
            
            
        case 'gain0'
            
            col= [116,169,207]./255; % light blue
            
            
        case 'loss5'
            
            col=  [103,0,13]./255; % dark red
            
            
        case 'loss5-loss0'
            
            col=[203,24,29]./255; % red
            
            
        case 'loss1'
            
            col=[203,24,29]./255; % red
            
            
        case 'loss0'
            
            col=[251,106,74]./255; % light red
            
            
        case {'gainwin','gainwin-gainmiss'}
            
            col=[33,113,181]./255; % blue
            
            
        case 'gainmiss'
            
            col=[33,113,181]./255; % blue
            
            
        case {'losswin','losswin-lossmiss','losshit'}
            
            col=[203,24,29]./255; % red
            
            
        case 'lossmiss'
            
            col=[203,24,29]./255; % red
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%  cue conditions %%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        case 'alcohol'
            col=[253 158 33]./255; % orange
            
        case {'drugs','drug'}
            col=[253 44 20]./255; %  fire-y red
            
        case 'food'
            col= [2 117 180]./255; % blue
            
        case 'neutral'
            col= [100 100 100]./255; % light gray
            
        case {'strongwant','strong want'}
            col=[2 117 180]./255;     % blue
            
        case {'somewhatwant','somewhat want','somewhat_want'}
            col= [42 160 120]./255;  % green
            
        case {'somewhat dontwant','somewhatdontwant','somewhat_dontwant'}
            col=  [253 158 33]./255;      % orange
            
        case {'strong dontwant','strongdontwant','strong_dontwant'}
            col=[219 79 106]./255;       % pink
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%  midi conditions %%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        case {'gain5go','gain5go-gain0go'}
            col=[253 158 33]./255; % orange
            
        case 'gain0go'
            col=[253 158 33]./255; % orange
            
        case {'gain5nogo','gain5nogo-gain0nogo'}
            col=[2 117 180]./255; % blue
            
        case 'gain0nogo'
            col=[2 117 180]./255; % blue
            
        case {'loss5go','loss5go-loss0go'}
            col=[29 186 154]./255; % green
            
        case 'loss0go'
            col=[29 186 154]./255; % green
            
        case {'loss5nogo','loss5nogo-loss0nogo'}
            col=[246 97 165]./255;  % pink
            
        case 'loss0nogo'
            col=[246 97 165]./255;  % pink
            
            
            %%%%%%%%%%%%%%%%%%%%%
            
        otherwise
            col = [30 30 30]./255; % return grayish black
            
    end
    
    
    %% gray scale rgb values
    
else
    
    switch lower(stim)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%  mid conditions %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        case 'gain5'
            
            col=  [30 30 30]./255; % grayish black
            
            
        case 'gain5-gain0'
            
            col= [30 30 30]./255; % grayish black
            
            
        case 'gain1'
            
            col=[100 100 100]./255; % mid-gray
            
            
        case 'gain0'
            
            col=  [170 170 170]./255; % light gray
            
            
        case 'loss5'
            
            col= [30 30 30]./255; % grayish black
            
            
        case 'loss5-loss0'
            
            col=[30 30 30]./255; % grayish black
            
            
        case 'loss1'
            
            col=[100 100 100]./255; % mid-gray
            
            
        case 'loss0'
            
            col= [170 170 170]./255; % light gray
            
            
        case {'gainwin','gainwin-gainmiss'}
            
            col=[30 30 30]./255; % grayish black
            
            
        case 'gainmiss'
            
            col=[170 170 170]./255; % light gray
            
            
        case {'losswin','losswin-lossmiss','losshit'}
            
            col=[30 30 30]./255; % grayish black
            
            
        case 'lossmiss'
            
            col=[170 170 170]./255; % light gray
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%  cue conditions %%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        case 'alcohol'
            col= [75 75 75]./255; % dark gray
            
        case {'drugs','drug'}
            col=[30 30 30]./255; % grayish black
            
        case 'food'
            col= [100 100 100]./255; % mid-gray
            
        case 'neutral'
            col= [170 170 170]./255; % light gray
            
        case {'strongwant','strong want'}
            col=  [30 30 30]./255; % grayish black
            
        case {'somewhatwant','somewhat want','somewhat_want'}
            col =  [77 77 77]./255; % dark gray
            
        case {'somewhat dontwant','somewhatdontwant','somewhat_dontwant'}
            col=   [123 123 123]./255; % mid gray
            
        case {'strong dontwant','strongdontwant','strong_dontwant'}
            col=[170 170 170]./255; % light gray
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%  midi conditions %%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        case {'gain5go','gain5go-gain0go'}
            col=[253 158 33]./255; % orange
            
        case 'gain0go'
            col=[253 158 33]./255; % orange
            
        case {'gain5nogo','gain5nogo-gain0nogo'}
            col=[2 117 180]./255; % blue
            
        case 'gain0nogo'
            col=[2 117 180]./255; % blue
            
        case {'loss5go','loss5go-loss0go'}
            col=[29 186 154]./255; % green
            
        case 'loss0go'
            col=[29 186 154]./255; % green
            
        case {'loss5nogo','loss5nogo-loss0nogo'}
            col=[246 97 165]./255;  % pink
            
        case 'loss0nogo'
            col=[246 97 165]./255;  % pink
            
            
            %%%%%%%%%%%%%%%%%%%%%
            
        otherwise
            col = [30 30 30]./255; % return grayish black
            
    end
    
end % color set (color or grayscale)
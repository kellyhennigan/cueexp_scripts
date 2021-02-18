function colors = getDTIColors(fgFileStrs)
% -------------------------------------------------------------------------
% usage: returns rgb color values for plotting cue experiment results. The
% idea of having this is to keep plot colors for each stimulus consistent.
% Hard code desired colors here, then they will be used by various plotting
% scripts.


% INPUT:
%   fgFileStrs - filename of fiber group, e.g., 'mpfcL_naccL_autoclean'

% OUTPUT:
%   colors - rgb values in rows for colors
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if notDefined('fgFileStrs')
    fgFileStrs={''};
end
if ~iscell(fgFileStrs)
    fgFileStrs={fgFileStrs};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% define colors for all possible stims/groups here %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


green=[102 166 30]./255;
pink=[231 41 138]./255;
purple=[117 112 179]./255;
junglegreen=[27 158 119]./255;

red = [250 24 29]./255;    % red
orange = [244 101 7]./255;       % orange
yellow = [238,178,35]./255;      % yellow
blue = [44, 129, 162]./255;    % blue (different from putamen blue)

white= [1 1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% determine which colors to return based on input labels %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colors = [];
for i=1:numel(fgFileStrs)
    
    fgStr=fgFileStrs{i};
    
    if contains(fgStr,'mpfc','IgnoreCase',1)
        
        colors(i,:)=[15   209   219]./255; % cyan
        
    elseif  contains(fgStr,'amyg','IgnoreCase',1)
        
        colors(i,:)=[253   160     0]./255; % yellowish-orange
        
    elseif  contains(fgStr,'vlpfc','IgnoreCase',1)
        
        colors(i,:)= [138 86 165]./255; % purple
        
    elseif  contains(fgStr,'pvt','IgnoreCase',1)
        
        colors(i,:)= [1 0 0]; % red
        
    elseif  contains(fgStr,'asgins','IgnoreCase',1)
        
        colors(i,:)= [ 226    24     2]./255; % red
        
    elseif  contains(fgStr,'caudate','IgnoreCase',1)
        
        colors(i,:)= [250 24 29]./255; % red
        
    elseif  contains(fgStr,'putamen','IgnoreCase',1)
        
        colors(i,:)= [44, 129, 162]./255; % blue
        
    elseif  contains(fgStr,'aboveAC','IgnoreCase',1) % superior VTA-NAcc tract
        
        colors(i,:)= [244 101 7]./255; % orange
        
    elseif  contains(fgStr,'belowAC','IgnoreCase',1) % inferior VTA-NAcc tract
        
        colors(i,:)= [238,178,35]./255; % yellow
        
    else
        colors(i,:)=[231 41 138]./255; % pink
        
    end
    
end



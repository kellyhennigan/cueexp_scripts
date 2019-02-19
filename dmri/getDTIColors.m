function colors = getDTIColors(targets,fgFileStrs)
% -------------------------------------------------------------------------
% usage: returns rgb color values for plotting cue experiment results. The
% idea of having this is to keep plot colors for each stimulus consistent.
% Hard code desired colors here, then they will be used by various plotting
% scripts.


% INPUT:

% OUTPUT:
%   colors - rgb values in rows for colors
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~iscell(targets)
    targets = {targets};
end

if notDefined('fgFileStrs')
    fgFileStrs=cell(size(targets));
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
for i=1:numel(targets)
    
    switch lower(targets{i})
        
        case 'nacc'
            
            if strfind(lower(fgFileStrs{i}),'aboveac')
                colors(i,:)=orange;
            else
                colors(i,:) = yellow;
            end
            
        case 'caudate'
            colors(i,:) = red;
            
        case 'putamen'
            colors(i,:) = blue;
            
        case 'da'
            colors(i,:) = white;
            
        otherwise
            colors(i,:)=green;
            
    end
    
end


% 
% nacc = [250 24 29]./255;    % red
% caudate = [238,178,35]./255;      % yellow
% putamen = [33, 113, 181]./255;  % blue
% dTier = [244 101 7]./255;       % orange
% vTier = [44, 129, 162]./255;    % blue (different from putamen blue)
% daRoi = [28 178 5]./255;       % green
% 
% 
% % colors for fiber density maps: 
% fd_caudate = [linspace(252,221,64)',linspace(244,151,64)',linspace(200,28,64)']./255; % yellow
% fd_nacc = [linspace(255,200,64)',linspace(224,15,64)',linspace(210,21,64)']./255;
% fd_putamen = [linspace(158,0,64)',linspace(202,0,64)',linspace(225,181,64)']./255;


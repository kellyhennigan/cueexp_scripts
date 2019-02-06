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

% yellow=[10 30 100]./255;
yellow=[230 171 2]./255;

green=[102 166 30]./255;
pink=[231 41 138]./255;
purple=[117 112 179]./255;
orange=[217 95 2]./255;
junglegreen=[27 158 119]./255;




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
            colors(i,:) = pink;
            
        case 'putamen'
            colors(i,:) = purple;
            
        otherwise
            colors(i,:)=green;
            
    end
    
end


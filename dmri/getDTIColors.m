function colors = getDTIColors(labels)
% -------------------------------------------------------------------------
% usage: returns colors for dti analysis for the cue fmri project.
% 
% INPUT:
%   labels - string or cell array of strings specifying which pathways to
%   return colors for

% 
% OUTPUT:
%   cols - rgb color values 
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 10-Sep-2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if notDefined('labels')
    labels = {'nacc'};
end

if ~iscell(labels)
    labels = {labels};
end

%%

nacc = [250 24 29]./255;    % red
caudate = [238,178,35]./255;      % yellow
putamen = [33, 113, 181]./255;  % blue
dTier = [244 101 7]./255;       % orange
vTier = [44, 129, 162]./255;    % blue (different from putamen blue)
daRoi = [28 178 5]./255;       % green


% colors for fiber density maps: 
fd_caudate = [linspace(252,221,64)',linspace(244,151,64)',linspace(200,28,64)']./255; % yellow
fd_nacc = [linspace(255,200,64)',linspace(224,15,64)',linspace(210,21,64)']./255;
fd_putamen = [linspace(158,0,64)',linspace(202,0,64)',linspace(225,181,64)']./255;


colors = cell(size(labels));
for i=1:numel(labels)
        
    switch lower(labels{i})
        
        case 'caudate'
            colors{i} = caudate;
        case 'nacc'
            colors{i} = nacc;
        case 'putamen'
            colors{i} = putamen;
        case 'fd_caudate'
            colors{i} = fd_caudate;
        case 'fd_nacc'
            colors{i} = fd_nacc;
        case 'fd_putamen'
            colors{i} = fd_putamen;
            
    end
end

  

%  0.925 0.528 0.169 1 % nice purple complimentary to the caudate yellow

%  0.916 0.010 0.458 %% GREAT hot pink!!!!


% 


    
    
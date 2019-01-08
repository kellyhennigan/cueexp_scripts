function colors = getDTIFDColors(labels)
% -------------------------------------------------------------------------
% usage: returns colors for fiber density maps for the cue fmri project.
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

% colors for fiber density maps: 
fd_caudate = [linspace(252,221,64)',linspace(244,151,64)',linspace(200,28,64)']./255; % yellow
fd_nacc = [linspace(255,200,64)',linspace(224,15,64)',linspace(210,21,64)']./255;
fd_putamen = [linspace(158,0,64)',linspace(202,0,64)',linspace(225,181,64)']./255;


colors = cell(size(labels));
for i=1:numel(labels)
        
    switch lower(labels{i})
        
        case 'caudate'
            colors{i} = fd_caudate;
        case 'nacc'
            colors{i} = fd_nacc;
        case 'putamen'
            colors{i} = fd_putamen;
            
    end
end

  

%  0.925 0.528 0.169 1 % nice purple complimentary to the caudate yellow

%  0.916 0.010 0.458 %% GREAT hot pink!!!!


% 


    
    
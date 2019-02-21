function colors = getDTIFDColors(targets,fgFileStrs)
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


if notDefined('targets')
    targets = {'nacc'};
end

if ~iscell(targets)
    targets = {targets};
end


if notDefined('fgFileStrs')
    fgFileStrs=cell(size(targets));
end
if ~iscell(fgFileStrs)
    fgFileStrs={fgFileStrs};
end

%%

% colors for fiber density maps: 
fd_nacc = [linspace(252,221,8)',linspace(244,151,8)',linspace(200,28,8)']./255; % yellow

fd_nacc_aboveac=[255,245,235
254,230,206
253,208,162
253,174,107
253,141,60
241,105,19
217,72,1
140,45,4]./255;

fd_caudate = [linspace(255,200,8)',linspace(224,15,8)',linspace(210,21,8)']./255;


fd_putamen=[247,251,255
222,235,247
198,219,239
158,202,225
107,174,214
66,146,198
33,113,181
8,69,148]./255;

colors = cell(size(targets));
for i=1:numel(targets)
        
    switch lower(targets{i})
        
        case 'caudate'
            colors{i} = fd_caudate;
        case 'nacc'
              if strfind(lower(fgFileStrs{i}),'aboveac')
                colors{i}=fd_nacc_aboveac;
            else
               colors{i} = fd_nacc;
            end
            
        case 'putamen'
            colors{i} = fd_putamen;
            
    end
end

  

%  0.925 0.528 0.169 1 % nice purple complimentary to the caudate yellow

%  0.916 0.010 0.458 %% GREAT hot pink!!!!


% 


    
    
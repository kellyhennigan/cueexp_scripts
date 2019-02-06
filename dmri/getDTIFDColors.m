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
% fd_caudate = [linspace(252,221,64)',linspace(244,151,64)',linspace(200,28,64)']./255; % yellow
% fd_nacc = [linspace(255,200,64)',linspace(224,15,64)',linspace(210,21,64)']./255;
% fd_putamen = [linspace(158,0,64)',linspace(202,0,64)',linspace(225,181,64)']./255;

% fd_nacc = [linspace(252,221,64)',linspace(244,151,64)',linspace(200,28,64)']./255; % yellow

fd_nacc = [linspace(252,221,8)',linspace(244,151,8)',linspace(200,28,8)']./255; % yellow

fd_caudate = [247,244,249
231,225,239
212,185,218
201,148,199
223,101,176
231,41,138
206,18,86
145,0,63]./255;


fd_putamen = [247,252,253
224,236,244
191,211,230
158,188,218
140,150,198
140,107,177
136,65,157
110,1,107]./255; 
  
fd_nacc_aboveac=[255,255,229
255,247,188
254,227,145
254,196,79
254,153,41
236,112,20
204,76,2
140,45,4]./255;

% yellow=[10 30 100]./255;
yellow=[230 171 2]./255;

green=[102 166 30]./255;
pink=[231 41 138]./255;
purple=[117 112 179]./255;
orange=[217 95 2]./255;
junglegreen=[27 158 119]./255;



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


    
    
function colors = getCueExpColors_old(n,format)
% -------------------------------------------------------------------------
% usage: returns rgb values for colors used in cue experiment
%
% INPUT:
%   n (optional) - # of colors to return
%   format (optional) - 'cell' will return colors in a cell array format
%
%
% OUTPUT:
%   colors - rgb values in rows for colors
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('n')
    n=4; % return 4 colors by default
end

if notDefined('format')
    format = [];
end


colors3 = [
    219 79 106      % pink
    253 158 33      % orange
    42 160 120      % green
    2 117 180       % blue
    ]./255;


colors2 = [
    246 97 165      % pink
    253 158 33      % orange
    29 186 154      % green
    2 117 180       % blue
    ]./255;

colors1 = [
    253 44 20      % fire-y red
    253 158 33      % orange
    29 186 154      % green
    2 117 180       % blue
    ]./255;

colors4 = [
    253 44 20      % fire-y red
    253 158 33      % orange
    29 186 154      % green
    71 33 233       % blue
    ]./255;

colors2 = [
    253 44 20      % fire-y red
    253 158 33      % orange
    29 186 154      % green
    37 180 250       % blue
    ]./255;

colors = [
    250 32 161      % pink
    253 158 33      % orange
    29 186 154      % green
    33 105 208      % blue
    ]./255;



% n = number of colors requested to be returned
if n==1
    colors = colors(4,:);
elseif n==2
    colors = [colors(4,:);colors(1,:)];
elseif n==3
    colors = [colors(4,:);colors(1,:);colors(3,:)];
elseif n>4
    colors = interp1(linspace(0,1,4),colors,linspace(0,1,n));
    colors = abs(colors); % in case there's a negative value
end

if strcmp(format,'cell')
    colors = mat2cell(colors,[ones(1,size(colors,1))],[3]);
end

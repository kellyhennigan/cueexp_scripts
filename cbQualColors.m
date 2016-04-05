function colors = cbQualColors(nColors)

% returns good colors for qualitatively different plots; colors are from
% here: http://colorbrewer2.org/



baseColors = [
    166,206,227
    31,120,180
    178,223,138
    51,160,44
    251,154,153
    227,26,28
    253,191,111
    255,127,0
    202,178,214
    106,61,154]./255;

if notDefined('nColors')
    nColors = size(baseColors,1);
end

if nColors>size(baseColors,1)
    error(['sorry this can only return up to ' str(size(baseColors,1)) ' colors']);
end


colors= baseColors(1:nColors,:);



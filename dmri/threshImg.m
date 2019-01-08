function outImg = threshImg(inImg,thresh)
% -------------------------------------------------------------------------
% usage: set voxels less than thresh to zero. 
% 
% INPUT:
%   img 
%   thresh
% 
% OUTPUT:
%   img_thresholded
% 

% note: this function is basically to get around the fact that I can't
% figure out how to use cellfun to threshold data in a cell array. Having
% this function means I can do it like this: 

% outImg = cellfun(@(x) threshImg(x,thresh), inImg, 'UniformOutput',0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outImg = inImg; 
outImg(outImg < thresh) = 0;
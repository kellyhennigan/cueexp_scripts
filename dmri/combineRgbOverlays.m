
function outOl = combineRgbOverlays(rgbOverlays,w)
% -------------------------------------------------------------------------
% usage: this function is used to combine overlays from different maps, for
% example, fiber density maps from different tracts. 
% 
% INPUT:
%   rgbOverlays - matrix with rgb values corresponding to an overlay image
%       or volume. As of now, rgb values are expected in the 3rd dim, and the
%       4th dim has different overlay maps. It may be useful to make this more
%       flexible by allowing inputs w/dimesnions other than 4, but for now
%       stick to that. 
    
%       So, for example, to combine rgb images for a single 2d image, pixel
%       locations would be in dim(1) and dim(2), rgb vals per pixel in
%       dim(3), and the different overlay maps for that image would be
%       in dim(4).

%       If just 1 rgb img is given, e.g., size(rgbOverlay) = 100 100 3,
%       then outOl will be the same as the rgbOverlay input (nothing to
%       combine).

% 
%   w - (optional) these are the weights associated with each map.
%       Must have the same dimensions as rgbOverlays except for just 1
%       value instead of 3 for the dimension w/rgb values. For example,
%       for 2 maps of a 10x10 image, 
%               size(rgbOverlays) = 10 10 3 2
%               size(w) = 10 10 2, or 10 10 1 2
%       If w isn't provided, each map will be weighted evenly (so will
%       take a simple mean across the maps).
% 
% OUTPUT:
%   outOL - combined rgb overlay.
%   
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 18-Apr-2015
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% check rgbOverlays input argument 
if notDefined('rgbOverlays') 
    error('input rgbOverlays must be provided.')
end

% make sure 2nd to last dim of rgbOverlays is the right size for r,g,b vals
dim = size(rgbOverlays); % dimensions of rgbOverlays
if ~any(dim==3)
    error('dont know which dimension has rgb values.');
end

% dont do anything is only 1 overlay is given
if numel(dim)==3 || dim(4)==1
    fprintf('\n\nonly one overlay image given - returning input rgbOverlay.\n\n');
    outOl = rgbOverlays; 
    return
end


% define some useful dimension/size variables 
nOls = dim(end);


% if w isn't given, weight each rgbOverlay equally 
if notDefined('w')
    dim_w=dim; dim_w(end-1)=[];
    w = ones(dim_w); 
end
  

% reshape so that each map is now a column vector
wR=reshape(w,[],nOls);


% normalize so that weights across fd maps sum to 1 for each voxel
% that has at least some fd value.
wR=wR./repmat(sum(wR,2),1,nOls);


% use repmat to replicate weights to have 3 copies for r,g,b, values. 
% Then reshape weights back into slice shape.
w=reshape(repmat(wR,3,1),dim(1),dim(2),3,nOls);


 % get the weighted mean across overlays
outOl=sum(rgbOverlays.*w,4);


%% 
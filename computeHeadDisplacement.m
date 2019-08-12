function displacement = computeHeadDisplacement(dxyz)
% -------------------------------------------------------------------------
% usage: compute mean relative 3d volume-to-volume displacement. 
% 
% 
% INPUT:
%   dxyz - Nx3 matrix of displacements vectors measuring head displacement
%   relative to some constant reference (e.g., the first volume, or the
%   mean of all the volumes).
%   
% 
% OUTPUT:
%   displacement - volume-to-volume displacement. This
%   will be in whatever units the input is in. 
% 
% NOTES: this is calculated as the root mean square of x,y,z displacements.

% see ref for more details: 
% Van Dijk, K.R., Sabuncu, M.R., Buckner, R.L., 2012. The influence of head motion on in-
% trinsic functional connectivity MRI. Neuroimage.

% 
% author: Kelly, kelhennigan@gmail.com, 09-Aug-2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dxyz = [zeros(1,3);diff(dxyz)]; % relative volume-to-volume displacement

displacement=sqrt(sum(dxyz.^2,2)); % RMS = sqrt( dx^2 + dy^2 + dz^2)


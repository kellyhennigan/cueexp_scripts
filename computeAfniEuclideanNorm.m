function enorm = computeAfniEuclideanNorm(mp)
% -------------------------------------------------------------------------
% usage: compute euclidean norm of head motion based on AFNI's calculation
% of euclidean norm (see AFNI documentation for more details). 

% because 1 degree of rotation is roughly equivalent to 1 mm displacement
% at the surface of the brain, AFNI includes both translation (in units mm)
% and rotation (in units of degrees) to calculate this metric. 

% INPUT:
%   mp - nvols x 6 matrix, where columns are rigid body motion parameters
%   (translation (mm) and rotation (degrees) in x, y, z axes); note that
%   column order doesn't matter.

%   * translations MUST be in units of mm and rotations must be in degrees.
 
% OUTPUT:
%   enorm - volume-to-volume euclidean norm of displacement.  

% author: Kelly, kelhennigan@gmail.com, 09-Aug-2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enorm = [0;sqrt(sum(diff(mp).^2,2))];
      

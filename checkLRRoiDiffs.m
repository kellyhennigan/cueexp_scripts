function p = checkLRRoiDiffs(dL,dR)
% -------------------------------------------------------------------------
% usage: use this function to return stats for comparing ROI values from L
% and R ROIs; the idea is to test for hemispheric differences before
% collapsing across sides...
% 
% INPUT:
%   dL - MxN data matrix, with M subjects and N measures from left hemi roi
%   dR - " " from right hemi roi
% 
% OUTPUT:
%   p - p values testing for l and r differences 
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 23-Aug-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
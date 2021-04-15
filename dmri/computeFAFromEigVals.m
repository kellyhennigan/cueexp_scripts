function [fa,md]=computeFAFromEigVals(ev1,ev2,ev3)
% -------------------------------------------------------------------------
% usage: say a little about the function's purpose and use here
% 
% INPUT:
%   ev1,ev2,ev3 - eigenvalues of the principal (ev1), secondary, and
%   tertiary directional components
% 
% OUTPUT:
%   fa - fa value
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 11-May-2019

% FA equation found in Jellison et al (2004)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

md = (ev1 + ev2 + ev3)./3;

fa = sqrt(3./2) .* (sqrt((ev1-md).^2+(ev2-md).^2+(ev3-md).^2)./sqrt(ev1.^2+ev2.^2+ev3.^2));
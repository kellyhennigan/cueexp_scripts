function fwdisplacement = computeFrameWiseHeadDisplacement(mp)
% -------------------------------------------------------------------------
% usage: compute framewise displacement, averaged over volumes, as
% described in Power et al (2012) (see below for ref) 
% 
% 
% INPUT:
%   mp - 6 rigid body motion parameters; first 3 are translation & last 3
%   are rotation. 

%   * translations MUST be in units of mm and rotations must be in degrees.
%   
% 
% OUTPUT:
%   fwd - framewise displacement, averaged over volumes, in mm units 

% see ref for more details: 
% Jonathan D Power,a Kelly A Barnes,a Abraham Z Snyder,a,b Bradley L
% Schlaggar,a,b,c,d and Steven E Petersena,b,d,e Spurious but systematic
% correlations in functional connectivity MRI networks arise from subject
% motion Neuroimage. 2012 Feb 1; 59(3): 2142?2154. Published online 2011
% Oct 14. doi: 10.1016/j.neuroimage.2011.10.018

% 
% author: Kelly, kelhennigan@gmail.com, 09-Aug-2019

%%% ************ NOTE: double-check that this is correct before using; it
%%% seems to be returning values that ae quite high!!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


mp = [zeros(1,6);diff(mp)]; % relative volume-to-volume motion


%%%% convert rotations to displacement:

% convert rotation degrees to radians
mp(:,4:6)=deg2rad(mp(:,4:6)); 

% use Power et al (2012) method of getting displacement as arc length on a 50 mm radius sphere
r = 50;

% arc length formula is r*radians: 
mp(:,4:6) = r.*mp(:,4:6);


fwdisplacement = sum(abs(mp),2); % framewise displacement, as described in Power et al (2012)



function [fg1,fg2,cl_means]=clusterDANAccFibers(fg,doPlot)
% -------------------------------------------------------------------------
% usage: this function takes pathways between the midbrain and NAcc and
% clusters them into two groups according to their endpt coordinates.

% The idea is to use this to define a fiber group that goes below the
% anterior commissure from one that goes above it.
%
% INPUT:
%  fg - DA-NAcc fiber group with all pathways oriented to have the midbrain
%       endpoint as the first coordinate and the NAcc coordinate at the end.
%  doPlot - 1 to plot the out fiber groups, 0 to not plot. Default is 0.
%
% OUTPUT:
%  fg1 - clustered fiber group with the lowest mean z-coordinate in the
%  NAcc.
%  fg2 - " " with the higher z-coord NAcc endpoint
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 20-Dec-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

if notDefined('doPlot')
    doPlot=0;
end


% try to do kmeans clustering into 2 clusters based on endpt coords
[~,endpts]=getFGEnds(fg,[1,2],1);


[cl_idx,cl_means,~]=clusterEndpts(endpts',2,'kmeans');


% we expect that this should leave 2 groups: one that goes below the
% anterior commissure (AC), to hit the NAcc, and another that goes above
% the AC, into the internal capsule, and hits the NAcc from above. 

% so, we expect that 1 group should have a mean z-coord & y-coord that are
% less than the other group. If this isn't the case, check with the user to
% verify the cluster labels. 

% flip the cluster labels if necessary
if cl_means(1,5)>cl_means(2,5) && cl_means(1,6)>cl_means(2,6)
    cl_idx = abs(cl_idx-3);
    cl_means = flipud(cl_means);
end

% ask user which fiber group should be fg1 if ambiguous
fg1_idx=1;
if ~(cl_means(1,5)<cl_means(2,5) && cl_means(1,6)<cl_means(2,6))
    AFQ_RenderFibers(getSubFG(fg,cl_idx==1),'tubes',0,'color',[1 0 0]);
    AFQ_RenderFibers(getSubFG(fg,cl_idx==2),'tubes',0,'color',[0 0 1],'newfig',0);
   fg1_idx=input('\nwhich fiber group goes under the AC? \nEnter 1 for red or 2 for blue: ');
end

if fg1_idx==2
    cl_idx = abs(cl_idx-3);
    cl_means = flipud(cl_means);
end

% define 2 fiber groups based on clustering results
fg1=getSubFG(fg,cl_idx==1,'fg1');
fg2=getSubFG(fg,cl_idx==2,'fg2');

% plot, if desired
if doPlot
    AFQ_RenderFibers(fg1,'tubes',0,'color',[1 0 0]);
    AFQ_RenderFibers(fg2,'tubes',0,'color',[0 0 1],'newfig',0);
end
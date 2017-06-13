function [fgOut,endpts]=getFGEnds(fg,whichEnd,nEndNodes)
% -------------------------------------------------------------------------
% usage: this function takes in a fiber group and returns two separate
% fiber group structs that contain the first and last endpoints of each
% fiber in the group.
% 
% INPUT:
%   fg - fiber group structure 
%   whichEnd - first, last, or both fiber endpoints? Must be either 1, 2,
%              or [1,2]
%   nEndNodes - # of endpoint coords to give at each end. Default is 1.
%   


% OUTPUT:
%   fgOut - exact same as fg, except each fiber cell contains only the 
%           endpoint coordinates of each fiber. 
%   endpts - endpt coordinates of the fiber group returned as a M x N
%           matrix, where each column contains the desired endpoints for a
%           single fiber.
% 
% 
% author: Kelly, kelhennigan@gmail.com, 23-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if whichEnd isn't given, just give the first endpoint coord
if notDefined('whichEnd')
    whichEnd = 1; 
end

% if nEnds isn't given, just give the first endpoint coord
if notDefined('nEndNodes') 
    nEndNodes = 1; 
end
   
    
 fgOut=fg;  
 
% get fibers' first endpoints:
if whichEnd==1
 fgOut.fibers = cellfun(@(x) x(:,1:nEndNodes), fgOut.fibers,'UniformOutput',0);
 endpts = [fgOut.fibers{:}];

 % get fibers' last endpoints:
elseif whichEnd==2
 fgOut.fibers = cellfun(@(x) x(:,end-nEndNodes+1:end), fgOut.fibers,'UniformOutput',0);
 endpts = [fgOut.fibers{:}];

% give fibers' first and last endpoints  
else 
    fgOut.fibers = cellfun(@(x) x(:,[1:nEndNodes,end-nEndNodes+1:end]), fgOut.fibers,'UniformOutput',0);
    endpts = cell2mat(cellfun(@(x) reshape(x,[],1), fgOut.fibers, 'UniformOutput',0)');

    
end



function d=cohensd(x1,x2)
% -------------------------------------------------------------------------
% usage: compute cohen's d. 
% 
% INPUT:
%   x1 - data for group 1
%   x2 (optional) - data from group 2
% 
% OUTPUT:
%   d - cohen's d, defined as: 

% meanx1 - meanx2 
% ---------------
%    SDpooled
% 
% NOTES:
% if only x1 is given, then cohen's d is for paired or single-sample test,
% defined as: 

%   meanx1 
%  --------------
%    SDx1


% 
% author: Kelly, kelhennigan@gmail.com, 20-Nov-2018

% formulas from here: https://trendingsideways.com/the-cohens-d-formula
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('x2')
    
   
    SDx1=sqrt(sum((x1-mean(x1)).^2)./(numel(x1)-1)); % same as std(x1)
   
    d = mean(x1) / SDx1;
    
else
    
    SDpooled = sqrt((sum((x1-mean(x1)).^2)+sum((x2-mean(x2)).^2))./(numel(x1)+numel(x2)-2));
    
    d = (mean(x1)-mean(x2))./SDpooled;
    
end
    
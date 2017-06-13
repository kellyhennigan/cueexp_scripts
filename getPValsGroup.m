function p = getPValsGroup(tc)
% -------------------------------------------------------------------------
% usage: this function is to return p-values for multiple statistical
% tests; my intention is to use this for plotting sig differences on time
% course data.

% INPUT:
%   tc - timecourse data

%
% OUTPUT:
%   p - p values
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 28-Mar-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% for group comparisons:


    gi = []; % group index
    for g = 1:numel(tc)
        gi = [gi; repmat(g, size(tc{g},1),1)];
    end
    tc = cell2mat(tc);
    
    for i=1:size(tc,2)
        p(i) = anova1(tc(:,i),gi,'off');
    end
    
    
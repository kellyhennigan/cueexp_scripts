function p = getPVals(tc,rm)
% -------------------------------------------------------------------------
% usage: this function is to return p-values for multiple statistical
% tests; my intention is to use this for plotting sig differences on time
% course data.

% INPUT:
%   tc - timecourse data
%   rm - 1 for repeated measures, otherwise 0
%
% OUTPUT:
%   p - p values
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 28-Mar-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if not given, assume that data are NOT repeated measures
if notDefined('rm')
    rm = 0;
end

%% for group comparisons:

if ~rm
    
    gi = []; % group index
    for g = 1:numel(tc)
        gi = [gi; repmat(g, size(tc{g},1),1)];
    end
    tc = cell2mat(tc);
    
    for i=1:size(tc,2)
        p(i) = anova1(tc(:,i),gi,'off');
    end
    
    
    %% for repeated measures comparisons, use 2-way anova (same as using repeated measures anova)
else
    
    for i=1:size(tc{1},2)
        
        d = cell2mat(cellfun(@(x) x(:,i), tc','UniformOutput',0));
        p2= anova_rm(d,'off');
        p(i) = p2(1);
    
    end
    
    
end



function Z = t2z(t,df)
% -------------------------------------------------------------------------
% usage: convert t-stats to z-scores
% 
% INPUT:
%   t - t statistic
%   df -  degrees of freedom
% 
% OUTPUT:
%   Z - corresponding z-scores
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 14-Jun-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numel(df)==1 && numel(t)>1
    df = repmat(df,size(t));
end

Z = norminv(tcdf(double(t),double(df)),0,1); % Z score corresponding to a t-stat with df degrees of freedom


fprintf('\n\nWARNING:\n\n Z vals for abs(Z) vals greater than 10 or so\n will be returned as inf!!!\n\n') 

%% to get the p-val from the t or Z score, with 1 or 2 tails: 
% 
% p = 1-tcdf(t,df);  % for 1 tailed t stats
% 
% p = 2.*(1-tcdf(t,df)); % for 2-tailed t stats
% 
% p = 1-normcdf(Z); % for 1-tailed Z scores
% 
% p = 2.*(1-normcdf(Z)); % for 2-tailed Z scores


%% 

% 
% p = 2.*(1-tcdf(T_2tail,df)); % for 2-tailed T stats
% Z_2tail = norminv(1-(p./2)); % corresponding Z stats for two-tailed test



%% some useful code found here: 
% http://andysbrainblog.blogspot.com/2015/07/converting-t-maps-to-z-maps.html
% 
% 
% if strcmp(conversion,'TtoZ')
%     expval = ['norminv(tcdf(i1,' num2str(dof) '),0,1)'];
% elseif strcmp(conversion,'ZtoT')
%     expval = ['tinv(normcdf(i1,0,1),' num2str(dof) ')'];
% elseif strcmp(conversion,'-log10PtoZ')
%     expval = 'norminv(1-10.^(-i1),0,1)';
% elseif strcmp(conversion,'Zto-log10P')
%     expval = '-log10(1-normcdf(i1,0,1))';
% elseif strcmp(conversion,'PtoZ')
%     expval = 'norminv(1-i1,0,1)';
% elseif strcmp(conversion,'ZtoP')
%     expval = '1-normcdf(i1,0,1)';
% else
%     disp(['Conversion "' conversion '" unrecognized']);
%     return;

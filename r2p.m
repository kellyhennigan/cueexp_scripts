function p=r2p(r,N)

% according to this set: http://vassarstats.net/tabs_r.html
% you get p values for a correlation coefficient by transforming 
% coefficient r to a t-statistic. Then you get the p value for a % 
% 2-sided test. 

df = N-2; 

t = r ./ sqrt( (1 - r.^2)./df ); 

% now get p value for 2-tailed t stats
if t<0
    p = 2.*tcdf(t,df);
else
    p = 2.*(1-tcdf(t,df));
end
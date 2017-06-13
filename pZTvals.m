

p = [.05 .01 .005 .001 .0001];  % p-values

%%%%%%%%%%%%%%%% p to T stats %%%%%%%%%%%%%%%%
df = 17; 

T_1tail=tinv(1-p,df);  % corresponding T stats for one-tailed test

T_2tail=tinv(1-(p./2),df); % corresponding T stats for two-tailed test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%% p to Z scores %%%%%%%%%%%%%%%
Z_1tail = norminv(1-p); % corresponding Z stats for one-tailed test

Z_2tail = norminv(1-(p./2)); % corresponding Z stats for two-tailed test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%% T to p vals %%%%%%%%%%%%%%%
p = 1-tcdf(T_1tail,df)  % for 1 tailed T stats

p = 2.*(1-tcdf(T_2tail,df)); % for 2-tailed T stats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%% Z to p vals %%%%%%%%%%%%%%%
p = 1-normcdf(Z_1tail); % for 2-tailed T stats

p = 2.*(1-normcdf(Z_2tail)); % for 2-tailed Z scores

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


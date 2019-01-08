
a=[88 90 102 98 105 117 95 92 108 105]; 


% mean
mean(a)

% population variance (mean sum of squares): 
popvar=mean([a-mean(a)].^2);
isequal(popvar,var(a,1))

% sample variance (n-1 in denominator):
samplevar=sum([a-mean(a)].^2)./(numel(a)-1);
isequal(samplevar,var(a))


% population standard deviation
popsd=sqrt(popvar);
isequal(popsd,std(a,1));

% sample standard deviation
samplesd=sqrt(samplevar);
isequal(std(a),samplesd)

 
% t-test is defined as: mean(a)./se(a)
% where se(a) is defined as: sample SD of a / sqrt(n)
% where n is the # of elements in a
[h,p,~,stats]=ttest(a);
isequal(stats.tstat,)
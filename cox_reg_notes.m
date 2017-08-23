% from: https://onlinecourses.science.psu.edu/stat507/node/81

% Survival analysis methods, such as proportional hazards regression differ
% from logistic regression by assessing a rate instead of a proportion.

% Proportional hazards regression, also called Cox regression, models the
% incidence or hazard rate, or in our case, the relapse rate. 

% The hazard function is the probability that if a person survives to t,
% they will relapse in the next instant.
% 

% Cox regression model assumptions: 
% - independence of survival times between distinct individuals in the
% sample, 
% - a multiplicative relationship between the predictors and the hazard (as
% opposed to a linear one as is the case with multiple linear regression),
% - a constant hazard ratio over time.

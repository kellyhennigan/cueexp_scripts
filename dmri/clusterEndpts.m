function [cl_idx,cl_means,err_metric] = clusterEndpts(d,K,cl_method)
% -------------------------------------------------------------------------
% usage: cluster fiber endpt data
%
% INPUT:
%   d - N x p matrix with N observations and p dimensions (6 for endpt coords)
%   K - number of clusters to estimate. Must be either a scalar or a vector
%
%
% OUTPUT:
%
%   gmm:
%
%   kmeans:
%
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 07-May-2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% if data is in a cell, put it into a matrix
if iscell(d)
    d = cell2mat(d);
end

% do gaussian mixture model if cl_method isn't specified
if notDefined('cl_method')
    cl_method = 'gmm';
end


% rng('shuffle'); % for randomness or
rng(1);      % reproducibility



   %% estimate Gaussian mixture model with n components defined by numClusters
        
%         gm = gmdistribution.fit(roiTensors,nClusters,'Options',options);
%         idx = cluster(gm, roiTensors);     % gives a cluster index
%         


switch lower(cl_method)
    
    
    case 'gmm'
        
        % up the max number of interations to 1000
        options = statset('MaxIter',1000);
        
        % gmm = cell(K,1); % Preallocation
        
        gm = fitgmdist(d,K,'Options',options);  % estimate mixture model
        cl_idx = cluster(gm, d);     % gives a cluster index
        cl_means = gm.mu;
        AIC = gm.AIC;                   % aikike's information criterion
        BIC = gm.BIC;                   % bayesian information criterion
        nll = gm.NegativeLogLikelihood; % negative log-likelihood
        
        %         err_metric = [AIC BIC nll];
        err_metric = BIC;
        
    case 'kmeans'
        
        %% non-cell array method:
        
        %         opts = statset('Display','final');
        [cl_idx,cl_means,sumd]=kmeans(d,K,'MaxIter',500,'Replicates',4);
        
        
        SSw = sum(sumd);       % calculate within cluster sum of squares
        
        
        SSt = sum(pdist2(d,mean(d)).^2); % calculate total sum of squares
        
        
        R2 = 1 - SSw./SSt; % fractional variance
        
        
        err_metric = R2;   % error metric to return
        
        
end



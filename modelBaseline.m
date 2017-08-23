function Xbase = modelBaseline(nt,degrees)

% this function creates a design matrix for modeling the baseline of an
% fMRI time series with polynomial baseline regressors.
% 
% IdegreesUTS: 
%      nt - a scalar or vector of scalars specifying the # of TRs in each
%           scan run to model. So numel(nt) is the number of scan runs to
%           model separately.
%      degrees - specifies the higheswt order of polynomial expansion, e.g.
%           degrees = 0 will return a constant regressor of length=nt to
%           model for each scan run, or degrees = 2 will return a constant,
%           linear term, and quadatic term
% 
% note: afni recommends using 1 degree of polynomial expansion (so constant
% + linear trend) for runs <150 s; plus an extra degree for every
% additional 150 s of scan run time
% 
% OUTPUTS:
%      Xbase - design matrix with M rows x N columns. So # of rows M will
%           equal sum(nt) & # of columns N will equal (degrees+1)*numel(nt)
%     
% 
% kjh 20-Nov-2013
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nRuns = numel(nt); % number of scan runs to individually model
Nt = sum(nt);      % total number of time points across scan runs

% Xbase = zeros(sum(nt),nRuns*(degrees+1));
Xbase = [];

for i = 1:nRuns
    for j = 0:degrees
        Xbase_run{i}(:,j+1) = linspace(-1,1,nt(i))'.^j;
    end
    Xbase(end+1:end+nt(i),end+1:end+degrees+1) = Xbase_run{i};
end


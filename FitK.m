function [k, m, LL] = FitK(data)
% Usage: [k, m, LL] = FitK(data)
%
% Returns best fitting k for the discount function V=r/(1+kd).
% Input data must contain individual trials in rows with columns
%   [r1 d1 r2 d2 choice]
% for choices betwen r1 at delay d1 and r2 at delay d2. choice must
% be 1 for choice of option (r1,d1) or 2 to indicate choice of (r2,d2).
% Fitting is for maximum likelihood with a softmax function. m is the
% best fitting slope of the softmax function. Larger values of m
% indicate a better quality fit.
% LL is the log-likelihood of the best fit. This is useful for statistical
% analysis of the significance of fitted parameters (i.e. likelihood ratio
% test).
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if LL choice is indicated with zeros, change them to twos
data(data(:,5)==0,5)=2;

global d;
d = data;
LL = Inf;

options = optimset('MaxFunEvals', 100000, 'MaxIter', 100000);
for i = 1:100
	% k is usually pretty small, so restrict initial search to small range
	ki = rand * .02;
	mi = rand * 2;
	pi = [ki mi];

	[pf,llf] = fminsearch(@errorf, pi, options);
	if (llf < LL)
		p = pf;
		LL = llf;
	end;
end;

k = abs(p(1));
m = abs(p(2));
LL = -1*LL;
% plotFit(k,m);

function e = errorf(p)
	global d;

	% this forces the function to find positive k values in fitting
	k = abs(p(1));
	% if the best fitting m is negative, then this is bad news
	m = abs(p(2));

	ll = 0;

	for i = 1:size(d,1)
		V1 = d(i,1)/(1 + k*d(i,2));
		V2 = d(i,3)/(1 + k*d(i,4));

		P1 = 1/(1+ exp(-1*m*(V1-V2)));
	
		if (d(i,5) == 1) %choose (r1,d1)
			if (P1 == 0)
				e = Inf;
				return;
			end;
			ll = ll + log(P1);
		else
			if (P1 == 1)
				e = Inf;
				return;
			end;
			ll = ll + log(1-P1);
		end;
	end;

	e = -1 * ll;

function plotFit(k,m)
	global d;

	maxd1 = max(d(:,2));
	maxd2 = max(d(:,4));
	maxd = max([maxd1 maxd2]);

	subplot(1,2,1);
	t = [0:.1:maxd];
	plot(t, 1./(1+k*t), '-k');

	subplot(1,2,2);
	hold off;
	for i = 1:size(d,1)
		if (i == 2)
			hold on;
		end;
	
		early = 1;
		if (d(i,4) < d(i,2))
			early  = 2;
		end;

		x = [d(i,2) d(i,4)];
		y = [d(i,1)/(1+k*d(i,2)) d(i,3)/(1+k*d(i,4))];
		style = 'o-';
		if (d(i,5) == early)
			style = [style 'r'];
		else
			style = [style 'b'];
		end;
		plot(x,y,style);
	end;

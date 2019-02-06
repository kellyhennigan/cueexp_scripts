function [axH,rpStr] = plotCorr(axH,x,y,xlab,ylab,titleStr,col,mspec,msize,fsize)
% -------------------------------------------------------------------------
% usage: function to nicely plot a correlation between 2 variables x and y
%
% INPUT:
%   axH - axis handle for plotting
%   x - var1; single vector
%   y - var2; single vector
%   xlab - label for x-axis
%   ylab - label for y-axis
%   titleStr - string for plot title; if 'rp', corr coefficient and p value
%              will be plotted
%   col - rgb color; default is black
%

% OUTPUT:
%   axH - axis handle containing correlation plot
%   rpStr - string containing Pearson's correlation coefficient and p-vaue (e.g.,
%   'r=.30, p=.05')
%
%
% author: Kelly, kelhennigan@gmail.com, 11-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input variables

% if axis handle isn't provided, start a new figure
if notDefined('axH')
    fig=setupFig;
    axH = gca;
end

if notDefined('fsize')
    fsize=12;
end
set(gca,'fontName','Helvetica','fontSize',fsize);

if notDefined('x')
    x=randn(20,1);
end
if notDefined('y')
    y=randn(20,1);
end
if notDefined('xlab')
    xlab = '';
end
if notDefined('ylab')
    ylab = '';
end
if notDefined('titleStr')
    titleStr = '';
end
if notDefined('col')
    col = [0 0 0];
end
if notDefined('mspec')
    mspec = '.';
end
if notDefined('msize')
    msize = 30;
end

%% do it

% remove NaN values 
[nan_idx,~]=find(isnan([x,y]));
if numel(nan_idx)>0
    fprintf('\nremoving %d data points due to NaN values...\n',numel(unique(nan_idx)));
    x(nan_idx) = []; y(nan_idx) = [];
end

hold on

% plot data points as dots
plot(axH,x,y,mspec,'MarkerSize',msize,'color',col);


% plot correlation/best fit line
xl = [min(x), max(x)];
b=regress(y,[ones(numel(x),1),x]);
yl=xl*b(2)+b(1);
plot(axH,xl,yl,'LineWidth',2.5,'color',col)

% x and y axis limits
% xlim([min(x) max(x)])
% ylim([min(y) max(y)])

% x and y axis labels
xlabel(xlab)
ylabel(ylab)

% get string of Pearson's correlation coefficient and p value
[r,p]=corr(x,y);
if p<.06; pdig='3'; else pdig='2'; end % give p value 2 or 3 digits
rpStr = sprintf(['r=%.2f, p=%.' pdig 'f'],r,p);

% add title
if strcmpi(titleStr,'rp')
    titleStr = rpStr;
end
title(titleStr)

box off

hold off



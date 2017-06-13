
function fig = plotCorr2(x,y,xlab,ylab,titleStr,col,fig)
% -------------------------------------------------------------------------
% usage: function to nicely plot a correlation; data points are plotted as
% colored dots and correlation line is plotted as black line
% 
% INPUT:
%   x - var1
%   y - var2
%   xlab - label for x-axis 
%   ylab - label for y-axis
%   titleStr - string for plot title
%   col - rgb color 
%   

% OUTPUT:
%   fig - figure handle 
% 
% 
% author: Kelly, kelhennigan@gmail.com, 11-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input variables

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
    col = [0.4235    0.4431    0.7686];
end
if notDefined('fig')
    fig = setupFig;
end
hold on;

%% do it

% figure
scSize = get(0,'ScreenSize'); % get screensize for pleasant figure viewing :)


% place figure in top right of monitor for more convenient viewing
pos = get(gcf,'Position');
set(gcf,'Position',[scSize(3)-pos(3), scSize(4)-pos(4), pos(3), pos(4)])

plot(x,y,'.','MarkerSize',30,'color',col);
[r,p]=corr(x,y); 

% x and y coords for plotting a line
xl = [min(x)+.25, max(x)-.25];
b=regress(y,[ones(numel(x),1),x]);
yl=xl*b(2)+b(1);
plot(xl,yl,'LineWidth',2.5,'color','k')

xlim([min(x)-.25 max(x)+.25])

xlabel(xlab)
ylabel(ylab)

titleStr = sprintf('%s, r=%.2f, p=%.2f',titleStr,r,p);
title(titleStr)

hold off


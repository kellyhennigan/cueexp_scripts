function fig = plotNicePoints(x,y,cols,titleStr,xlab,ylab,legStrs,savePath)
% -------------------------------------------------------------------------
% usage: plot points on an axis nicely
% 
% INPUT:
%   x - vector (or cell array of vectors) of values to plot on x-axis 
%   y - vector (or cell array of vectors) of values to plot on y-axis
%   cols - 1x3 vector (or cell array) of rgb values for plot colors
            
% 
% OUTPUT:
%   fig
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 09-Nov-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check inputs
if notDefined('y')
    y={randn(20,1)};
end
if ~iscell(y)
    y={y};
end

if notDefined('x')
    for i=1:numel(y)
        x{i}=zeros(numel(y{i}),1)+i;
    end
end
if ~iscell(x)
    x={x};
end
    
if notDefined('cols')
    cols = {solarizedColors(numel(x))};
end

 
if notDefined('titleStr')
    titleStr = [];
end

if notDefined('xlab')
    xlab=[];
end

if notDefined('ylab')
    ylab = [];
end

if notDefined('legStrs')
    legStrs={};
end

if notDefined('savePath')
    savePath = [];
end

%%%%%% plotting params
markersize = 20; % markersize of points
fontName = 'Helvetica';
fontSize = 20; 


%% plot it

fprintf('plotting points...\n\n')

fig=setupFig;
set(gca,'fontName',fontName,'fontSize',fontSize)
hold on

for i=1:numel(x)
    plot(x{i},y{i},'.','color',cols(i,:),'markersize',markersize);
end
    
title(titleStr)
xlabel(xlab)
ylabel(ylab)


if ~isempty(legStrs)
    leg=legend(legStrs,'location','NorthEastOutside');
    legend(gca,'boxoff')
end

if ~isempty(savePath)
    print(fig,'-dpng','-r300',savePath);
end
    
fprintf('done.\n\n')
 


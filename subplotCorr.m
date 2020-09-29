function figH = subplotCorr(figH,x,y,xlab,ylab,titleStr,col)
% -------------------------------------------------------------------------
% usage: wrapper script for plotCorr() function to be able to plot multiple
% correlations as subplots. 

% x and y must be either a single vector or a cell array of single vectors. 
% if a single vector, it will be put into a cell array and repmat() will be
% used so that x and y have the same # of cells. 

% each cell in the array contains data for a subplot.
% 
% INPUT:
%   x - single column vector or cell array of single column vectors
%   y - single column vector or cell array of single column vectors
%   xlab & ylab - label(s) for axes; if more than 1 plot, these should be 
%                  cell arrays
%   titleStr - string or cell array of strings for plot titles
%   col - rgb values for plotting; must be either a 1x3 vector or a cell
%   array of 1x3 vectors for each subplot

% OUTPUT:
%   figH - figure handle
% 
% 
% author: Kelly, kelhennigan@gmail.com, 17-May-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% possibilities: 
% 1) x is a single vector, y is a cell array of single vectors
% 2) y is a single vector, x is a cell array of single vectors
% 3) x and y are both cell arrays of single vectors 
% 4) x and y are both single vectors

% fig1 = subplotCorr(scores,cellfun(@(x) mean(x(:,node),2), fgMeasures, 'uniformoutput',0),...
%     'BIS',fgMLabels,[strrep(fgMatStr,'_',' ') ' node ' nodeStr]);


%%%%%%%% check inputs

% figH
if notDefined('figH')
    figH=setupFig;
end

% x and y
if notDefined('x')
    x=randn(20,1);
end
if ~iscell(x)
    x = {x};
end
if notDefined('y')
    y=randn(20,1);
end
if ~iscell(y)
    y = cell2mat(y);
end

nP = max([numel(x),numel(y)]); % # of plots

% repmat x or y cell arrays as needed
if numel(x)<nP
    x=repmat(x,1,nP);
end
if numel(y)<nP
    y=repmat(y,1,nP);
end

% x label 
if notDefined('xlab')
    xlab = '';
end
if ~iscell(xlab)
    xlab={xlab};
end
if numel(xlab)==1
    xlab = repmat(xlab,1,nP);
end

% y label
if notDefined('ylab')
    ylab = '';
end
if ~iscell(ylab)
    ylab={ylab};
end
if numel(ylab)==1
    ylab = repmat(ylab,1,nP);
end

% titleStr
if notDefined('titleStr')
    titleStr = '';
end
if ~iscell(titleStr)
    titleStr = {titleStr};
end
if numel(titleStr)==1
    titleStr = repmat(titleStr,1,nP);
end

% col
if notDefined('col')
    col = [0 0 0];
end
if ~iscell(col)
    col = repmat({col},1,nP);
end

titleStr

%% do it

[nRow,nCol] = getNiceSPConfig(nP);

for i=1:nP
    
    axH=subplot(nRow,nCol,i);
    [axH,rpStr] = plotCorr(axH,x{i},y{i},xlab{i},ylab{i},titleStr{i},col{i});
% 
% FA xlim
% if i==1
%     xlim([.1 .5])
%     set(gca,'XTick',[.1:.1:.5])
% end
% % 
%     % MD
%     if i==2
%         xlim([.21 .55])
%         set(gca,'XTick',[.3:.1:.5])
%     end
end


% adjust fig size so that plots are square-shaped
    pos=get(figH,'Position');
    crr=nCol./nRow; %  column to row ratio
    newpos=[pos(1), pos(2), pos(3).*crr, pos(4)]
    set(figH,'Position',newpos)
    %     ss = get(0,'Screensize'); % screen size
    %     set(fig,'Position',[ss(3)-800 ss(4)-420 800 420]) % make figure 800 x 420 pixels
end



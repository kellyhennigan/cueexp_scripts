function [fig,hh] = plotNiceHist(d,nbins,col,titleStr,legStr,savePath)
% -------------------------------------------------------------------------
% hh = plotNiceHist(d,nbins,col,titleStr,legStr,savePath)
% usage: function to nicely plot a histogram of data

% 
% INPUT:
%   d - column vector of data
%   nbins (optional) - # of bins to plot
%   col (optional) - Nx3 RGB color values for plotting 
%   titleStr (optional) - title for plot if desired
%   legStr (optional) - string for legend if desired
%   savePath (optional) - a file path to save out the plot to
% 
% OUTPUT:
%   fig - figure handle
%   hh - histogram plot handle
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 10-Sep-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% unless color is specified as input, use a nice blue 
if notDefined('col')
    col = [0.1490    0.5451    0.8235];
end


% plot histogram(s)
fig = setupFig;

hold on
    
hh = histogram(d);
% hh.Normalization = 'probability';
hh.EdgeColor = [1 1 1];
hh.FaceColor = col;
hh.FaceAlpha=1

if ~notDefined('nbins')
    hh.NumBins = nbins;
end

% add title, if desired
if ~notDefined('titleStr')
    title(titleStr)
end

% add legend, if desired
if ~notDefined('legStr')
    legend(legStr)
    legend('boxoff')
end

hold off

% save, if desired
if ~notDefined('savePath')
    print(fig,'-dpng','-r300',savePath)
end






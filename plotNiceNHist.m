function hh = plotNiceNHist(d,cols,titleStr,legStr,savePath)
% -------------------------------------------------------------------------
% hh = plotNiceNHist(d,cols,titleStr,legStr,savePath)
% usage: function to nicely plot overlapping (semi-transparent) histograms 
% of data in the same figure for comparison purposes
% 
% INPUT:
%   d - 1xN cell array that contains a column vector of data for each 
%       group/measure to plot. If d is a matrix, each column will be
%       plotted as a separate histogram. 
%   cols (optional) - Nx3 RGB color values for plotting 
%   
% 
% OUTPUT:
%   hh - structural array of histogram handles corresponding to each plot
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 10-Sep-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if d is a MxN matrix, separate each column vector into its own cell
if ~iscell(d)
    d=mat2cell(d,[size(d,1)],[ones(1,size(d,2))]);
end

% use solarized colors by default
if notDefined('cols')
    cols = solarizedColors(numel(d));
end


% plot histogram(s)
fig = setupFig;
hold on

for i=1:numel(d)
    
    hh(i) = histogram(d{i});
    % hh{i}.Normalization = 'probability';
    hh(i).EdgeColor = [1 1 1];
    hh(i).FaceColor = cols(i,:);
    
end

% give them all equal # of bins and bin widths
bwidth=min([hh(:).BinWidth]); % SET BIN WIDTH
nbins=max([hh(:).NumBins]);   % SET # OF BINS
for i=1:numel(d)
    hh(i).BinWidth = bwidth; % smallest bin width
    hh(i).NumBins = nbins; % max # of bins
end

hold off

% add title, if desired
if ~notDefined('titleStr')
    title(titleStr)
end

% add legend, if desired
if ~notDefined('legStr')
    legend(legStr)
    legend('boxoff')
end

% save, if desired
if ~notDefined('savePath')
    print(fig,'-dpng','-r300',savePath)
end






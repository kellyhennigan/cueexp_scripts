function [h,figName] = plotFDMaps(slImg,plane,acpcSlice,saveFig,figDir,figPrefix)
% -------------------------------------------------------------------------
% usage: this function handles all the desired formatting specific to
% plotting fiber density overlay images
%
% INPUT:
%   slImg - MxNx3 image w/rgb vals in the 3rd dim
% 	plane and acpcSlice are just used for labeling, etc.
%
%   saveFig - if not defined, its set to [0 0]. Can be:
%       1 or [1 1] to save fig and cropped fig
%       [1 0]  to save fig but not cropped fig
%       [0 1]  to save only cropped fig
%       0 or [0 0] to save no figs
%
%

% OUTPUT:
%   hf - figure handle
%
% NOTES:
% h = plotFDMaps(slImg,plane,acpcSlice,
% author: Kelly, kelhennigan@gmail.com, 18-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


if notDefined('slImg') || size(slImg,3) ~=3
    error('must provide slImg w/rgb vals in the 3rd dim');
end

if notDefined('plane')
    plane = 0; % don't print any plane info
end

if notDefined('acpcSlice')
    acpcSlice = ''; % don't print any plane info
end

if notDefined('saveFig')
    saveFig = [0 0]; % don't save by default
end

if numel(saveFig)==1
    if saveFig==1
        saveFig=[1 1];
    else
        saveFig=[0 0];
    end
end

if any(saveFig)
    % if saving figure is desired but figDir not given, define it as pwd
    if notDefined('figDir')
        figDir = pwd;
    end
    if ~exist(figDir,'dir')
        mkdir(figDir)
    end
    
    % if saving figure and figPrefix is given, add '_' to the end if its not there already
    if notDefined('figPrefix') 
        figPrefix = 'fig';
    end
  
    
end

% get string specifying plane
switch plane
    case 1              % sagittal
        planeStr = 'X=';
    case 2              % coronal
        planeStr = 'Y=';
    case 3              % axial
        planeStr = 'Z=';
    otherwise
        planeStr = ''; % don't print plane info
end



%% plot it


h = figure;

scSize = get(0,'ScreenSize'); % get screensize to place fig in upper right corner of the screen
pos = get(gcf,'Position');
set(gcf,'Position',[scSize(3)-pos(3), scSize(4)-pos(4), pos(3), pos(4)]) % put the figure in the upper right corner of the screen

image(slImg)
axis equal; axis off;
set(gca,'Position',[0,0,1,1]);

% text(size(slImg,2)-20,size(slImg,1)-20,[planeStr,num2str(acpcSlice)],'color',[1 1 1])

figName = [figPrefix '_' planeStr num2str(acpcSlice)];


%% save figure?

if saveFig(1)==1
    
    fprintf(['\n\n saving out fig ' figName '...']);
    
    %     print(gcf, '-depsc', '-tiff', '-loose', '-r300', '-painters', fullfile(figDir,[figName '.eps']));
    %      saveas(h,fullfile(figDir,figName),'pdf');
    print(gcf,'-dpng','-r300',fullfile(figDir,figName))
    
    fprintf('done.\n');
    
end


%% cropped fig


midpt=ceil(size(slImg)./2);
cr = [midpt(1)-29, midpt(1)+30]; % crop rows (take mid horizontal strip, 60px tall)
cc = [midpt(2)-29, midpt(2)+30]; % crop columns (mid vertical strip, 60px wide)

switch plane
    
    case 1 % sagittal
        
        cc  =cc+10; % (looks better)
        croppedImg =slImg(cr(1):cr(2),cc(1):cc(2),:);
        
    case 2  % coronal
        cr = cr+15;
        croppedImg =slImg(cr(1):cr(2),cc(1):cc(2),:);
        
    case 3
        
        croppedImg =slImg(cr(1):cr(2),cc(1):cc(2),:);
        
end


% plot it
h(2) = figure;

pos = get(gcf,'Position');
set(gcf,'Position',[scSize(3)-pos(3), scSize(4)-pos(4), pos(3), pos(4)]) % put the figure in the upper right corner of the screen
image(croppedImg)
axis equal; axis off;
set(gca,'Position',[0,0,1,1]);


if saveFig(2)==1  % then plot and save
    
    croppedFigName = [figName '_cropped'];
    fprintf(['\n\n saving out cropped fig ' figName '...']);
    
    
    print(h(2),'-dpng','-r300',fullfile(figDir,croppedFigName));
    %         saveas(h(2),fullfile(figDir,croppedFigName),'pdf');
    
    fprintf('done.\n');
    
    
end






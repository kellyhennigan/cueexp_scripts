
function figH = plotMotionParams(mp)
% -------------------------------------------------------------------------
% usage: plot head movement parameters
% 
% INPUT:
%   mp - nVols x 6 matrix with the following columns:
%         roll - rotation along z-axis
%         pitch - rotation along x-axis
%         yaw - rotation along y-axis
%         dS - displacement along z-axis
%         dL - " " x-axis
%         dP - " " y-axis

% OUTPUT:
%     figH - figure handle

% 
% author: Kelly, kelhennigan@gmail.com, 07-Jan-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


labs = {'roll','pitch','yaw','dZ','dX','dY'};

c = solarizedColors;



figH = figure;
set(gcf,'Visible','off')
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

for i=1:6
    
subplot(6,1,i)

plot(mp(:,i),'color',c(i,:),'linewidth',1.5)
set(gca,'box','off');

xt = get(gca,'XTick');
set(gca,'XTick',[])

ylabel(labs{i})% legend

end

set(gca,'XTick',xt)
xlabel('TRs')


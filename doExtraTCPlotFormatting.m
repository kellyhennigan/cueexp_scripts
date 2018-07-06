% function doExtraTCPlotFormatting(fig,leg,roiName,savePath)
% -------------------------------------------------------------------------
% usage: do special formatting specific for paper figures that are
% VOI-specific 
% 
% INPUT:
%   
%   var2 - string specifying something
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 21-Mar-2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(gcf,'Visible','on')

% get y-axis params that are roi specific 
if strcmpi(roiName,'mpfc')
    
    YL = [-.2 .17]; % YL is ylim
    YT = [-.2:.05:.2]; % YT determines YTicks

elseif strcmpi(roiName,'nacc_desai')
    
    YL = [-.13 .11]; % YL is ylim
    YT = [-.1:.05:.1]; % YT determines YTicks

elseif strcmpi(roiName,'vta')
    
    YL = [-.14 .14]; % YL is ylim
    YT = [-.1:.05:.1]; % YT determines YTicks

elseif strcmpi(roiName,'ins_desai')
 
    YL = [-.16 .2]; % YL is ylim
    YT = [-.2:.05:.2]; % YT determines YTicks

end


%% 
    %%%%%%% make lines thicker
    lw=4;
    ch=get(gca,'Children');
    set(ch(:),'LineWidth',lw)
    
    
    %%%%%%% manually change y axis here:
    if ~notDefined('YT')
        set(gca,'YTick',YT)
    end
    
    if ~notDefined('YL')
        ylim([YL(1) YL(2)])
    end
    

    %%%%%%% grayed out rectangles    
    yl = ylim; 
    t=get(gca,'XTick');
    
    gxs = [5 13]; % x-axis limits for graying out
    
    % vertices
    v = [t(1) yl(1);
        t(1) yl(2);
        gxs(1) yl(2);
        gxs(1) yl(1);
        gxs(2) yl(1);
        gxs(2) yl(2);
        t(end) yl(2);
        t(end) yl(1)];
    
    patch('Faces',[1:4;5:8],'Vertices',v,'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5)
    
    % legend off
    legend(gca,'off')
    
    % ylim
    ylim([yl(1) yl(2)])
    
    % xlim and xtick
    xlim([t(1) t(end)])
    set(gca,'xtick',t)
    
    % change font size
    fsize = 26;
    set(gca,'fontName','Helvetica','fontSize',fsize)
    %         title('NAc response to drugs-neutral trials','fontName','Helvetica','fontSize',fsize)
  
    % xlabel
    xl=get(gca,'xlabel');
    xl.FontName='Helvetica';
    xl.FontSize=fsize;
    
    % y label
    ylabel([],'fontName','Helvetica','FontSize',fsize)
    
    
    % title (remove)
    title('')
    
    % re-save fig with changed formatting
    print(gcf,'-dpng','-r300',savePath);
    
    
    fprintf('done.\n\n')
    
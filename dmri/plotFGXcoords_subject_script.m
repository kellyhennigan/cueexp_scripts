
clear all
close all

rng('default')

% get experiment-specific paths and cd to main data directory
p = getCuePaths;
dataDir = p.data;
figDir = p.figures_dti;
outDir=[figDir '/subject_xcoord_plots'];

subjects=getCueSubjects('dti',0); 
% subjects={'tm160117','ph161104'};

% fibers directory relative to subject dir
% inDir = fullfile(dataDir,'fg_densities','mrtrix_fa');
inDir = fullfile(dataDir,'%s','fibers','mrtrix_fa'); 

fgNames = {'DA%s_nacc%s_belowAC_autoclean.pdb';
    'DA%s_nacc%s_aboveAC_autoclean.pdb';
    'DA%s_caudate%s_autoclean.pdb';
    'DA%s_putamen%s_autoclean.pdb'};


LR=['L','R'];


fgStrs = {'Inferior NAcc tract';...
    'Superior NAcc tract';...
    'Caudate tract';...
    'Putamen tract'};


msize=30;

cols=[
    0.9333    0.6980    0.1373
    0.9569    0.3961    0.0275
    0.9804    0.0941    0.1137
    0.1725    0.5059    0.6353];

%%


% create dir for saving out figs, if desired
if ~exist(outDir,'dir')
    mkdir(outDir)
end



%% load fg groups

i=1;
for i=1:numel(subjects)

    subject=subjects{i};

     for lr=LR
% lr='R'; 

    j=1    
    for j=1:numel(fgNames)
        
    fg=fgRead([sprintf(inDir,subject) '/' sprintf(fgNames{j},lr,lr)]);
     
    % get just DA endpts
   endpts=cell2mat(cellfun(@(x) x(:,1), fg.fibers','uniformoutput',0))';
   
   % get an index to randomly select 100 fibers
   idx=randperm(size(endpts,1),100);
   
   x(:,j)=endpts(idx,1);
   y(:,j)=endpts(idx,2);
   z(:,j)=endpts(idx,3);
   
    end
  

%% 


fig=setupFig;
hold on
for  j=1:numel(fgNames)
    plot(x(:,j),y(:,j),'.','markersize',msize,'color',cols(j,:))
end
xlabel('X coordinates')
ylabel('Y coordinates')
outName = [subject lr '_XYcoords_points'];
print(fig,fullfile(outDir,outName),'-depsc')

legend(fgStrs)
legend('boxoff')
legend('location','EastOutside')
outName = [outName '_w_leg'];
print(fig,fullfile(outDir,outName),'-depsc')
hold off


fig=setupFig;
hold on
for j=1:numel(fgNames)
    plot(x(:,j),z(:,j),'.','markersize',msize,'color',cols(j,:))
end
% set(gca,'fontName','Helvetica','fontSize',16)
xlabel('X coordinates')
ylabel('Z coordinates')
outName = [subject lr '_XZcoords_points'];
print(fig,fullfile(outDir,outName),'-depsc')

legend(fgStrs)
legend('boxoff')
legend('location','EastOutside')
outName = [outName '_w_leg'];
print(fig,fullfile(outDir,outName),'-depsc')
hold off

close all

     end
     
end
% fig=setupFig;
% hold on
% for  j=1:numel(fgNames)
%     plot3(x(:,j),y(:,j),z(:,j),'.','markersize',msize,'color',cols(j,:))
% end
% xlabel('X coordinates')
% ylabel('Y coordinates')
% zlabel('Z coordinates')
% view([0,0]) % x on x-axis, z on y-axis
% 
% view(0,90) % x on x-axis, y on y-axis
% 
% outName = ['LR_XYZcoords_points_' gspace];
% print(fig,fullfile(outDir,outName),'-depsc')
% 
% legend(fgStrs)
% legend('boxoff')
% legend('location','EastOutside')
% outName = [outName '_w_leg'];
% print(fig,fullfile(outDir,outName),'-depsc')
% hold off
% 

% fig=setupFig;
% hold on
% for j=1:numel(targets)
%     plot3(x(:,j),y(:,j),z(:,j),'.','markersize',msize,'color',cols(j,:))
% end
% xlabel('X coordinates (medial - lateral)')
% ylabel('Y coordinates (anterior - posterior)')
% zlabel('Z coordinates (superior - inferior)')
% outName = ['LR_XYZcoords_points_' gspace];
% print(fig,fullfile(outDir,outName),'-depsc')
% 
% legend(fgStrs)
% legend('boxoff')
% legend('location','EastOutside')
% outName = [outName '_w_leg'];
% print(fig,fullfile(outDir,outName),'-depsc')




% %% histogram and distribution plots
% 
% xc=mat2cell(x,[size(x,1)],[1 1 1 1]);
% 
% hh=plotNiceNHist(xc,cols)
% hold on
% yl=ylim;
% mx=median(x);
% j=1;
% for j=1:numel(targets)
%     plot([mx(j) mx(j)],[0 yl(2)],'--','color',[.1 .1 .1],'Linewidth',1)
% end
% set(gca,'fontName','Helvetica','fontSize',16)
% 
% outName = ['Xcoords_hist_' gspace];
% print(gcf,'-dpng','-r300',fullfile(outDir,outName))
% 
% legend(fgStrs)
% legend('location','EastOutside')
% legend('boxoff')
% outName = [outName '_w_leg'];
% print(gcf,'-dpng','-r300',fullfile(outDir,outName))
% 
% %
% %         outName = [fgMatStr '_' group{:} cvStr];
% %         print(fig{f},fullfile(outDir,outName),'-depsc')
% %     end
% 
% 
% 
% %%
% 
% fig=setupFig
% hold on
% for  j=1:numel(targets)
%     [f,xi]=ksdensity(x(:,j));
%     plot(xi,f,'color',cols(j,:),'linewidth',2);
% end
% outName = ['Xcoords_dist_' gspace];
% print(gcf,fullfile(outDir,outName),'-depsc')
% 
% legend(fgStrs)
% legend('location','EastOutside')
% legend('boxoff')
% outName = [outName '_w_leg'];
% print(gcf,fullfile(outDir,outName),'-depsc')
% 



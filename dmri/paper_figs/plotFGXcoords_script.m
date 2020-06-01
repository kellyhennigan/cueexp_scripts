
clear all
close all

% get experiment-specific paths and cd to main data directory
p = getCuePaths;
dataDir = p.data;
figDir = p.figures_dti;
outDir=[figDir '/paper_figs/fig2_xcoord_plots'];

% fibers directory relative to subject dir
% inDir = fullfile(dataDir,'fg_densities','mrtrix_fa');
inDir = fullfile(dataDir,'fgendpt_com_coords');

seed = 'DA';

targets = {'nacc','nacc','caudate','putamen'};

gspace = 'mni';

CoMFileStrs = {[seed '%s_%s%s_belowAC_autoclean_DAendpts_CoM_' gspace '.txt'];
    [seed '%s_%s%s_aboveAC_autoclean_DAendpts_CoM_' gspace '.txt']
    [seed '%s_%s%s_autoclean_DAendpts_CoM_' gspace '.txt'];
    [seed '%s_%s%s_autoclean_DAendpts_CoM_' gspace '.txt']}; % %s's are: L/R, target, L/R

lr='R';

mergeLR=0; 


fgStrs = {'Inferior NAcc tract';...
    'Superior NAcc tract';...
    'Caudate tract';...
    'Putamen tract'};

% cd /Users/kelly/cueexp/data/fg_densities/mrtrix_fa/endpt_coords
% 
% % load('LRcoords.mat');
% 
% l=load('Lcoords.mat')
% l.x=abs(l.x);
% r=load('Rcoords.mat')
% x=[l.x;r.x]; y=[l.y;r.y]; z=[l.z;r.z];

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



%% load CoM coords

% combine L and R sides
if mergeLR

    lr='LR';
    j=1    
    for j=1:numel(targets)
        
        TL=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},'L',targets{j},'L')));
        TR=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},'R',targets{j},'R')));
        
        % make sure the CoM files have the same subjects in the same order
        if j==1
            subjects=table2array(TL(:,1));
        end
        if ~isequal(TL.Var1,subjects) || ~isequal(TR.Var1,subjects)
            error('hold up - the subjects in the center of mass files arent the same!')
        end
        
        comL=table2array(TL(:,2:4)); 
        comL(:,1)=abs(comL(:,1)); % get abs value for left x coords
        
% %         CoM{j}=[comL+table2array(TR(:,2:4))]./2; % get average over left and right
        CoM{j}=[comL;table2array(TR(:,2:4))]; % get left and right (not averaged)
        
        x(:,j)=CoM{j}(:,1); y(:,j)=CoM{j}(:,2); z(:,j)=CoM{j}(:,3);
    
    end

    
% to NOT merge L and R: 
else 

    
    for j=1:numel(targets)
        
        T=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},lr,targets{j},lr)));
        
        % make sure the CoM files have the same subjects in the same order
        if j==1
            subjects=table2array(T(:,1));
        else
            if ~isequal(T.Var1,subjects)
                error('hold up - the subjects in the center of mass files arent the same!')
            end
        end
        CoM{j}=table2array(T(:,2:4));
        x(:,j)=CoM{j}(:,1); y(:,j)=CoM{j}(:,2); z(:,j)=CoM{j}(:,3);
    end
  
end %mergeLR


%% 


fig=setupFig;
hold on
for  j=1:numel(targets)
    plot(x(:,j),y(:,j),'.','markersize',msize,'color',cols(j,:))
end
xlabel('X coordinates (medial - lateral)')
ylabel('Y coordinates (anterior - posterior)')
outName = ['LR_XYcoords_points_' gspace];
print(fig,fullfile(outDir,outName),'-depsc')

legend(fgStrs)
legend('boxoff')
legend('location','EastOutside')
outName = [outName '_w_leg'];
print(fig,fullfile(outDir,outName),'-depsc')



fig=setupFig;
hold on
for j=1:numel(targets)
    plot(x(:,j),z(:,j),'.','markersize',msize,'color',cols(j,:))
end
set(gca,'fontName','Helvetica','fontSize',16)

xlabel('X coordinates (medial - lateral)')
ylabel('Z coordinates (superior - inferior)')

outName = ['LR_XZcoords_points_' gspace];
print(fig,fullfile(outDir,outName),'-depsc')

legend(fgStrs)
legend('boxoff')
legend('location','EastOutside')
outName = [outName '_w_leg'];
print(fig,fullfile(outDir,outName),'-depsc')




fig=setupFig;
hold on
for j=1:numel(targets)
    plot3(x(:,j),y(:,j),z(:,j),'.','markersize',msize,'color',cols(j,:))
end
xlabel('X coordinates (medial - lateral)')
ylabel('Y coordinates (anterior - posterior)')
zlabel('Z coordinates (superior - inferior)')
outName = ['LR_XYZcoords_points_' gspace];
print(fig,fullfile(outDir,outName),'-depsc')

legend(fgStrs)
legend('boxoff')
legend('location','EastOutside')
outName = [outName '_w_leg'];
print(fig,fullfile(outDir,outName),'-depsc')




%% histogram and distribution plots

xc=mat2cell(x,[size(x,1)],[1 1 1 1]);

hh=plotNiceNHist(xc,cols)
hold on
yl=ylim;
mx=median(x);
j=1;
for j=1:numel(targets)
    plot([mx(j) mx(j)],[0 yl(2)],'--','color',[.1 .1 .1],'Linewidth',1)
end
set(gca,'fontName','Helvetica','fontSize',16)

outName = ['Xcoords_hist_' gspace];
print(gcf,'-dpng','-r300',fullfile(outDir,outName))

legend(fgStrs)
legend('location','EastOutside')
legend('boxoff')
outName = [outName '_w_leg'];
print(gcf,'-dpng','-r300',fullfile(outDir,outName))

%
%         outName = [fgMatStr '_' group{:} cvStr];
%         print(fig{f},fullfile(outDir,outName),'-depsc')
%     end



%%

fig=setupFig
hold on
for  j=1:numel(targets)
    [f,xi]=ksdensity(x(:,j));
    plot(xi,f,'color',cols(j,:),'linewidth',2);
end
outName = ['Xcoords_dist_' gspace];
print(gcf,fullfile(outDir,outName),'-depsc')

legend(fgStrs)
legend('location','EastOutside')
legend('boxoff')
outName = [outName '_w_leg'];
print(gcf,fullfile(outDir,outName),'-depsc')


%% fake fig to get legend for Haber plot


fig=setupFig;
hold on
for i=[1 3 4]
    plot(x(:,i),z(:,i),'.','markersize',msize,'color',cols(i,:))
end
set(gca,'fontName','Helvetica','fontSize',16)


outName = ['haber_legend'];
print(fig,fullfile(outDir,outName),'-depsc')

legend({'Limbic striatum','Associative striatum','Motor striatum'})
legend('boxoff')
legend('location','EastOutside')
print(fig,fullfile(outDir,outName),'-depsc')



% plot roi time courses by subject

% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;
outDir = [p.figures_dti '/fgm_trajectories'];


% directory & filename of fg measures
method = 'mrtrix_fa';

targets={'nacc';
    'nacc';
    'caudate';
    'putamen'};

fgStrs = {'_belowAC';
    '_aboveAC';
    '';
    ''};

fgMatStrs = {'DA%s_%s%s%s_dil2_autoclean';
    'DA%s_%s%s%s_dil2_autoclean';
    'DA%s_%s%s%s_dil2_autoclean';
    'DA%s_%s%s%s_dil2_autoclean'};

titleStrs = {'NAcc pathway (inferior)';...
    'NAcc pathway (superior)';...
    'Caudate pathway';...
    'Putamen pathway'};

% fgMatStrs = {'DALR_caudateLR_dil2_autoclean'};

% corresponding labels for saving out
fgMatLabels = strrep(fgMatStrs,'_dil2_autoclean','');

% plot groups
% group = {'controls','patients'};
% groupStr = '_bygroup';
% lspec = {'-','--'};

group = {'controls'};
groupStr = 'controlsLR';
lspec = {'-','--'};


% group = {'controls','relapsers','nonrelapsers'};
% groupStr = '_byrelapse';


cols=cellfun(@(x,y) getDTIColors(x,y), targets,fgStrs, 'uniformoutput',0); % plotting colors for groups
cols(:,2)=cols; % plot L and R as the same color

omit_subs = {}; % as170730 is too old for this sample

% fgMPlots = {'FA','MD','RD','AD'}; % fg measure to plot as values along pathway node
fgMPlots={'FA','MD'};

plotStats=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end


j=1;
for j=1:numel(fgMatStrs)
    
    fgMatStrL=sprintf(fgMatStrs{j},'L',targets{j},'L',fgStrs{j});
    fgMatStrR=sprintf(fgMatStrs{j},'R',targets{j},'R',fgStrs{j});
    fgMatLabel=sprintf(fgMatLabels{j},'',targets{j},'',fgStrs{j});
    
    
    %%%%%%%%%%%% get fiber group measures
    fgMeasuresL=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStrL '.mat']),'',[group{:}],omit_subs);
    nNodes = size(fgMeasuresL{1},2);
    
    %%%%%%%%%%%% get fiber group measures
    [fgMeasuresR,fgMLabels,~,subjects,gi]=loadFGBehVars(...
        fullfile(dataDir,'fgMeasures',method,[fgMatStrR '.mat']),'',[group{:}],omit_subs);
    
    
    %%%%%%%%%%% loop through diff measures to plot
    k=1;
    for k=1:numel(fgMPlots)
        
        fgMPlot=fgMPlots{k};
        
        % get desired diff measure to plot for L and R sides
        groupfgm{1}=fgMeasuresL{strcmp(fgMPlot,fgMLabels)};
        groupfgm{2}=fgMeasuresR{strcmp(fgMPlot,fgMLabels)};
        
        % average across mid 50% of the pathway and test for L vs R diffs
        [h,p,~,stats]=ttest(mean(groupfgm{1}(:,26:75),2),mean(groupfgm{2}(:,26:75),2));
        fprintf('\nttest for %s differences in L vs R %s:\nt(%d)=%.2f, p=%.3f\n\n\n',fgMPlot,fgMatLabel,stats.df,stats.tstat,p);
        
        % if desired, plot p-value from ttest
        pp=nan(1,nNodes);
        if plotStats
            pp(50)=p;
        end
        
        mean_fg = cellfun(@mean, groupfgm,'uniformoutput',0);
        se_fg = cellfun(@(x) std(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        
        
        %%%%%%%%%% plotting params
        xlab = 'fiber group node';
        ylab = fgMPlot;
        %         cols=repmat({getDTIColors(targets{j},fgMatStr)},size(group)); % plot groups as same color
        
        figtitle = [strrep(fgMatLabel,'_',' ') ' ' strrep(groupStr,'_',' ') ];
        
        savePath = fullfile(outDir,[fgMatLabel '_' fgMPlot groupStr]);
        plotToScreen=1;
        lineLabels={'L','R'};
        
        
        %%%%%%%%%%% finally, plot the thing!
        [fig,leg]=plotNiceLines(1:nNodes,mean_fg,se_fg,cols(j,:),pp,lineLabels,...
            xlab,ylab,figtitle,[],plotToScreen,lspec);
        hold on
        yl=ylim
        plot([26 26],[yl(1) yl(2)],'--','color',[.3 .3 .3],'linewidth',2)
        plot([75 75],[yl(1) yl(2)],'--','color',[.3 .3 .3],'linewidth',2)
        ylim(yl)
        legend HIDE
        %         print(fig,savePath,'-depsc')
        %         print(fig,savePath,'-dpdf')
        print(gcf,'-dpng','-r300',savePath);
        
    end % fg measures (fgMPlots)
    
end % fiber groups (fgMatStrs)



% tic
%  print(gcf,'-dpng','-r300',savePath);
%   print(gcf,'-dpng','-r300',savePath);
%    print(gcf,'-dpng','-r300',savePath);
%     print(gcf,'-dpng','-r300',savePath);
%      print(gcf,'-dpng','-r300',savePath);
% %
% print(fig,savePath,'-depsc')
% print(fig,savePath,'-depsc')
% print(fig,savePath,'-depsc')
% print(fig,savePath,'-depsc')
% print(fig,savePath,'-depsc')
% toc



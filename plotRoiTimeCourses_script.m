% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.


clear all
close all


% get paths for cue data & claudia's cue data
p = getCuePaths_Claudia;
dataDir2 = p.data;

p = getCuePaths;
dataDir = p.data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

figDir = p.figures;

tcDir = 'timecourses_ants';
tcDir2 = 'timecourses';

% roiStrs = {'nacc','dlpfc','ins','caudate','acing','mpfc'};

roiStrs = {'LC'};


% specify which groups to plot. 'all' means plot grand average across
% groups.
% groups = {'controls','patients'}; % controls, patients, or both
groups = {'controls'};

% specify specific stim types (e.g., 'food', or 'strong_want', etc.
% or 'want' for all want rating bins or 'type' for all image types
stimStr = {'type'};

nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR

saveFig = 1;

useSpline = 0; % if 1, time series will be upsampled by TR*10

omitSubs = {'as160317'};

plotStats = 1;

%% do it


stims = getStimNames(stimStr); % if stimStr = 'type' or 'want', this returns a cell array of relevant stimNames

t = 0:TR:TR.*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

r=1;
for r = 1:numel(roiStrs)
    
    roiStr = roiStrs{r};
    
    tc = {};
    
    % get time courses & plot Labels in a cell array where each cell will be a line plot.
    pLabels = repmat(stims,numel(groups),1); pLabels = strrep(pLabels,'_',' ');
    
    
    for g=1:numel(groups)
        
        if strcmpi(groups{g},'alcpatients') || strcmpi(groups{g},'2')
            inDir = fullfile(dataDir2,tcDir2,roiStr);
        else
            inDir = fullfile(dataDir,tcDir,roiStr);
        end
        
        [tc(g,:),subjects(g,:)]=cellfun(@(x) loadRoiTimeCourses(fullfile(inDir,[x '.csv']),groups{g},nTRs), stims,'uniformoutput',0);
        
        % omit subjects?
        if any(ismember(subjects{g,1},omitSubs))
            omit_idx=find(ismember(subjects{g,1},omitSubs));
            for i = 1:size(subjects(g,:),2)
                subjects{g,i}(omit_idx)=[];
                tc{g,i}(omit_idx,:)=[];
            end
        end
        
        if numel(groups)>1
            pLabels(g,:) = cellfun(@(x) [x ' ' groups{g} ' (n=' num2str(size(tc{g,1},1)) ')'], pLabels(g,:), 'uniformoutput',0);
        end
        
    end
    
    tc = reshape(tc,[],1);
    pLabels = reshape(pLabels,[],1);
    
    mean_tc = cellfun(@nanmean, tc,'uniformoutput',0);
    se_tc = cellfun(@(x) nanstd(x,1)./sqrt(size(x,1)), tc,'uniformoutput',0);
    
    
    if (useSpline) %  upsample time courses
        t_orig = t;
        t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
        mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
        se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
    end
    
    %% plot it
    
    cols = getCueExpColors(numel(tc),'cell');
    
    figH = figure;
    set(figH, 'Visible', 'off');
    hold on
    ss = get(0,'Screensize'); % screen size
    
    set(figH,'Position',[ss(3)-700 ss(4)-525 700 525]) % make figure 700 x 525 pixels
    set(gca,'fontName','Arial','fontSize',14)
    set(gca,'box','off');
    set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
    
    cellfun(@(x,y) plot(t,x,'color',y,'linewidth',2), mean_tc,cols)
    
    % legend
    legend(pLabels,'Location','Best')
    legend(gca,'boxoff')
    % xlim([1 numel(xt)])
    % set(gca,'XTick',xt)
    xlabel('time (in seconds) relative to cue onset')
    ylabel('%\Delta BOLD')
    
    % shaded error bar
    h=cellfun(@(x,y,z) shadedErrorBar(t,x,y,{'color',z},.5), mean_tc, se_tc, cols, 'uniformoutput',0);
    cellfun(@(x) set(x.edge(1), 'Visible','off'), h)
    cellfun(@(x) set(x.edge(2), 'Visible','off'), h)
    hc = get(gca,'Children');
    set(hc,'Linewidth',2);
    
    % if plotting stats:
    if plotStats
        if numel(groups)>1
            p = getPVals(tc,0);
        else
            p = getPVals(tc,1);
        end
        yL = ylim;
        ystats = mean([max(cell2mat(cellfun(@(x,y) max(x+y), mean_tc, se_tc, 'UniformOutput',0))),yL(2)]);
        for i=1:numel(p)
            if p(i)<.001
                text(xt(i),ystats,'***','FontName','Times','FontSize',24,'HorizontalAlignment','center','color','k')
            elseif p(i) < .01
                text(xt(i),ystats,'**','FontName','Times','FontSize',24,'HorizontalAlignment','center','color','k')
            elseif p(i) < .05
                text(xt(i),ystats,'*','FontName','Times','FontSize',24,'HorizontalAlignment','center','color','k')
            end
        end
    end
    
    % group string & plot title
    if numel(groups)>1
        groupStr = 'bygroup';
        title([roiStr ' response to ' stimStr{1} ' ' groupStr]);
    else
        groupStr = groups{1};
        title([groupStr '(n=' num2str(size(tc{1},1)) ') ' roiStr ' response to ' stimStr{1}]);
    end
    
    
    
    %% save figure?
    
    % nomenclature: roiStr_stimStr_groupStr
    
    if saveFig
        
        outName = [roiStr '_' [stimStr{:}] '_' groupStr];
        
        outDir = fullfile(figDir,tcDir,roiStr);
        
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        
        print(gcf,'-dpng','-r600',fullfile(outDir,outName));
    end
    
    
end % roiStrs







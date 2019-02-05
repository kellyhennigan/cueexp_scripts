% plot roi time courses by subject

% this will produce a figure with a timecourse line for each subject

clear all
close all


%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;
outDir = [p.figures '/dti/group_diffs'];


% directory & filename of fg measures
method = 'mrtrix_fa';


fgMatStrs = {'DALR_naccLR_belowAC_dil2_autoclean';
    'DALR_naccLR_aboveAC_dil2_autoclean';
    'DALR_naccLR_dil2_autoclean';
    'DALR_caudateLR_dil2_autoclean';
    'DALR_putamenLR_dil2_autoclean'};


% corresponding labels for saving out
fgMatLabels = strrep(fgMatStrs,'_dil2_autoclean','');

% plot groups
group = {'controls','patients'};
groupStr = '_bygroup';

% group = {'controls','relapsers','nonrelapsers'};
% groupStr = '_byrelapse';


cols=cellfun(@(x) getCueExpColors(x), group, 'uniformoutput',0); % plotting colors for groups

omit_subs = {'as170730'}; % as170730 is too old for this sample
    %     'jr160507'
    %     % 	'gm160909'
    %     'ld160918'
    %     'gm161101'
    %     %     'cg160715'
    %     % 	'jn160403'
    %     % 	'sr151031'
%     };

% fgMPlots = {'FA','MD','RD','AD'}; % fg measure to plot as values along pathway node
fgMPlots={'FA','MD'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

if ~exist(outDir,'dir')
    mkdir(outDir)
end


j=1;
for j=1:numel(fgMatStrs)
    
    fgMatStr=fgMatStrs{j};
    fgMatLabel=fgMatLabels{j};
    
    
    %%%%%%%%%%%% get fiber group measures
    load(fullfile(dataDir,'fgMeasures',method,[fgMatStr '.mat']))
    
    
    %%%%%%%%%%%% hack so that epiphany patients are in the same
    %%%%%%%%%%%% patient group as VA patients
    gi(gi>0)=1;
    
    %%%%%%%%%%%% any subjects to exclude?
    keep_idx = ones(numel(subjects),1);
    keep_idx=logical(keep_idx.*~ismember(subjects,omit_subs));
    subjects = subjects(keep_idx);
    gi = gi(keep_idx);
    fgMeasures = cellfun(@(x) x(keep_idx,:), fgMeasures,'uniformoutput',0);
    
    
    %%%%%%%%%%% get desired fg measure broken down by group
    k=1;
    for k=1:numel(fgMPlots)
        
        fgMPlot=fgMPlots{k};
        
        for g=1:2
            groupfgm{g} = fgMeasures{find(strcmp(fgMPlot,fgMLabels))}(gi==g-1,:);
            n(g)=numel(gi(gi==g-1));
        end
      
        % check for NaN values 
        if any(cell2mat(cellfun(@(x) any(isnan(x(:))), groupfgm,'uniformoutput',0)))
            error('hold up - NaN values found for fiber group measures...');
        end
        
        mean_fg = cellfun(@mean, groupfgm,'uniformoutput',0);
        se_fg = cellfun(@(x) std(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
%         mean_fg = cellfun(@nanmean, groupfgm,'uniformoutput',0);
%         se_fg = cellfun(@(x) nanstd(x)./sqrt(size(x,1)), groupfgm,'uniformoutput',0);
        
        
        %%%%%%%%%%% test for group differences averaging over mid 50% of the pathway
        mid50_groupfg = cellfun(@(x) nanmean(x(:,round(nNodes./4)+1:round(nNodes./4).*3),2), groupfgm,'uniformoutput',0);
        p=nan(1,nNodes);
        stat=getPValsGroup(mid50_groupfg); % one-way ANOVA
        p(round(nNodes./2)) = stat; 
%         pvals(j)=stat;
        
        %%%%%%%%%% plotting params
        xlab = 'fiber group nodes';
        ylab = fgMPlot;
        figtitle = [strrep(fgMatLabel,'_',' ') ' by group'];
        savePath = fullfile(outDir,[fgMatLabel '_' fgMPlot groupStr]);
        plotToScreen=1;
        lineLabels=strcat(group,repmat({' n='},1,numel(group)),cellfun(@(x) num2str(size(x,1)), groupfgm, 'uniformoutput',0));
%         cols = {[0 0 1];[1 0 0] }';
        
        
        %%%%%%%%%%% finally, plot the thing!
        [fig,leg]=plotNiceLines(1:nNodes,mean_fg,se_fg,cols,p,lineLabels,...
            xlab,ylab,figtitle,savePath,plotToScreen);
        
        % print(gcf,'-dpng','-r300',[fgMPlot '_bygroup']);
        
    end % fg measures (fgMPlots)
    
end % fiber groups (fgMatStrs)






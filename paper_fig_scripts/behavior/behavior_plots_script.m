% plot behavioral measures

clear all
close all

inDir = '/Users/kelly/cueexp/paper_figs_tables_stats/behavior/data';
outDir = '/Users/kelly/cueexp/figures/behavior';

% 
% measures = {'want','familiar','PA','NA',...
%     'cueRT','ratingRT'};
% measureStrs = {'Wanting','Familiarity','Positive Arousal','Negative Arousal','Shape reaction time (s)','Rating reaction time (s)'};

measures = {'want'};
measureStrs = {'Wanting'};

YL = {[-3 3],[1 7],[-3 3],[-3 3],[0 1],[0 1.8]}; % y limits

conds = {'Food','Drugs','Neutral'};

% groups = {'controls','patients'};
% groupStr = '';

% do this to loop over plotting by patients vs controls and then by
% controls, relapsers, and nonrelapsers
plotGroups{1} = {'Controls','Patients'};
plotGroupStr{1} = '';

plotGroups{2} = {'Controls','Relapsers_3months','Nonrelapsers_3months'};
plotGroupStr{2} = '_REL';

colorSet = 'color'; % either grayscale or color
% cols=[150 150 150; 40 40 40]./255;


%% do it

for pg=1:numel(plotGroups)
%     for pg=2
    groups = plotGroups{pg};
    groupStr = plotGroupStr{pg};
    
    
    cols=getCueExpColors(groups,[],colorSet);
    
    
    for i=1:numel(measures)
% for i=5
        
        measure = measures{i};
        measureStr = measureStrs{i};
        yl = YL{i};
        
        try 
            T=readtable(fullfile(inDir,[measure '_ratings.csv']));
        catch ME
            if (strcmp(ME.identifier,'MATLAB:readtable:OpenFailed'))
                T=readtable(fullfile(inDir,[measure '.csv']));
            end
        end
        
%         T=readtable(fullfile(inDir,[measure fname_suffix{i}]));
        
        % reorganize data into so that each group's data is in 1 cell
        d={};
        for g=1:numel(groups)
            for c=1:numel(conds)
                thisd = eval(['T. ' lower(conds{c}) '_' measure]);
                if strcmp(lower(groups{g}),'relapsers_3months')
                    d{g}(:,c) = thisd(T.relapse_3month_status==1);
                elseif strcmp(lower(groups{g}),'nonrelapsers_3months')
                    d{g}(:,c) = thisd(T.relapse_3month_status==0);
                else
                    d{g}(:,c) = thisd(strcmp(T.group,lower(groups{g})));
                end
            end
        end
        
        
        %%
        
        % plot with sig for slides 
        savePath = fullfile(outDir,[measure groupStr '_sig']);
        plotSig = [1 0];
        plotLeg = 0;
        fontSize = 22;
        fig = plotBehFigBars(d,measureStr,conds,strrep(groups,'_',' '),cols,...
            plotSig,'',plotLeg,savePath,1,yl,fontSize);
%           plotSig,titleStr,plotLeg,savePath,plotToScreen,YL,fontSize,saveFormat,figWidth)
        
            
        % plot with sig, stats, and legend stats
        savePath = fullfile(outDir,[measure groupStr '_stats_leg']);
        plotSig = [1 1];
        plotLeg = 1;
        fontSize=22;
        saveFormat='pdf';
        [fig,leg] = plotBehFigBars(d,measureStr,conds,strrep(groups,'_',' '),cols,...
            plotSig,'',plotLeg,savePath,1,yl,fontSize,saveFormat);
        
        
        % save out sized for publication
        outDir2=fullfile(outDir,'paper_size');
        if ~exist(outDir2,'dir')
            mkdir(outDir2)
        end
        savePath = fullfile(outDir2,[measure groupStr '_sig']);
        plotSig = [1 0];
        plotLeg = 0;
        fontSize=12;
%         saveFormat = '-depsc';
% figWidth = 3.5;
saveFormat='pdf';
        figWidth = 5;
        fig = plotBehFigBars(d,measureStr,conds,strrep(groups,'_',' '),cols,...
            plotSig,'',plotLeg,savePath,1,yl,fontSize,saveFormat,figWidth);
        
        
    end % measures
    
end % plotGroups
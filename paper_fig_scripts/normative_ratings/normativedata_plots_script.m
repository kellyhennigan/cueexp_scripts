% plot behavioral measures

clear all
close all

inDir = '/Users/kelly/cueexp/paper_figs_tables_stats/normative_ratings/data';
outDir = '/Users/kelly/cueexp/paper_figs_tables_stats/normative_ratings/figs';


measures = {'want','familiar','PA','NA'};
measureStrs = {'Wanting','Familiarity','Positive Arousal','Negative Arousal'};

YL = {[1 7],[1 7],[-3 3],[-3 3],[0 1],[0 1.8]}; % y limits

conds = {'Food','Drugs','Neutral'};

% groups = {'controls','patients'};
% groupStr = '';

% do this to loop over plotting by patients vs controls and then by
% controls, relapsers, and nonrelapsers
groups = {'Raters'};
groupStr = '';


colorSet = 'color'; % either grayscale or color
% cols=[150 150 150; 40 40 40]./255;


%% do it

%     for pg=2
    
    
    cols=[ 0.0078    0.4588    0.7059]; % controls color
    
    
    for i=1:numel(measures)

        
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
       
        for c=1:numel(conds)
                thisd = eval(['T. ' lower(conds{c}) '_' measure]);
                d{1}(:,c) = thisd(strcmp(T.group,lower(groups{1})));
        end
        
        
        %%
        
        % plot with sig for slides 
        savePath = fullfile(outDir,[measure groupStr '_sig']);
        plotSig = [1 0];
        plotLeg = 0;
        fontSize = 18;
        fig = plotBehFigBars(d,measureStr,conds,strrep(groups,'_',' '),cols,...
            plotSig,'',plotLeg,savePath,1,yl,fontSize);
%           plotSig,titleStr,plotLeg,savePath,plotToScreen,YL,fontSize,saveFormat,figWidth)
        
            
        % plot with sig, stats, and legend stats
        savePath = fullfile(outDir,[measure groupStr '_stats_leg']);
        plotSig = [1 1];
        plotLeg = 1;
        fontSize=18;
        fig = plotBehFigBars(d,measureStr,conds,strrep(groups,'_',' '),cols,...
            plotSig,'',plotLeg,savePath,1,yl,fontSize);
        
        
        % save out sized for publication
        outDir2=fullfile(outDir,'paper_size');
        if ~exist(outDir2,'dir')
            mkdir(outDir2)
        end
        savePath = fullfile(outDir2,[measure groupStr '_sig']);
        plotSig = [1 0];
        plotLeg = 0;
        fontSize=12;
        saveFormat = '-depsc';
        figWidth = 3.5;
        fig = plotBehFigBars(d,measureStr,conds,strrep(groups,'_',' '),cols,...
            plotSig,'',plotLeg,savePath,1,yl,fontSize,saveFormat,figWidth);
        
        
    end % measures

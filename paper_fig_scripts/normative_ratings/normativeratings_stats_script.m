% plot behavioral measures

clear all
close all

inDir = '/Users/kelly/cueexp/paper_figs_tables_stats/normative_ratings/data';
outDir = '/Users/kelly/cueexp/paper_figs_tables_stats/normative_ratings/figs';

% measures = {'ratingRT'};
measures={'familiar'};
% measures = {'want','familiar','PA','NA'};


conds = {'food','drugs','neutral'};

groups = {'raters'}
groupStr = '';




%% do it


for i=1:numel(measures)
    
    measure = measures{i};
    
    try
        T=readtable(fullfile(inDir,[measure '_ratings.csv']));
    catch ME
        if (strcmp(ME.identifier,'MATLAB:readtable:OpenFailed'))
            T=readtable(fullfile(inDir,[measure '.csv']));
        end
    end
    
    
    % reorganize data into so that each group's data is in 1 cell
    d={};
    for g=1:numel(groups)
        for c=1:numel(conds)
            thisd = eval(['T. ' conds{c} '_' measure]);
            if strcmp(groups{g},'relapsers_3months')
                d{g}(:,c) = thisd(T.relapse_3month_status==1);
            elseif strcmp(groups{g},'nonrelapsers_3months')
                d{g}(:,c) = thisd(T.relapse_3month_status==0);
            else
                d{g}(:,c) = thisd(strcmp(T.group,groups{g}));
            end
        end
    end
    
    
    %% omit NaNs
    
    % remove subjects with any NaN values
    [ri,cj]=cellfun(@(x) find(isnan(x)), d, 'uniformoutput',0);
    
    fprintf(['\n excluding ' ...
        num2str(numel(cell2mat(cellfun(@(x) unique(x), ri,'uniformoutput',0)'))) ...
        ' subjects from analysis due to nan values...\n']);
    
    if ~isempty(ri)
        for ni=1:numel(d)
            d{ni}(ri{ni},:) = [];
        end
    end
    
    
    
    %% get stats
    [p,tab]=anova_rm(d,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
    
    % get F stats
    Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
%     Fg=tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'F')}; % group
%     Fi=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'F')}; % cond x group interaction
    
    % corresponding eta-squared (effect sizes) 
    etasq_c=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
%     etasq_g=tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
%     etasq_i=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
%    
    % corresponding degrees of freedom
    df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
%     df_g = tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'df')}; % group
%     df_i=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'df')}; % cond x group interaction
%     
    df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
    
    anova_res = sprintf('%s:\nF(%d,%d) = %.1f; p = %.3f; eta_sq=%.3f\n\n',...
        'condition',df_c,df_e,Fc,p(1),etasq_c);
    
    fprintf(['\n\nANOVA RESULTS FOR MEASURE ' measures{i} ':\n'])
    fprintf(anova_res)
    
    %% get effect size measures:
    
        [h,p,~,stats]=ttest(d{1}(:,strcmp(conds,'food')),d{1}(:,strcmp(conds,'neutral')))
        [h,p,~,stats]=ttest(d{1}(:,strcmp(conds,'neutral')),d{1}(:,strcmp(conds,'drugs')))
        [h,p,~,stats]=ttest(d{1}(:,strcmp(conds,'drugs')),d{1}(:,strcmp(conds,'food')))
   
         stats2=mes(d{1}(:,strcmp(conds,'food'))-d{1}(:,strcmp(conds,'neutral')),0,'g1')
    stats2=mes(d{1}(:,strcmp(conds,'neutral'))-d{1}(:,strcmp(conds,'drugs')),0,'g1')

    end



% script to assess group differences in correlation between positive
% arousal and brain activity 

clear all
close all

[subjects,gi]=getCueSubjects('cue');

% subjects with no variance in drug PA ratings
% omit_subs = {'ja160416'};
% omit_subs = {'at160601','as170730','rc170730',...
%     'er171009','vm151031','jw160316','jn160403','rb160407','rv160413','yl160507',...
%     'tj160529','kn160918','cs171002'};

omit_subs = {'at160601','as170730','rc170730',...
    'er171009','vm151031','jw160316','jn160403','rb160407','rv160413','yl160507',...
    'tj160529','kn160918','cs171002','ja160416'};

% 
omit_idx=ismember(subjects,omit_subs);
subjects(omit_idx)=[];
gi(omit_idx)=[];

conds = {'food','drugs','neutral'};
% conds = {'all'};

roi = 'nacc_desai';

groups = {'Controls','Patients'};


%% 

cd(['/Users/kelly/cueexp/data/results_cue_afni_pa/roi_betas/' roi])

for j=1:numel(conds)
    T=readtable(['pa_' conds{j} '.csv']);

    % omit subs if necessary
    T(ismember(T.Var1,omit_subs),:)=[];
    
if ~isequal(T.Var1,subjects)
    error('hold up! subject lists arent matched up');
end

pa=T.Var2;

d{1}(:,j)=pa(gi==0);
d{2}(:,j)=pa(gi==1);

end


  %% get stats
    [p,tab]=anova_rm(d);  % [p(cond) p(group) p(subjs) p(group*cond)]
    
    % get F stats
    Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
    Fg=tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'F')}; % group
    Fi=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'F')}; % cond x group interaction
    
    % corresponding eta-squared (effect sizes) 
    etasq_c=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
    etasq_g=tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
    etasq_i=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
   
    % corresponding degrees of freedom
    df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
    df_g = tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'df')}; % group
    df_i=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'df')}; % cond x group interaction
    
    df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
    
    anova_res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f; eta_sq=%.3f\n\n',1,3),...
        'condition',df_c,df_e,Fc,p(1),etasq_c,...
        'group',df_g,df_e,Fg,p(2),etasq_g,...
        'group x cond interaction',df_i,df_e,Fi,p(4),etasq_i);
    
    fprintf(['\n\nANOVA RESULTS:\n'])
    fprintf(anova_res)
    

    %% plot 
    
        colorSet = 'color'; % either grayscale or color

    cols=getCueExpColors(groups,[],colorSet);

outDir = fullfile('/Users/kelly/cueexp/figures/insight_analysis',roi);
if ~exist(outDir,'dir')
    mkdir(outDir)
end
savePath = fullfile(outDir,[strcat(conds{:})]);
plotSig = [1 1];
plotLeg = 1;
titleStr='';
plotToScreen = 1;
dName = 'PA x brain correlation';
conds{1}='Food'
conds{2}='Drugs'
conds{3}='Neutral'
[fig,leg] = plotNiceBars(d,dName,conds,strrep(groups,'_',' '),cols,plotSig,titleStr,plotLeg,savePath,plotToScreen);
        

%%%%%%%%%%%%%%%%%%%%%%%%%%
%


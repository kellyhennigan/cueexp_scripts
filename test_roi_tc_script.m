% quick and dirty script to plot ROI betas

clear all
close all

p = getCuePaths();
dataDir = p.data;
figDir = p.figures;

task = 'cue';


roiNames = {'mpfc'};
% roiNames = {'ins_desai'}

% stims = {'pa_alcoholdrugs'};
% stimStr = 'pa_alcoholdrugs'

stims = {'drugs','food','neutral'};
stimStr = 'type';
% stims = {'drugs'}
% stimStr = 'drugs';


groups = {'controls','patients'};

cols = getCueExpColors(groups);

saveOut = 0;

TRs = [4:7];

omit_subs = {'ja160416'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

j=1

for j=1:numel(roiNames)
    roi=roiNames{j};
    
    betaDir = fullfile(dataDir,['timecourses_' task '_afni'],roi);
    
    % load data
    for g = 1:numel(groups)
        
        for k=1:numel(stims)
            
            subs=getCueSubjects('cue',groups{g}); 
            omit_idx = ismember(subs,omit_subs);
            subs(omit_idx)=[];
            tc = loadRoiTimeCourses(fullfile(betaDir,[stims{k} '.csv']),subs);
            B{g}(:,k) = mean(tc(:,TRs),2);
            
        end % stims
        
    end % groups
    
    
    % plot it
    if saveOut
        %             savePath = fullfile(figDir,'roi_betas',[roi '_betas_bars_bygroup.png']);
        outDir = fullfile(figDir,'roi_betas',roi);
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        savePath = fullfile(outDir,[stimStr '_TRs' strrep(num2str(TRs),' ','') '.png']);
    else
        savePath = [];
    end
    
    % [fig,leg] = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,titleStr,plotLeg,savePath,plotToScreen)
    titleStr = [strrep(roi,'_',' ') ' TRs' strrep(num2str(TRs),' ','') ' by group and stim']; 
    [fig,leg] = plotNiceBars(B,[strrep(roi,'_',' ') ' betas'],stims,groups,cols,[1 1],titleStr,1,savePath,1);
    
    
     %% get stats
    [p,tab]=anova_rm(B,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
    
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
    
    fprintf(['\n\nANOVA RESULTS FOR MEASURE ' roi ':\n'])
    fprintf(anova_res)
 
    
    
end % roiNames

% % also plot as points
% b0= B{1}(:,1)-B{1}(:,2); % drugs-neutral
% b1= B{2}(:,1)-B{2}(:,2); % drugs-neutral
% b0= B{1}(:,1); % drugs
% b1= B{2}(:,1); % drugs
%
%     % for two-sample ttests: 
    [h,p,~,stats]=ttest2(B{1}(:,strcmp(stims,'drugs')),B{2}(:,strcmp(stims,'drugs')))
    stats2=mes(B{2}(:,strcmp(stims,'drugs')),B{1}(:,strcmp(stims,'drugs')),'hedgesg')


    [h,p,~,stats]=ttest2(B{1}(:,strcmp(stims,'food')),B{2}(:,strcmp(stims,'food')))
    stats2=mes(B{2}(:,strcmp(stims,'food')),B{1}(:,strcmp(stims,'food')),'hedgesg')

    
       [h,p,~,stats]=ttest2(B{2}(:,strcmp(stims,'neutral')),B{1}(:,strcmp(stims,'neutral')))
    stats2=mes(B{2}(:,strcmp(stims,'neutral')),B{1}(:,strcmp(stims,'neutral')),'hedgesg')

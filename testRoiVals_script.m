% script to get stats for VOI values (timecourses or betas, etc)


clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
% task = whichCueTask();
task = 'cue';

p = getCuePaths();

dataDir = p.data;
figDir = p.figures;

% stims = {'drugs','food','neutral'};
stims = {'drugs-food'};
% stims = {'pa'};

% groups = {'controls','relapsers_6months','nonrelapsers_6months'};
% groupStr = 'byrelapse';

groups = {'patients','controls'};
groupStr = 'patients vs controls';

% groups = {'patients'};
% groupStr = groups{1};

% roiNames = whichRois(inDir);
roiNames = {'mpfc','nacc_desai','VTA'};
% roiNames = {'nacc_desai'};
% roiNames = {'VTA'};

dType = 'betas'; % either betas or timecourses


%%
switch lower(dType)
    
    case 'betas'
        
        inDir = fullfile(dataDir,['results_' task '_afni'],'roi_betas'); % roi betas
        %         inDir = fullfile(dataDir,['results_' task '_afni_pa'],'roi_betas'); % roi betas
        dName = 'betas'; % name of data type
        aveTRs = [];
        
        
    case 'timecourses'
        
        inDir =  fullfile(dataDir, ['timecourses_' task '_afni' ]); % timecourses
        aveTRs = [4 7]; % 1x2 vector denoting the first and last TR to average over
        dName = sprintf('aveTRs%d-%d',aveTRs(1),aveTRs(2)); % name of data type
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

for r=1:numel(roiNames)
    % r=1;
    roi = roiNames{r};
    
    
    
    %%%%%%%%% load data
    
    d = {};
    
    for g=1:numel(groups)
        
        for c=1:numel(stims)
            
            % if there's a minus sign, assume desired plot is stim1-stim2
            if strfind(stims{c},'-')
                
                stimFile1 = fullfile(inDir,roi,[stims{c}(1:strfind(stims{c},'-')-1) '.csv']);
                stimFile2 = fullfile(inDir,roi,[stims{c}(strfind(stims{c},'-')+1:end) '.csv']);
                
                % load roi data (stim1-stim2)
                this_d=[loadRoiTimeCourses(stimFile1,getCueSubjects(task,groups{g}))-...
                    loadRoiTimeCourses(stimFile2,getCueSubjects(task,groups{g}))];
                
            else  % just load stim data
                
                stimFile = fullfile(inDir,roi,[stims{c} '.csv']);
                
                % load roi data
                this_d=loadRoiTimeCourses(stimFile,getCueSubjects(task,groups{g}));
                
            end
            
            % average over subset of TRs, if data is timecourse data
            if ~isempty(aveTRs)
                this_d = mean(this_d(:,aveTRs(1):aveTRs(2)),2);
            end
            
            d{g}(:,c) = this_d;
            
        end % stims
        
    end % groups
    
    
    %% get stats
    
    %   data from different groups should be in cells
    % data from same subjects but different conditions should be in columns
    
    
    % ONE SAMPLE TTEST: 
    if numel(d)==1 && size(d{1},2)==1
        [h,p,~,stats]=ttest(d{1});
        Z=t2z(stats.tstat,stats.df);
        res = sprintf('\none-sample ttest:\n t(%d)=%.3f; p=%.3f; Z=%.3f\n\n',...
            stats.df,stats.tstat,p,Z);
        
        % TWO SAMPLE TTEST:
    elseif numel(d)==2 && size(d{1},2)==1
        [h,p,~,stats]=ttest2(d{1},d{2});
        Z=t2z(stats.tstat,stats.df);
        res = sprintf('\two-sample ttest:\n t(%d)=%.3f; p=%.3f; Z=%.3f\n\n',...
            stats.df,stats.tstat,p,Z);
       
    else
        
        [p,tab]=anova_rm(d,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
        
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
        
        res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f; eta_sq=%.3f\n\n',1,3),...
            'condition',df_c,df_e,Fc,p(1),etasq_c,...
            'group',df_g,df_e,Fg,p(2),etasq_g,...
            'group x cond interaction',df_i,df_e,Fi,p(4),etasq_i);
        
        
    end
    
    res = sprintf('\nresults for ROI: %s, STIM: %s, GROUP, %s:\n%s',...
        roi,stims{1},groupStr,res);
    
    disp(res);
    
end % rois




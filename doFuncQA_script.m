
%%%%%%%% do QA for cue experiment data

% clear all
% close all

[p,task,subjects,gi]=whichCueSubjects();
dataDir = p.data;

useAfniVersion=input('use afni xformed version? (1=yes 0=no; no means use ANTS version) ');
if useAfniVersion
    afniStr = '_afni';
else
    afniStr = '';
end

funcDir = [dataDir '/%s/func_proc/']; % func data dir, %s is subject id
mp_file = '%s_vr.1D'; % motion param file where %s is task
roits_file = ['%s_nacc' afniStr '.1D']; % roi time series file to plot where %s is task

figDir = fullfile(p.figures,'QA');

savePlots = input('plot & save out QA plots? (1=yes 0=no) ');

plotMotionLim = .5; % euclidean distance limit to plot

%% do it

if ~exist(figDir,'dir')
    mkdir(figDir);
end


for s = 1:numel(subjects)
    
    subject = subjects{s};
    fprintf(['\nworking on subject ' subject '...\n\n']);
    
    mp = dlmread([sprintf(funcDir,subject) sprintf(mp_file,task)]);
    mp = mp(:,2:7);
    
    % plot motion params
    if savePlots
        fig = plotMotionParams(mp);
        
        a=get(fig,'Children');
        title(a(6),subject)
        
        outName = [subject '_mp_' task];
        
        print(gcf,'-dpng','-r600',fullfile(figDir,outName));
    end
    
    
    %% plot roi ts w/enorm of movement
    
    en = [0;sqrt(sum(diff(mp).^2,2))]; % euclidean norm (head motion distance roughly in mm units)
    
    nBadTRs = numel(find(en>plotMotionLim));
    fprintf(['\nsubject ' subject ' has ' num2str(nBadTRs) ' bad motion vols,\n' ...
        'which is ' num2str(100.*nBadTRs./numel(en)) ' percent of task ' task ' trials\n\n'])
    
    task_nBadTRs(s) = nBadTRs;
    
    [max_en,max_TR]=max(en);
    
    if savePlots
        
        c = solarizedColors;
        
        figH = figure;
        set(gcf,'Visible','off')
        set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
        
        subplot(2,1,1)
        hold on
        plot(en,'color',c(6,:),'linewidth',1.5)
        set(gca,'box','off');
        plot(ones(numel(en),1).*plotMotionLim,'color',c(1,:))
        ylabel('head motion (in ~mm units)','FontSize',12)
        
        title(['max displacement: ~' num2str(max_en) ' mm, at TR=' num2str(max_TR)],...
            'FontSize',14)
        
        ts = dlmread([sprintf(funcDir,subject) sprintf(roits_file,task)]);
        
        subplot(2,1,2)
        plot(ts,'color',c(5,:),'linewidth',1.5)
        set(gca,'box','off');
        ylabel('BOLD signal','FontSize',12)
        xlabel('TRs','FontSize',12)
        title('nacc roi ts','FontSize',14)
        
        outName = [subject '_mp2_' task];
        
        print(gcf,'-dpng','-r600',fullfile(figDir,outName));
        close all
        
    end
    
    
    
end % subjects



%% calculate tSNR

%% show where censored TRs are



%%
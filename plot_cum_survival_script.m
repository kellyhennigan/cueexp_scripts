
% plot cumulative survival 

% refs:
% https://www.mathworks.com/help/stats/cox-proportional-hazard-regression.html
% https://www.mathworks.com/help/stats/readmission-times.html

clear all
close all

figDir = '/Users/kelly/cueexp/paper_figs/relapse_data'

cd(figDir)

% load data
T = readtable('relapse_data_171116.csv');

% plot colors 
col(1,:) = [30 30 30]./255; % blackish gray
col(2,:) = [150 150 150]./255; % lighter gray


%% omit subjects that have no followup data

% subjects with no followup data
nanidx=find(isnan(T.relapse));


% remove data for subjects with nan relapse values
T(nanidx,:)=[];


%% get just observed time and censor data (0=relapse, 1=no relapse)

[obstime,si]=sort(T.obstime);
censored = T.censored(si);
subjects = T.subjid(si);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot cumulative survival 


fig=figure;
set(gca,'fontName','Helvetica','fontSize',18)
set(gca,'box','off');
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
hold on

subplot(1,1,1);
[empF,x,empFlo,empFup] = ecdf(obstime,'censoring',censored);
stairs(x,1-empF,'Linewidth',2,'color',col(1,:));
stairs(x,1-empFlo,':','Linewidth',2,'color',col(1,:)); 
stairs(x,1-empFup,':','Linewidth',2,'color',col(1,:));
hold off
xlabel('Time (days)'); ylabel('Cumulative survival'); title('Empirical CDF')

xl=xlim;
xlim([-10 xl(2)])
legend('CDF','Location','EastOutside')
legend('boxoff')

savePath = fullfile(figDir,'empiricalCDF_survival.png');
print(gcf,'-dpng','-r300',savePath);

xlim([-10 180])

savePath = fullfile(figDir,'empiricalCDF_survival_180days.png');
print(gcf,'-dpng','-r300',savePath);



%% median split on Nacc activity - survival curve 

% sort and format 
[obstime,si]=sort(T.obstime);
censored = T.censored(si);
subjects = T.subjid(si);
nacc = T.nacc_drugs_beta(si);

hi = find(nacc>=median(nacc));
lo = find(nacc<median(nacc));


set(gca,'fontName','Helvetica','fontSize',18)
set(gca,'box','off');
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
hold on

% lo
[empF1,x1,empFlo1,empFup1] = ecdf(obstime(lo),'censoring',censored(lo));
stairs(x1,1-empF1,'Linewidth',2,'color',col(2,:));


% hi
[empF2,x2,empFlo2,empFup2] = ecdf(obstime(hi),'censoring',censored(hi));
stairs(x2,1-empF2,'Linewidth',2,'color',col(1,:));

legend('low reactivity','high reactivity','Location','EastOutside')
legend('boxoff')

% confidence intervals
stairs(x1,1-empFlo1,':','Linewidth',2,'color',col(2,:)); 
stairs(x1,1-empFup1,':','Linewidth',2,'color',col(2,:));

stairs(x2,1-empFlo2,':','Linewidth',2,'color',col(1,:)); 
stairs(x2,1-empFup2,':','Linewidth',2,'color',col(1,:));

xlabel('Time (days)'); ylabel('cumulative survival'); 
title('Empirical CDF')

xl=xlim;
xlim([-10 xl(2)])
ylim([0 1.05])
hold off


savePath = fullfile(figDir,'empiricalCDF_survival_lohi.png');
print(gcf,'-dpng','-r300',savePath);

% plot time to relapse as a function of NAcc drug betas


clear all
close all


p = getCuePaths(); 
dataDir = p.data; % cue exp paths
figDir = p.figures; 


% get relapse data
% [obstime,censored,notes]=getCueRelapseSurvival(subjects);

% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171031.csv');
dataPath = fullfile(dataDir,'relapse_data','relapse_data_180403.csv');

% load data
T = readtable(dataPath); 


% cols=getCueExpColors({'relapsers','nonrelapsers'});
% cols = [30 30 30]./255; % relapsers
cols = [1 0 0]; % relapsers

cols(2,:) = [0 0 1]; % nonrelapsers

%% plot it 

 y=T.nacc_drugs_beta;
x=T.obstime; 

fig=setupFig; 
set(gca,'fontName','Helvetica','fontSize',18)


plot(x(T.relapse==1),y(T.relapse==1),'.','markersize',30,'color',cols(1,:))
% plot(x(T.relIn6Mos==1),y(T.relIn6Mos==1),'.','markersize',30,'color',cols(1,:))

xl=xlim;
xlim([-5 xl(2)])

yl=ylim;
ylim([yl(1) .17])
% title(['NAcc response to drug cues in relapsers'],'FontName','Helvetica','FontSize',18)
xlabel('Time (days)','FontName','Helvetica','FontSize',18)
ylabel('NAcc drug response','FontName','Helvetica','FontSize',18)
legend({'relapsers'},'Location','EastOutside')
legend('boxoff')
savePath = fullfile(figDir,'relapse_prediction','days2relapse_byNAccdrugresponse')
print(gcf,'-dpng','-r300',savePath);


%% also plot nonrelapsers
 
hold on
plot(x(T.relapse==0),y(T.relapse==0),'.','markersize',30,'color',cols(2,:))
plot(x(T.relIn6Mos==0),y(T.relIn6Mos==0),'.','markersize',30,'color',cols(2,:))

% title(['NAcc response to drug cues in patients'],'FontName','Helvetica','FontSize',18)
xlabel('observed time (days) after treatment','FontName','Helvetica','FontSize',18)
ylabel('NAcc drug response','FontName','Helvetica','FontSize',18)
legend({'relapsers','nonrelapsers'},'Location','EastOutside')
legend('boxoff')
savePath = fullfile(figDir,'relapse_prediction','observedtime_byNAccdrugresponse')
print(gcf,'-dpng','-r300',savePath);




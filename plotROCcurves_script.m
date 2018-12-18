% plot ROC curves

clear all
close all


p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath =fullfile(dataDir,'relapse_data','relapse_data_181012.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_180723.csv');

% load data
T = readtable(dataPath); 

% T.relIn6Mos(4)=1; % set ja151218 to be relapsed in 6 months 


% define outcome variable
Yname = 'relIn3Mos';

% omit subjects that have no outcome data 
eval(['T(isnan(T.' Yname '),:)=[];']);
resp = eval(['T.' Yname]);

% model colors
cols=[  0.7961    0.2941    0.0863
    0.5216    0.6000         0
    0.1490    0.5451    0.8235
    0.8275    0.2118    0.5098];

%     cols=[ 0.9922    0.1725    0.0784
%     0.9922    0.1725    0.0784];
% modnames={'demographic/clinical','self-reported craving','neural (nacc)','combined'};
% modnames={'nacc drugs'};
modnames={'Self-reported craving','NAcc drug response'};

% define models to plot: 

% mod{1} = T.nacc_drugs_beta;
% 
% mod{1} = T.age;
% mod{2} = [T.pref_drug T.craving  T.bam_upset];
mod{1} = [T.craving];
% mod{3} = [T.nacc_drugs_beta T.mpfc_drugs_beta T.vta_drugs_beta];
mod{2} = [T.nacc_drugs_beta];

% mod{4} = [T.age T.nacc_drugs_beta];

outDir='/Users/kelly/cueexp/paper_figs_tables_stats/ROCcurves';
figName='modelROC';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 


% standardize them
mod=cellfun(@(x) [x-nanmean(x)./nanstd(x)], mod,'uniformoutput',0);


%% set up figure w/font size 20
fig=setupFig([],20);

%% 

for m=1:numel(mod)
    
pred = mod{m};


%%
% Fit a logistic regression model.
mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');    



%%
% Compute the ROC curve. Use the probability estimates from the logistic
% regression model as scores.
scores = mdl.Fitted.Probability;
[X,Y,thresh,AUC(m)] = perfcurve(resp,scores,1); 
%%
% |perfcurve| stores the threshold values in the array |T|.
%%
% Display the area under the curve.
AUC(m)
%%
% The area under the curve is 0.7698. The maximum AUC is 1, which corresponds to a perfect
% classifier. Larger AUC values indicate better classifier performance.
%%
% Plot the ROC curve.


plot(X,Y,'LineWidth',2,'color',cols(m,:))
% plot(X,Y,'--','LineWidth',2,'color',cols(m,:))
end

plot([0 1],[0 1],'linewidth',2,'color',[.5 .5 .5])
xlabel('1 - specificity') % false positive rate 
ylabel('sensitivity') % true positive rate 
% title('ROC for Classification by Logistic Regression')

%% save versions with and without legends

%     print(gcf,'-dpng','-r300',fullfile(outDir,figName));
    saveas(gcf,fullfile(outDir,figName),'pdf');
% 
leg=legend(modnames{:},'location','NorthEastOutside');
    legend(gca,'boxoff')
%     legend(leg,'FontName',fontName,'FontSize',fontSize)
 
% print(gcf,'-dpng','-r300',fullfile(outDir,[figName '_wleg']));
saveas(gcf,fullfile(outDir,[figName '_wleg']),'pdf');
fprintf('done.\n\n')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% also plot histograms showing model predictability


cols=[0.1490    0.5451    0.8235;
    0.8627    0.1961    0.1843];

m=1;
for m=1:numel(mod)
    
pred = mod{m};

% Fit a logistic regression model.
mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');    

% get model's predictions 
scores = mdl.Fitted.Probability;

fig=setupFig([],20);
titleStr=[modnames{m} ' model predictions'];
legStr={'true not relapse','true relapse'};
plotNiceNHist({scores(T.relIn3Mos==0),scores(T.relIn3Mos==1)},cols,titleStr,legStr)

figName = ['outcome predictions for ' modnames{m} ' model'];
% print(gcf,'-dpng','-r300',fullfile(outDir,figName));
saveas(gcf,fullfile(outDir,figName),'pdf');
fprintf('done.\n\n')

end





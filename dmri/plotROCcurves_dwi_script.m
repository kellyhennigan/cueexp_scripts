% plot ROC curves

clear all
close all


p = getCuePaths(); 
dataDir = p.data;
figDir = p.figures;


% dataPath = fullfile(dataDir,'relapse_data','relapse_data_171116.csv');
dataPath =fullfile(dataDir,'q_demo_data','data__200413.csv');
% dataPath = fullfile(dataDir,'relapse_data','relapse_data_180723.csv');

% load data
T = readtable(dataPath); 

% define outcome variable
% Y = 'relapse';
% Yname = 'relIn3Mos';
Yname = 'gi';
T.gi(T.gi>0)=1;


% define outcome variable

% omit subjects that have no outcome data 
eval(['T(isnan(T.' Yname '),:)=[];']);
resp = eval(['T.' Yname]);

% model colors
% cols=[  0.7961    0.2941    0.0863
%     0.5216    0.6000         0
%     0.1490    0.5451    0.8235
%     0.8275    0.2118    0.5098];

% cols=[ .4 .4 .4;
%     .4 .4 .4;
%     0 0 0];

cols=[ .2 .2 .2;
    .2 .2 .2;
    .2 .2 .2];
    


lspec={':','--','-'};
%     cols=[ 0.9922    0.1725    0.0784
%     0.9922    0.1725    0.0784];
% modnames={'demographic/clinical','self-reported craving','neural (nacc)','combined'};
% modnames={'nacc drugs'};

% define models to plot: 

modnames={'Behavior: BIS','Brain: FA','Combined: BIS+FA'};


mod{1} = T.BIS;
mod{2} = T.inf_NAcc_fa_controllingagemotion; 
mod{3} = [T.BIS T.inf_NAcc_fa_controllingagemotion]; 


outDir='/Users/kelly/cueexp/figures_dti/paper_figs/ROCcurves';
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
    
    %% compute d prime; based on notes found here: 
%     http://gru.stanford.edu/doku.php/tutorials/sdt
    
    modelpred = scores>.5;
    hits = numel(find(modelpred==1 & resp==1))./numel(find(resp==1));
    falseAlarms=numel(find(modelpred==1 & resp==0))./numel(find(resp==0));
    zHits = icdf('norm',hits,0,1);
    zFalseAlarms = icdf('norm',falseAlarms,0,1);
    dPrime(m) = zHits-zFalseAlarms;
    
    %%
    % |perfcurve| stores the threshold values in the array |T|.
    %%
    % Display the area under the curve. Larger AUC values indicate better classifier performance.
    AUC(m)
    legtext{m} = sprintf('%s AUC: %.2f; d'': %.2f',modnames{m},AUC(m),dPrime(m));
%         legtext{m} = sprintf('%s (%.2f)',modnames{m},AUC(m));
%     plot(X,Y,'LineWidth',2,'color',cols(m,:))
    plot(X,Y,lspec{m},'LineWidth',2,'color',cols(m,:))
end

plot([0 1],[0 1],'-','linewidth',2,'color',[.8 .8 .8])
xlabel('1 - specificity') % false positive rate 
ylabel('sensitivity') % true positive rate 

set(gca,'XTick',[.2:.2:1])
set(gca,'YTick',[.2:.2:1])

% title('ROC for Diagnosis Classification by Logistic Regression')
title('')

%% save versions with and without legends

%     print(gcf,'-dpng','-r300',fullfile(outDir,figName));
    saveas(gcf,fullfile(outDir,figName),'pdf');
% 
sz=get(gcf,'OuterPosition')
set(gcf,'OuterPosition',[sz(1) sz(2) sz(3).*1.2 sz(4)])

leg=legend(legtext,'location','NorthEastOutside');
    legend(gca,'boxoff')
%     legend(leg,'FontName',fontName,'FontSize',fontSize)
 
% print(gcf,'-dpng','-r300',fullfile(outDir,[figName '_wleg']));
saveas(gcf,fullfile(outDir,[figName '_wleg']),'pdf');
fprintf('done.\n\n')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

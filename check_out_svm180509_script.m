% find the svm with the highest accuracy

clear all
close all


p = getCuePaths();
dataDir = p.data;
figDir = p.figures;


subjects = getCueSubjects('cue','patients_3months');
rel= getCueData(subjects,'relapse_3months');

svmName = 'betasvm_180509_iterations';

csvDir = fullfile(dataDir,svmName,'i%d','csvs');

fstr = '_lag_0_trs_1_cut_0.05relapse_oversampled.csv'; %s is subject

% savePath='svmrfe_accuracy.png'
figDir=fullfile(figDir,'svm',svmName);
if ~exist(figDir,'dir')
    mkdir(figDir);
end


includeENet = 0; % 1 to include elastic net measures in plot, 0 to not include
                        
                        
%% do it

varNames2 = {'subject','Cval','n_features','percent_features','accuracy','test_prediction','f1','precision','recall','roc_auc','r2','traintime'};

acc=[];

i=1;iter=1;

for iter=1:10
    
    this_csvDir=sprintf(csvDir,iter);

    for i=1:numel(subjects)
        
 d0=readtable(fullfile(this_csvDir,[subjects{i} fstr]),'ReadVariableNames',0);
 d0.Properties.VariableNames=varNames2;
 acc(:,i,iter)=d0.accuracy;
 pred(:,i,iter)=d0.test_prediction;
            pred(pred==-1)=0; % recode -1 predictions to be 0
    end
end

 acc = mean(acc,3); % average over iterations
 pred = mean(pred,3); % average over iterations
 ave_acc=mean(acc,2); % average over subjects
 
%% organize average accuracies by model specification & percent features

mods=unique(d0.Cval); % strings identifying different model params

% remove elastic net if its there - its too variable
if ~includeENet
    mods(strcmp('elasticnetiter1000_l1ratio0.15',mods))=[];
end

for k=1:numel(mods)
    idx = find(strcmp(d0.Cval,mods{k}));
    mod_acc{k}=acc(idx,:);
    aa(:,k) = ave_acc(idx);
    if ~notDefined('pred')
        mod_pred{k}=pred(idx,:);
    end
end
pfeatures = d0.percent_features(idx);


%% plot it

cols=solarizedColors(numel(mods));

% make mod string shorter
mods=strrep(mods,'linearsvc_','svm ');
mods=strrep(mods,'elasticnetiter1000_l1ratio0.15','enet');

plot_mod_idx=2:8;  % which models to plot? 

fig=setupFig
hold on

for k=plot_mod_idx
    plot(aa(:,k),'Linewidth',1.5,'color',cols(k,:));
end
xlim([1,numel(pfeatures)])
xt=get(gca,'XTickLabels'); % ordinal x tick values
xt=cellfun(@(x) round(pfeatures(str2num(x)).*1000)./10, xt, 'uniformoutput',0);
set(gca,'XTickLabels',xt)
xlabel('percent of features')
ylabel('percent accuracy')

legend(mods(plot_mod_idx),'Location','southoutside')
legend(gca,'boxoff')

title('LOSO cross-validated test accuracy; averaged over 10 iterations per subject')

% save figure
% change save name based on whether elastic net is included or not
saveName = 'accuracy_by_percentfeatures.png';
savePath = fullfile(figDir,saveName);
print(fig,'-dpng','-r300',savePath)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot predictions as well if they were recorded

if ~notDefined('mod_pred')
    
    fig2=setupFig
    hold on
    for k=plot_mod_idx
        plot(mean(mod_pred{k},2),'Linewidth',1.5,'color',cols(k,:));
    end
    xlim([1,numel(pfeatures)])
    xt=get(gca,'XTickLabels'); % ordinal x tick values
    xt=cellfun(@(x) round(pfeatures(str2num(x)).*1000)./10, xt, 'uniformoutput',0);
    set(gca,'XTickLabels',xt)
    xlabel('percent of features')
    ylabel('percent relapse guesses')
 % legend(mods(plot_mod_idx),'Location','southoutside')
% legend(gca,'boxoff')
   
    title(sprintf(str))
    % change save name based on whether elastic net is included or not
    saveName = 'relapseguesses_by_percentfeatures.png';
    savePath = fullfile(figDir,saveName);
    print(fig2,'-dpng','-r300',savePath)
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot accuracy for a model for all subjects sorted by relapse status

% get subjects' relapse status
rel=getCueData(subjects,'relapse_3months');

nmod = 6; % which model? 

[relS,riS]=sort(rel);  % sort by relapse status

subsS=subjects(riS); 
this_acc = mod_acc{nmod}(:,riS);


fig=setupFig
hold on
imagesc(this_acc)
colormap(winter)
colorbar
set(gca,'XTick',1:numel(subjects))
set(gca,'XTickLabels',subsS)
plot([find(diff(relS))+.5 find(diff(relS))+.5],[0 size(this_acc,1)],'Linewidth',2,'color',[1 1 1])
 xtickangle(45)

 ylim([1,numel(pfeatures)])
yt=get(gca,'YTickLabels'); % ordinal x tick values
yt=cellfun(@(y) round(pfeatures(str2num(y)).*1000)./10, yt, 'uniformoutput',0);
set(gca,'YTickLabels',yt)
ylabel('percent of features')

% set(colorbar,'Ticks',[0 1])
% set(colorbar,'TickLabels',{'correct','incorrect'})
 
% change save name based on whether elastic net is included or not
title(sprintf('nonrelapsers are on the left, relapsers on the right\n1 means prediction was right; 0 means prediction was wrong'))
saveName = 'subj_accuracy_by_percentfeatures.png';

savePath = fullfile(figDir,saveName);

print(fig,'-dpng','-r300',savePath)




%% do the plot for predictions if possible

if ~notDefined('mod_pred')
    this_pred = mod_pred{nmod}(:,riS);
    
    fig2=setupFig
    hold on
    imagesc(this_pred)
    colormap(winter)
    colorbar
    set(gca,'XTick',1:numel(subjects))
    set(gca,'XTickLabels',subsS)
    plot([find(diff(relS))+.5 find(diff(relS))+.5],[0 size(this_acc,1)],'Linewidth',2,'color',[1 1 1])
    xtickangle(45)
    
    ylim([1,numel(pfeatures)])
    yt=get(gca,'YTickLabels'); % ordinal x tick values
    yt=cellfun(@(y) round(pfeatures(str2num(y)).*1000)./10, yt, 'uniformoutput',0);
    set(gca,'YTickLabels',yt)
    ylabel('percent of features')
    
    % set(colorbar,'Ticks',[0 1])
    % set(colorbar,'TickLabels',{'correct','incorrect'})
    
    % change save name based on whether elastic net is included or not
    title(sprintf('nonrelapsers are on the left, relapsers on the right\n1 means predicted relapser; 0 means predicted abstainer'))
    saveName = 'testsubj_predictions_by_percentfeatures.png';
    
    savePath = fullfile(figDir,saveName);
    
    print(fig2,'-dpng','-r300',savePath)
end

%% percent correct when test subject is a relapser vs non-relapser
% 
% abstainers_acc = mean(this_acc(:,relS==0),2);
% relapsers_acc = mean(this_acc(:,relS==1),2);
% 
% fig=setupFig
% hold on
% imagesc([abstainers_acc relapsers_acc])
% colormap(winter)
% colorbar
% set(gca,'XTick',[1 2])
% set(gca,'XTickLabels',{'abstainers','relapsers'})
% xlabel('percent accuracy')
% 
%  ylim([1,numel(pfeatures)])
% yt=get(gca,'YTickLabels'); % ordinal x tick values
% yt=cellfun(@(y) round(pfeatures(str2num(y)).*1000)./10, yt, 'uniformoutput',0);
% set(gca,'YTickLabels',yt)
% ylabel('percent of features')


%% plot accuracy for just 1 mod


fig=setupFig
hold on
mod_idx=5;

    plot(aa(:,mod_idx),'Linewidth',1.5,'color',cols(mod_idx,:));

xlim([1,numel(pfeatures)])
xt=get(gca,'XTickLabels'); % ordinal x tick values
xt=cellfun(@(x) round(pfeatures(str2num(x)).*1000)./10, xt, 'uniformoutput',0);
set(gca,'XTickLabels',xt)
xlabel('percent of features')
ylabel('percent accuracy')


title('LOSO cross-validated test accuracy; averaged over 10 iterations per subject; C=1')

% save figure
% change save name based on whether elastic net is included or not
saveName = 'accuracy_by_percentfeatures_C1.png';
savePath = fullfile(figDir,saveName);
print(fig,'-dpng','-r300',savePath)


% find the svm with the highest accuracy

clear all
close all



svmName = ['betasvm_DRUGS_REL6Mos_nooversampling'];


p = getCuePaths();
dataDir = p.data;
figDir = p.figures;

csvDir = fullfile(dataDir,svmName,'csvs');

% fstr = '_lag_0_trs_1_cut_0.05oversampled.csv'; %s is subject
fstr = '_lag_0_trs_1_cut_0.05relapse.csv'; %s is subject

% savePath='svmrfe_accuracy.png'
figDir=fullfile(figDir,'svm',svmName);
if ~exist(figDir,'dir')
    mkdir(figDir);
end


includeENet = 0; % 1 to include elastic net measures in plot, 0 to not include


% notes to include as title on accuracy plot
switch svmName
    case 'betasvm_180507_3'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with fluctuating random state (no fixed starting point)';
   
    case {'betasvm_180502','betasvm_180507','betasvm_180507_5'}
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=0';
    case 'betasvm_180507_3'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with fluctuating random state (no fixed starting point)';
    case 'betasvm_180507_4'
        str = 'n=33; *13* relapsers @3mos (plus ja151218);\n downsampled with random state=0';
    case 'betasvm_180507_6'
        str = 'n=33; 15 relapsers @6mos (through ja151218);\n downsampled with random state=0';
    case 'betasvm_180508'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=42';
    case 'betasvm_180508_2'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=1';
    case 'betasvm_180508_3'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=2';
    case 'betasvm_180508_4'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=3';
    case 'betasvm_180508_5'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=5';
    case 'betasvm_180508_6'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=6';
    case 'betasvm_180508_7'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=7';
    case 'betasvm_180508_8'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=8';
    case 'betasvm_180508_9'
        str = 'n=33; 12 relapsers @3mos;\n downsampled with random state=9';
    case 'betasvm_180508_10'
        str = 'n=33; 12 relapsers @3mos;\n NOT downsampled';
    case 'betasvm_180508_11'
        str = 'n=36; 15 relapsers (through ja151218);\n random row shuffle; downsampled with random state=0';
    case 'betasvm_180508_12'
        str = 'n=36; 15 relapsers (through ja151218);\n downsampled with random state=0';
    case 'betasvm_180508_13'
        str = 'n=33; 15 relapsers (through ja151218);\n downsampled with random state=0';
    case 'betasvm_180508_14'
        str = 'n=33; 15 relapsers (through ja151218);\n downsampled with random state=1';
    case 'betasvm_180508_15'
        str = 'n=33; 12 relapsers @3mos;\n oversampled with no fixed random state';
    case 'betasvm_180508_16'
        str = 'n=33; 12 relapsers @3mos;\n oversampled with random state=0';
    case 'betasvm_180508_17'
        str = 'n=33; 12 relapsers @3mos;\n oversampled with random state=1';
    case 'betasvm_180508_18'
        str = 'n=33; 12 relapsers @3mos;\n oversampled with random state=2';
    case 'betasvm_t1w'
        str = 'n=33; 12 relapsers @3mos;\n oversampled; used GM mask; t1w data';
    case 'betasvm_180520'
        str = 'n=33; 12 relapsers @3mos;\n oversampled; used GM mask; FA data';
    case 'betasvm_FA_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on FA maps; oversampled; used WM mask';
    case 'betasvm_MD_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on MD maps; oversampled; used WM mask';;
 
    case 'betasvm_DRUGS_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on drug betas; oversampled; used GM mask';
    case 'betasvm_DRUGS_REL'
        str = 'n=33; 12 relapsers @3mos;\n oversampled; used GM mask; drug betas';
    case 'betasvm_DRUGS_REL_smote'
        str = 'n=33; 12 relapsers @3mos;\n oversampled using SMOTE; used GM mask';
    case 'betasvm_DRUGS_REL_adasyn'
        str = 'n=33; 12 relapsers @3mos;\n oversampled using ADASYN; used GM mask';
    case 'betasvm_DRUGS&FOOD_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on drug and food betas; oversampled; used GM mask';
    case 'betasvm_FOOD_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on food betas; oversampled; used GM mask';
    case 'betasvm_FOOD_REL'
        str = 'n=33; 12 relapsers @3mos;\n oversampled; GM mask; food betas';
    case 'betasvm_DVF_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on drug-food betas; oversampled; used GM mask';
    case 'betasvm_DVF_REL'
        str =  'n=33; 12 relapsers @3mos;\n oversampled; GM mask; drug-food betas';
    case 'betasvm_DVN_GROUP'
        str =  'n=36 patients and n=40 controls;\n classifying based on drug-neutral betas';
    case 'betasvm_DVN_REL'
        str =  'n=33; 12 relapsers @3mos;\n oversampled; GM mask; drug-neutral betas';
    case 'betasvm_DRUGS_REL6Mos'
        str =  'n=30 patients; 15 relapsers by ~7mos;\n oversampled; GM mask; drug betas';
    case 'betasvm_DRUGS_REL6Mos_nooversampling'
        str =  'n=30 patients; 15 relapsers by ~7mos;\n NO oversampling; GM mask; drug betas';
      case 'betasvm_NEUTRAL_GROUP'
        str = 'n=36 patients and n=40 controls;\n classifying based on neutral betas; oversampled; used GM mask';
    case 'betasvm_NEUTRAL_REL'
        str = 'n=33; 12 relapsers @3mos;\n oversampled; GM mask; neutral betas';
 
    otherwise
        str='';
end


%% do it

varNames = {'subject','Cval','n_features','percent_features','accuracy','f1','precision','recall','roc_auc','r2','traintime'};
varNames2 = {'subject','Cval','n_features','percent_features','accuracy','test_prediction','f1','precision','recall','roc_auc','r2','traintime'};
varNames3 = {'subject','Cval','n_features','percent_features','accuracy','test_prediction','train_accuracy','f1','precision','recall','roc_auc','r2','traintime'};

a=dir(fullfile(csvDir,'*csv'));
acc=[];
pred=[];
i=1;
for i=1:numel(a)
    subjects{i} = strrep(a(i).name,fstr,'');     % get subj id
    d0=readtable(fullfile(csvDir,a(i).name),'ReadVariableNames',0);
    if size(d0,2)==12
        d0.Properties.VariableNames=varNames2;
        pred(:,i)=d0.test_prediction;
        pred(pred==-1)=0; % recode -1 predictions to be 0
    elseif size(d0,2)==13
        d0.Properties.VariableNames=varNames3;
        pred(:,i)=d0.test_prediction;
        pred(pred==-1)=0; % recode -1 predictions to be 0
        train_acc(:,i)=d0.train_accuracy;
    else
        d0.Properties.VariableNames=varNames;
    end
    nr(i) = size(d0,1);
    acc(:,i)=d0.accuracy;
end
ave_acc = mean(acc,2);



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

plot_mod_idx=2:numel(mods);  % which models to plot?

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

title(sprintf(str))

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
% 
% % get subjects' relapse status
% rel=getCueData(subjects,'relapse_3months');
% 
% nmod = 2; % which model?
% 
% [relS,riS]=sort(rel);  % sort by relapse status
% 
% subsS=subjects(riS);
% this_acc = mod_acc{nmod}(:,riS);
% 
% 
% fig=setupFig
% hold on
% imagesc(this_acc)
% colormap(winter)
% colorbar
% set(gca,'XTick',1:numel(subjects))
% set(gca,'XTickLabels',subsS)
% plot([find(diff(relS))+.5 find(diff(relS))+.5],[0 size(this_acc,1)],'Linewidth',2,'color',[1 1 1])
% xtickangle(45)
% 
% ylim([1,numel(pfeatures)])
% yt=get(gca,'YTickLabels'); % ordinal x tick values
% yt=cellfun(@(y) round(pfeatures(str2num(y)).*1000)./10, yt, 'uniformoutput',0);
% set(gca,'YTickLabels',yt)
% ylabel('percent of features')
% 
% % set(colorbar,'Ticks',[0 1])
% % set(colorbar,'TickLabels',{'correct','incorrect'})
% 
% % change save name based on whether elastic net is included or not
% title(sprintf('nonrelapsers are on the left, relapsers on the right\n1 means prediction was right; 0 means prediction was wrong'))
% saveName = 'subj_accuracy_by_percentfeatures.png';
% 
% savePath = fullfile(figDir,saveName);
% 
% print(fig,'-dpng','-r300',savePath)
% 
% 
% 
% 
% %% do the plot for predictions if possible
% 
% if ~notDefined('mod_pred')
%     this_pred = mod_pred{nmod}(:,riS);
%     
%     fig2=setupFig
%     hold on
%     imagesc(this_pred)
%     colormap(winter)
%     colorbar
%     set(gca,'XTick',1:numel(subjects))
%     set(gca,'XTickLabels',subsS)
%     plot([find(diff(relS))+.5 find(diff(relS))+.5],[0 size(this_acc,1)],'Linewidth',2,'color',[1 1 1])
%     xtickangle(45)
%     
%     ylim([1,numel(pfeatures)])
%     yt=get(gca,'YTickLabels'); % ordinal x tick values
%     yt=cellfun(@(y) round(pfeatures(str2num(y)).*1000)./10, yt, 'uniformoutput',0);
%     set(gca,'YTickLabels',yt)
%     ylabel('percent of features')
%     
%     % set(colorbar,'Ticks',[0 1])
%     % set(colorbar,'TickLabels',{'correct','incorrect'})
%     
%     % change save name based on whether elastic net is included or not
%     title(sprintf('nonrelapsers are on the left, relapsers on the right\n1 means predicted relapser; 0 means predicted abstainer'))
%     saveName = 'testsubj_predictions_by_percentfeatures.png';
%     
%     savePath = fullfile(figDir,saveName);
%     
%     print(fig2,'-dpng','-r300',savePath)
% end
% 
% 
% %% percent correct when test subject is a relapser vs non-relapser
% %
% % abstainers_acc = mean(this_acc(:,relS==0),2);
% % relapsers_acc = mean(this_acc(:,relS==1),2);
% %
% % fig=setupFig
% % hold on
% % imagesc([abstainers_acc relapsers_acc])
% % colormap(winter)
% % colorbar
% % set(gca,'XTick',[1 2])
% % set(gca,'XTickLabels',{'abstainers','relapsers'})
% % xlabel('percent accuracy')
% %
% %  ylim([1,numel(pfeatures)])
% % yt=get(gca,'YTickLabels'); % ordinal x tick values
% % yt=cellfun(@(y) round(pfeatures(str2num(y)).*1000)./10, yt, 'uniformoutput',0);
% % set(gca,'YTickLabels',yt)
% % ylabel('percent of features')

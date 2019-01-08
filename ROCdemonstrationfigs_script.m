

clear all
close all


outDir='/Users/kelly/Google Drive/talks/SPANlabmeeting181017';

% specs = [0 1];
% mu1=.7;
% mu2=.3;
% sigma=.1;
% 
mu1=.6;
mu2=.4;
sigma=.1;

n=100000;
% mu1=.5;
% mu2=.5;
% sigma=.1;


cols=[ 0.8627    0.1961    0.1843;
    0.1490    0.5451    0.8235];

a = normrnd(mu1,sigma,n,1);
b = normrnd(mu2,sigma,n,1);

hh = plotNiceNHist({a,b},cols,'',{'true yes','true no'},'')

% save, if desired
cd(outDir)
print(gcf,'-dpng','-r300','2dist_overlap')



%% ROC curves


%     
% pred = mod{m};
% 
% 
% %%
% % Fit a logistic regression model.
% mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');    



%%
% Compute the ROC curve. Use the probability estimates from the logistic
% regression model as scores.
% scores = mdl.Fitted.Probability;

%%
% The area under the curve is 0.7698. The maximum AUC is 1, which corresponds to a perfect
% classifier. Larger AUC values indicate better classifier performance.
%%
% Plot the ROC curve.

fig=setupFig
hold on
plot([0 1],[0 1],'linewidth',2,'color',[.5 .5 .5])
xlabel('1 - specificity') % false positive rate 
ylabel('sensitivity') % true positive rate 

print(gcf,'-dpng','-r300','ROC0')



scores=[a;b];
resp = [ones(n,1);zeros(n,1)];
[X,Y,thresh,AUC] = perfcurve(resp,scores,1); 
plot(X,Y,'LineWidth',2,'color',cols(1,:))
print(gcf,'-dpng','-r300','ROC1')


% specs = [0 1];
mu1=.6;
mu2=.4;
sigma=.1;

a = normrnd(mu1,sigma,100000,1);
b = normrnd(mu2,sigma,100000,1);

scores=[a;b];
resp = [ones(100000,1);zeros(100000,1)];
[X,Y,thresh,AUC(2)] = perfcurve(resp,scores,1); 
plot(X,Y,'LineWidth',2,'color',cols(2,:))
print(gcf,'-dpng','-r300','ROC2')


% specs = [0 1];
mu1=.52;
mu2=.48;
sigma=.1;

a = normrnd(mu1,sigma,100000,1);
b = normrnd(mu2,sigma,100000,1);

scores=[a;b];
resp = [ones(100000,1);zeros(100000,1)];
[X,Y,thresh,AUC(3)] = perfcurve(resp,scores,1); 
plot(X,Y,'LineWidth',2,'color',[ 0.1647    0.6314    0.5961])
print(gcf,'-dpng','-r300','ROC3')


%%
% |perfcurve| stores the threshold values in the array |T|.
%%
% Display the area under the curve.
AUC


% title('ROC for Classification by Logistic Regression')



%% save versions with and without legends




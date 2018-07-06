% 

clear all
close all

% import data
cd /Users/kelly/cueexp/mturk_normative_data
import_batch3_ratings_script

raw_d = batch3ratings(:,2:end);

conds = {'alcohol','drugs','food','neutral'};

ci = [1 3 2 3 4 4 3 2 2 3 3 1 4 2 1 2 4 1 2 3 4 1 4 1 2]; 
% note: Emily has 17 coded as alcohol and 18 coded as neutral, but all 
% mturk raters identify image 17 as neutral and 18 as alcohol, so I'm goign
% with their rating. 

[rr,rc]=find(isnan(raw_d));

raw_d(:,unique(rc))=[];

clarity = raw_d(:,1:6:150);
identity = raw_d(:,2:6:150);
val = raw_d(:,3:6:150);
arousal = raw_d(:,4:6:150);
want = raw_d(:,5:6:150);
familiar = raw_d(:,6:6:150);

outDir = fullfile('/Users/kelly/cueexp','paper_figs_tables_stats','normative_ratings','data');

if ~exist(outDir,'dir')
    mkdir(outDir);
end


%% xform val and arousal to pa and na 

[pa,na]=va2pana(val,arousal);


%%%%%%%%%%%%%%%%%%%%%%%%%%%% pref ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean pref ratings by condition w/subjects in rows
mean_want = [];
mean_pa=[];
mean_na=[];
mean_familiar=[];

for j=1:numel(conds) % # of conds
    mean_want(:,j) = nanmean(want(:,ci==j),2);
    mean_pa(:,j) = nanmean(pa(:,ci==j),2);
    mean_na(:,j) = nanmean(na(:,ci==j),2);
    mean_familiar(:,j) = nanmean(familiar(:,ci==j),2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save out csv files 

N=size(raw_d,1);

% make group string column
group = repmat({'raters'},N,1);

cd(outDir);


%% want ratings

d = mean_want; 
varStr = '_want';
outName = 'want_ratings.csv';
for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end
T=array2table(d,'VariableNames',varNames);
T=[table(group) T]; 
writetable(T,outName);


%% pa ratings

d = mean_pa; 
varStr = '_PA';
outName = 'pa_ratings.csv';
for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end
T=array2table(d,'VariableNames',varNames);
T=[table(group) T]; 
writetable(T,outName);


%% na ratings

d = mean_na; 
varStr = '_NA';
outName = 'na_ratings.csv';
for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end
T=array2table(d,'VariableNames',varNames);
T=[table(group) T]; 
writetable(T,outName);

%% familiar ratings

d = mean_familiar; 
varStr = '_familiar';
outName = 'familiar_ratings.csv';
for i=1:numel(conds)
    varNames{i} = [conds{i} varStr];
end
T=array2table(d,'VariableNames',varNames);
T=[table(group) T]; 
writetable(T,outName);


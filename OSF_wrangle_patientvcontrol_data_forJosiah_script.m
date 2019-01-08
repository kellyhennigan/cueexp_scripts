
clear all
close all


p = getCuePaths(); dataDir = p.data; % cue exp paths

task = '';


[subjects,gi,notes] = getCueSubjects(task); 
subjects(91:end)=[];
gi(91:end)=[];

subjects(71)=[];
gi(71)=[];
% subjid=[1:numel(subjects)]';

% filepath for saving out table of variables
% outPath = fullfile(dataDir,'relapse_data',['relapse_data_' datestr(now,'yymmdd') '_allsubs.csv']);
outPath = fullfile('/Users/kelly/cueexp/data/demodata/',['demodata_' datestr(now,'yymmdd') '.csv']);

notes(91:end)=[];
notes(71)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% behavioral data

age=getCueData(subjects,'age');
sex=getCueData(subjects,'gender');
education=getCueData(subjects,'education');
race=getCueData(subjects,'race');
smokers=getCueData(subjects,'smoke');
smokeperday=getCueData(subjects,'smokeperday');
kirbyk=getCueData(subjects,'discount_rate');
veteran=cellfun(@(x) ~isempty(strfind(x,'veteran')), notes);
veteran(gi==1)=1;

T=table(subjects,gi,age,sex,education,race,smokers,smokeperday,veteran,kirbyk)
% save out
writetable(T,outPath); 



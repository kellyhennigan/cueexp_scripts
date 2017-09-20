%% get subject demographics script

clear all
close all

p = getCuePaths(); 
dataDir = p.data;

groupNames = {'controls','patients'};
% groupNames = {'relapsers','nonrelapsers'};



%% do it 

g=2; % groupNames

groupName = groupNames{g};

[subjects,gi,notes,~] = getCueSubjects('mid',1);
ri=getCueRelapseData(subjects);

subjects = subjects(ri~=1);

s = {}; % cell array to house all demographics strings

%% group N


s{end+1}=sprintf('\n\n\n%s: n=%d',groupName,numel(subjects));


%% gender 

gender = getCueData(subjects,'gender');

s{end+1} = sprintf('\nmale (percentage): %.2f',numel(find(gender==1))./numel(subjects));


%% age

age = getCueData(subjects,'age');

s{end+1}=sprintf('\nage (mean/sd): %.1f/%.1f',mean(age),std(age));


%% race/ethnicity

race=getCueData(subjects,'race');

% NIH categories: 
%     1= American indian/alaska native
%     2= Asian
%     3= Black
%     4= Hispanic/Latino
%     5= Native Hawaiian or Pacific Islander
%     6=White
%     7= Multiracial
%     8= Would rather not say

raceCats = {'American indian',...
    'Asian',...
    'Black',...
    'Hisp/Latino',...
    'Pac islander',...
    'White',...
    'Multi',...
    'Other'};
    
raceStr = sprintf('\nrace/ethnicity (percentage):\n ');
for r=1:numel(raceCats)
    raceStr = [raceStr sprintf('\t%s: %.2f\n',raceCats{r},numel(race(race==r))./numel(subjects))];
end

s{end+1} = raceStr;


%% education

educ = getCueData(subjects,'education');

s{end+1} = sprintf('\npercent some college: %.2f',numel(find(educ{1}>=3))./numel(subjects));


%% smokers

smoke = getCueData(subjects,'smoke');

smoker_idx = smoke{1}; smoker_idx(isnan(smoker_idx))=[];

s{end+1} = sprintf('\npercent smokers: %.2f',numel(find(smoker_idx==1))./numel(smoker_idx));


%% veteran

if gi(1)==1
    nVets=numel(subjects);
else
    nVets = sum(cellfun(@(x) ~isempty(strfind(x,'veteran')), notes));
end
s{end+1}=sprintf('\n# of veterans: %d',nVets);




%% display results

for i=1:numel(s)
    disp(s{i});
end



%% other patient measures

pm={'primary_stim','alc_dep','other_drug_dep',...
    'years_of_use','most_recent_use','depression_diag',...
    'ptsd_diag','other_diag','meds','dop_drugtest',...
    'for_admit_date','dop','for_discharge_date','days_sober'};

for j=1:numel(pm)
    d=getCueData(subjects,pm{j});
end



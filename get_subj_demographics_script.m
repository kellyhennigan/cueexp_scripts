%% get subject demographics script

clear all
close all

p = getCuePaths(); 
dataDir = p.data;

task = 'dti'; 

%  group = 'nonrelapsers_6months';  % can be controls, patients, relapsers, or nonrelapsers
% group = 'patients';
% group = 'controls';
group = 'relapsers_3months';
   
[subjects,gi,notes] = getCueSubjects(task,group);
% subjects(22:end)=[]; gi(22:end)=[];
% 
% omit_subs = {'at160601','lm160914'};
% % omit_subs = {'ja160416'};
% omit_idx=ismember(subjects,omit_subs);
% subjects(omit_idx,:)=[];

% idx=find(strcmp(subjects,'tf151127'));
% idx = []
% subjects(idx)=[];
% gi(idx)=[];

%% do it 


s = {}; % cell array to house all demographics strings

%% group N

N = numel(subjects);
s{end+1}=sprintf('\n\n\n%s: n=%d',group,N);


%% age

age = getCueData(subjects,'age');

s{end+1}=sprintf('\nage (mean/sd): %.1f/%.1f',nanmean(age),nanstd(age));


%% gender 

gender = getCueData(subjects,'gender');

s{end+1} = sprintf('\npercent male: %.2f',numel(find(gender==1))./numel(gender(~isnan(gender))));



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
    raceStr = [raceStr sprintf('\t%s: %.2f\n',raceCats{r},numel(race(race==r))./numel(race(~isnan(race))))];
end

s{end+1} = raceStr;


%% education

education = getCueData(subjects,'education');

s{end+1} = sprintf('\nyears of completed education (mean/sd): %.1f/%.1f',nanmean(education),nanstd(education));


%% smokers

smoke = getCueData(subjects,'smoke');

s{end+1} = sprintf('\npercent smokers: %.2f',numel(find(smoke==1))./numel(smoke(~isnan(smoke))));


%% # veterans

if gi(1)==1
    nVets=numel(subjects);
else
    nVets = sum(cellfun(@(x) ~isempty(strfind(x,'veteran')), notes));
end
s{end+1}=sprintf('\npercent veterans: %.2f',nVets./N);


%% BDI 

bdi = getCueData(subjects,'bdi');

s{end+1}=sprintf('\nBDI scores (mean/sd): %.1f/%.1f',nanmean(bdi),nanstd(bdi));

% BDI score of 17 or greater constitutes clinical depression
% s{end+1} = sprintf('\npercent clinical depression (mild-severe): %.2f',numel(find(bdi>=17))./numel(bdi(~isnan(bdi))));


%% BIS

bis = getCueData(subjects,'bis');

s{end+1}=sprintf('\nBIS scores (mean/sd): %.1f/%.1f',nanmean(bis),nanstd(bis));


%% discount rate

k = getCueData(subjects,'discount_rate');

s{end+1}=sprintf('\nkirby discounting log(k) (mean/sd): %.2f/%.2f',nanmean(log(k)),nanstd(log(k)));



%% patient-specific measures

if ~strcmp(group,'controls')
    
    % primary stim
    d=getCueData(subjects,'primary_meth');
    s{end+1}=sprintf('\npercent of meth users: %.2f',sum(d)./N);
    
    % dependence on alc?
    d=getCueData(subjects,'alc_dep');
    s{end+1} = sprintf('\npercent alc dep: %.2f',numel(find(d==1))./N);
 
       % dependence on alc?
    d=getCueData(subjects,'auditscore4orgreater');
    s{end+1} = sprintf('\npercent audit score 4 or greater: %.2f',numel(find(d==1))./N);
 
         % dependence on cannabis?
    d=getCueData(subjects,'cannabisuse');
    s{end+1} = sprintf('\npercent cannabis dep: %.2f',numel(find(d==1))./N);

        % dependence on opioid?
    d=getCueData(subjects,'opioidusedisorder');
    s{end+1} = sprintf('\npercent opioid dep: %.2f',numel(find(d==1))./N);


    % poly-drug dependence?
    d=getCueData(subjects,'poly_drug_dep');
    s{end+1} = sprintf('\npercent poly drug dep: %.2f',numel(find(d==1))./N);
    
    % days sober
    d=getCueData(subjects,'days_sober');
%      temporary: 
%     d(d>1000)=nan;
    s{end+1}=sprintf('\ndays sober (median/sd): %.1f/%.1f',nanmedian(d),nanstd(d));
    
        % days in rehab
    rehab_days=getCueData(subjects,'days_in_rehab');
    s{end+1}=sprintf('\ndays in rehab (mean/sd): %.1f/%.1f',nanmean(rehab_days),nanstd(rehab_days));

      % years of use
    yearsofuse=getCueData(subjects,'years_of_use');
    s{end+1}=sprintf('\nyears of use (mean/sd): %.1f/%.1f',nanmean(yearsofuse),nanstd(yearsofuse));

  
      % anxiety diagnosis
%     d=getCueData(subjects,'anxiety_diag');
%     nAnx = sum(cellfun(@(x) ~isempty(strfind(x,'yes')), d));
%     s{end+1}=sprintf('\npercent anxiety diagnosis: %.2f',nAnx./N);
%  

% ptsd diagnosis
    d=getCueData(subjects,'ptsd_diag');
    s{end+1}=sprintf('\npercent PTSD diagnosis: %.2f',sum(d)./N);

    % anxiety diagnosis
    d=getCueData(subjects,'anxiety_diag');
    s{end+1}=sprintf('\npercent anxiety diagnosis: %.2f',sum(d)./N);

    % depression diagnosis
    d=getCueData(subjects,'depression_diag');
    s{end+1}=sprintf('\npercent depression diagnosis: %.2f',sum(d)./N);

   % craving measure
    craving=getCueData(subjects,'craving');
    s{end+1}=sprintf('\ncraving measure (mean/sd): %.1f/%.1f',nanmean(craving),nanstd(craving));
  
%     pm={'primary_stim','alc_dep','other_drug_dep',...
%         'years_of_use','most_recent_use','depression_diag',...
%         'ptsd_diag','other_diag','meds','dop_drugtest',...
%         'for_admit_date','dop','for_discharge_date','days_sober'};
%     
%     for j=1:numel(pm)
%         d=getCueData(subjects,pm{j});
%     end
    
end % patient measures


%% display results

for i=1:numel(s)
    disp(s{i});
end


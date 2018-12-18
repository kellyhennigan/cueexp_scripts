%% script to compare demographic vars across groups

clear all
close all

p = getCuePaths(); 
dataDir = p.data;

task = 'cue'; 

% groups = {'controls','relapsers_6months','nonrelapsers_6months'};
% groups = {'controls','patients'};

% demVars = {'age','gender','education','smoke','bdi','bis','discount_rate'};
% demVars = {'discount_rate'};

% 
demVars = {'age','gender','education','smoke','bdi','bis','discount_rate',...
    'primary_meth',...
    'auditscore4orgreater',...
    'opioidusedisorder',...
    'cannabisusedisorder',...
    'poly_drug_dep',...
    'days_sober',...
    'days_in_rehab',...
    'years_of_use',...
    'ptsd_diag',...
    'anxiety_diag',...
    'depression_diag',...
    'craving',...
    };

     
subs = getCueSubjects('cue',1); 
subs(37:end)=[];

rel= getCueData(subs,'relapse_3months');

% omit subs without relapse data up to this point
subs(isnan(rel))=[];
rel(isnan(rel))=[];

groups = {'early_abstainers','early_relapsers'}; % group names

group_subs{1} = subs(rel==0); 
group_subs{2} = subs(rel==1); 

%% 

for i=1:numel(demVars)
    
    var = [];
    gvar = [];
    
    for g=1:numel(groups)
       
        d=getCueData(group_subs{g},demVars{i});

        % take log of discount rate
        if strcmp(demVars{i},'discount_rate')
            d=log(d);
        end
        var = [var; d];  % dem variable 
        gvar = [gvar; ones(numel(d),1).*g];  % group index
        
    end

    p=anova1(var,gvar,'off');
    if p<.05
        fprintf('\nsig difference for var: %s\n',demVars{i})
    else
        fprintf('\nNO difference for var: %s\n',demVars{i})
    end
end


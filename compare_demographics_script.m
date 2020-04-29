%% script to compare demographic vars across groups

clear all
close all

p = getCuePaths(); 
dataDir = p.data;

task = 'dti'; 

% groups = {'early_relapsers','early_abstainers'};
% groups = {'controls','relapsers_6months','nonrelapsers_6months'};
groups = {'controls','patients'};

% demVars = {'age','gender','education','smoke','bdi','bis','discount_rate'};
% demVars = {'discount_rate'};

% 
demVars = {'age','gender','education','smoke','bdi','bis','discount_rate',...
    'primary_meth',...
    'alc_dep',...
    'poly_drug_dep',...
    'days_sober',...
    'days_in_rehab',...
    'years_of_use',...
    'ptsd_diag',...
    'anxiety_diag',...
    'depression_diag',...
    'craving',...
    };

% omit_subs = {'wh160130','at160601','lm160914','jb161004','se161021','ja160416'};
% omit_subs = {'ja160416'};
     omit_subs = {''};

%% 

for i=1:numel(demVars)
    
    var = [];
    gvar = [];
    
    for g=1:numel(groups)
        
        subs=getCueSubjects('cue',groups{g});
        
        omit_idx=ismember(subs,omit_subs);
        subs(omit_idx,:)=[];
    
        d=getCueData(subs,demVars{i});

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


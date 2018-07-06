%% script to compare demographic vars across patients NOT lost to followups 
% vs those that were lost to followups 

clear all
close all

p = getCuePaths(); 
dataDir = p.data;

task = 'cue'; 

% groups = {'relapsers_6months','nonrelapsers_6months'};
% groups = {'controls','relapsers_6months','nonrelapsers_6months'};
groups = {'patients not lost','patients lost'};


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


subs = getCueSubjects('cue',1);
lost_subs = {'er171009','wh160130','at160601','lm160914','jb161004','se161021'};
lost_idx=ismember(subs,lost_subs);
subs(lost_idx)=[];

rel_subs=getCueSubjects('cue','relapsers_6months');
rel_idx=ismember(subs,rel_subs);

gi = ones(numel(subs),1);
gi(rel_idx)=2;

%% 

for i=1:numel(demVars)
    
        d=getCueData(subs,demVars{i});
       
        % take log of discount rate
        if strcmp(demVars{i},'discount_rate')
            d=log(d);
        end
   
    p=anova1(d,gi,'off');
    if p<.05
        fprintf('\nsig difference for var: %s\n',demVars{i})
    else
        fprintf('\nNO difference for var: %s\n',demVars{i})
    end
end


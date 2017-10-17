
% script to make afni 3dANOVA3 command for cue data 
% see here for more info:
% http://brainimaging.waisman.wisc.edu/~tjohnstone/AFNI_fundamental.html#_10._Group_analysis

clear all
close all

p = getCuePaths();
dataDir = p.data;

[subjects,gi]=getCueSubjects('cue');

% eliminate 3 youngest subjects from control group to make equal # of
% controls vs patients:
% age= getCueData(subjects,'age');
% subjects(age<20)=[]; gi(age<20)=[]; age(age<20)=[];

atype = 5; % 5   A,B fixed; C random;  AxB,BxC,C(A), meaning C is nested in A

maskfilepath = fullfile(dataDir,'templates','bmask.nii');

%% DEFINE ANOVA FACTORS

% FACTOR A: GROUP
alevels = 2; % groups
subs{1} = subjects(gi==1); % patients
subs{2} = subjects(gi==0); % controls


% FACTOR B: CONDITION
blevels = 3; % condition (drugs, food, neutral)
b_vols = [16,17,18]; % vol indices of condition betas in subj glm results niftis


% FACTOR C: subjects as random effects
clevels = numel(subs{1}); % # of subjects in patient group (also must be the same number of subjects in the control group)


%% ANOVA COMMAND:


anova_cmd = sprintf(['3dANOVA3 -type %d ',...
    '-alevels %d -blevels %d -clevels %d %s\n'],...
    atype,alevels,blevels,clevels,'\');


%% LINES FOR SPECIFYING DATA

cmd = [];
for aa=1:alevels
    for bb=1:blevels
        for cc=1:clevels
            
            str = sprintf('-dset %d %d %d %s_glm_B+tlrc[%d] %s\n',...
                aa,...
                bb,...
                cc,...
                subs{aa}{cc},...
                b_vols(bb),...
                '\');
            
            cmd = [cmd str];
        end
    end
end


%% add the rest of the command:

cmd2 = sprintf(['-fa group -fb cond -fab groupByCond %s\n',...
    '-acontr 1 0 patients -acontr 0 1 controls %s\n',...
    '-bcontr 1 0 0 drugs -bcontr 0 1 0 food -bcontr 0 0 1 neutral %s\n',...
    '-acontr 1 1 PvC %s\n',...
    '-bcontr 1 -1 0 drugs_v_food -bcontr 1 0 -1 drugs_v_neutral -bcontr 0 1 -1 food_v_neutral -bcontr 1 -0.5 -0.5 drug_v_foodneutral %s\n',...
    '-aBcontr 1 -1 : 1 PvC_drugs -aBcontr 1 -1 : 2 PvC_food -aBcontr 1 -1 : 3 PvC_neutral %s\n',...
    '-Abcontr 1 : 1 -1 0 drugs_v_food_patients -Abcontr 2 : 1 -1 0 drugs_v_food_controls %s\n',...
    '-mask ' maskfilepath ' %s\n',...
    '-bucket anova_res'],'\','\','\','\','\','\','\','\');

% line 1 specifies that we want the F-test for the group main effect,
% the F-test for the condition main effect, and the F-test for the group by
% condition interaction.


% lines 2 and 3  specify that we want the factor level means and
% statistical tests of whether those means are significantly different from
% 0.

% lines 4 and 5  test specific contrasts for each factor, averaged across the levels of the other factors.

% lines 6 and 7  test contrasts for one factor calculated within a
% specific level of the other factor.

% Finally, line 8 says that all the results should be saved in a statistical bucket dataset called anova+tlrc.

% There are abviously many more contrasts that could be specified than the
% ones we have here. Bear in mind that you should really only be looking at
% these contrasts if i) you have an apriori hypothesis about a specific
% contrast, ii) the main effect F-test for a given factor is significant
% and you want to know which factor level differences are driving the main
% effect, or ii) the interaction of two factors is significant and you need
% to know what differences are driving the interaction. Don-t fall victim
% to a fishing expedition in which you test every single possible contrast,
% and possibly wind up with a catch of junk. If you must do exploratory
% analyses, then you should guard against Type I error by adopting a
% suitably more stringent threshold.


%% put it all together

% get afni bin dir (there's surely a better way to do this)
homeDir = getHomeDir;
if strcmp(homeDir,'/home/hennigan')  % CNI VM server
    afniDir = '/usr/lib/afni/bin/';
else
    afniDir = '~/abin/';
end

anova_cmd = [anova_cmd cmd cmd2];
anova_cmd2= [afniDir anova_cmd];

disp(anova_cmd2)
% system(anova_cmd2)

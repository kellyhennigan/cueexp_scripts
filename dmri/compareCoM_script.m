% script to determine the spatial organization of fiber groups projecting
% to/from the midbrain.

% gives stats for testing for a medial-lateral organization of DA
% endpoints.

clear all
close all

p=getCuePaths();
dataDir = p.data;



% fibers directory relative to subject dir
% inDir = fullfile(dataDir,'fg_densities','mrtrix_fa');
inDir = fullfile(dataDir,'fgendpt_com_coords');

seed = 'DA';

targets = {'nacc','nacc','caudate','putamen'};

gspace = 'mni';

CoMFileStrs = {[seed '%s_%s%s_belowAC_autoclean_DAendpts_CoM_' gspace '.txt'];
    [seed '%s_%s%s_aboveAC_autoclean_DAendpts_CoM_' gspace '.txt']
    [seed '%s_%s%s_autoclean_DAendpts_CoM_' gspace '.txt'];
    [seed '%s_%s%s_autoclean_DAendpts_CoM_' gspace '.txt']}; % %s's are: L/R, target, L/R

lr='LR';

mergeLR=1; 

%%

% combine L and R sides
if mergeLR

    lr='LR';
    j=1    
    for j=1:numel(targets)
        
        TL=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},'L',targets{j},'L')));
        TR=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},'R',targets{j},'R')));
        
        % make sure the CoM files have the same subjects in the same order
        if j==1
            subjects=table2array(TL(:,1));
        end
        if ~isequal(TL.Var1,subjects) || ~isequal(TR.Var1,subjects)
            error('hold up - the subjects in the center of mass files arent the same!')
        end
        
        comL=table2array(TL(:,2:4)); 
        comL(:,1)=abs(comL(:,1)); % get abs value for left x coords
        CoM{j}=[comL+table2array(TR(:,2:4))]./2; % get average over left and right
        
        x(:,j)=CoM{j}(:,1); y(:,j)=CoM{j}(:,2); z(:,j)=CoM{j}(:,3);
    
    end

    
% to NOT merge L and R: 
else 

    
    for j=1:numel(targets)
        
        T=readtable(fullfile(inDir,sprintf(CoMFileStrs{j},lr,targets{j},lr)));
        
        % make sure the CoM files have the same subjects in the same order
        if j==1
            subjects=table2array(T(:,1));
        else
            if ~isequal(T.Var1,subjects)
                error('hold up - the subjects in the center of mass files arent the same!')
            end
        end
        CoM{j}=table2array(T(:,2:4));
        x(:,j)=CoM{j}(:,1); y(:,j)=CoM{j}(:,2); z(:,j)=CoM{j}(:,3);
    end
  
end %mergeLR

fprintf('\n\n%%%%%%%%% %s SIDE: %%%%%%%%%%%%%\n\n',lr)
     
    %% test medial-lateral gradient
    
%     teststr = 'medial';
%     
%     ti=[1 2];
%     res=[abs(x(:,ti(1)))<abs(x(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%     res2=double(res);
%     res2(res2<1)=-1;
%     [p,h]=signtest(res2)
%     
%     ti=[1 3];
%     res=[abs(x(:,ti(1)))<abs(x(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%       res2=double(res);
%     res2(res2<1)=-1;
%     [p,h]=signtest(res2)
%   
%     ti=[2 3];
%     res=[abs(x(:,ti(1)))<abs(x(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%       res2=double(res);
%     res2(res2<1)=-1;
%     [p,h]=signtest(res2)
%   
%     
%     %% test anterior-posterior gradient
%     
%     teststr = 'anterior';
%     
%     ti=[1 2];
%     res=[abs(y(:,ti(1)))<abs(y(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%     
%     ti=[1 3];
%     res=[abs(y(:,ti(1)))<abs(y(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%     
%     ti=[2 3];
%     res=[abs(y(:,ti(1)))<abs(y(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%     
%     
%     
%     %% test interior-superior gradient
%     
%     teststr = 'inferior';
%     
%     ti=[1 2];
%     res=[abs(z(:,ti(1)))<abs(z(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%     
%     ti=[1 3];
%     res=[abs(z(:,ti(1)))<abs(z(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
%     
%     ti=[2 3];
%     res=[abs(z(:,ti(1)))<abs(z(:,ti(2)))];
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});
    
    

%% repeated measures ANOVA to test medial-lateral gradient

  [p,tab]=anova_rm(x,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
        
        % get F stats
        Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
        Fg=tab{strcmp(tab(:,1),'Subjects (matching)'),strcmp(tab(1,:),'F')}; % subjects
        
        % corresponding eta-squared (effect sizes)
        etasq_c=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
        etasq_g=tab{strcmp(tab(:,1),'Subjects (matching)'),strcmp(tab(1,:),'SS')}./tab{strcmp(tab(:,1),'Total'),strcmp(tab(1,:),'SS')};
        
        % corresponding degrees of freedom
        df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
        df_g = tab{strcmp(tab(:,1),'Subjects (matching)'),strcmp(tab(1,:),'df')}; % group
        
        df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
        
        res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f; eta_sq=%.3f\n\n',1,3),...
            'ROI',df_c,df_e,Fc,p(1),etasq_c);
        
      fprintf(res)

  % MFB vs NAcc above AC
  [h,p,~,stats]=ttest(x(:,1),x(:,2));
  fprintf('\nMFB vs nacc above: t(%d)=%.3f; p=%.3f\n\n',stats.df,stats.tstat,p);
  
  % NAcc above AC vs caudate
  [h,p,~,stats]=ttest(x(:,2),x(:,3));
  fprintf('\nnacc above vs caudate: t(%d)=%.3f; p=%.3f\n\n',stats.df,stats.tstat,p);

    % caudate vs putamen
  [h,p,~,stats]=ttest(x(:,3),x(:,4));
  fprintf('\ncaudate vs putamen: t(%d)=%.3f; p=%.3f\n\n',stats.df,stats.tstat,p);

   
%     fprintf(['\nfor %d out of %d subjects, %s endpoints for \n%s pathways '...
%         'are more %s than %s pathways\n'],sum(res),numel(res),seed,targets{ti(1)},teststr,targets{ti(2)});


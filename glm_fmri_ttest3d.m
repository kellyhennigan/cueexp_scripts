function out = glm_fmri_ttest3d(A,B,groups,mask,outPath,stat)
% -------------------------------------------------------------------------
% usage: takes in single-subject statistics for groups A and B and creates
% an out file of summary group stats that is similar to whats created by
% 3dttest++
%
%
% INPUT:
%   A & B - single-subject stats to perform group level statistics on. They
%       should each be:
%             - a matrix of data (ONE GROUP) with either w/ subjects in
%               rows and voxels in columns, or a 4-d matrix with voxels in
%               1st 3 dim and subject stats in 4th dim columns
%       If B is left empty, group stats will be performed only on group A
%       data.
%   mask - template nifti that will be used for saving out group stats. The
%       dimensions, etc. of this nii should match the input data, d. Should
%       be a binary mask with 1s for voxels to include, otherwise, 0. 

%   groups - 1x2 cell array with group names


%   outPath - out path for saving out file

%   stat - (optional); either 't' or 'z'. Returns Z score maps by default.

% OUTPUT:
%   out - out nifti that contains summary stats (either t or Z maps) for
%   each of the comparisons made (i.e., either just 1 vol if just one group
%   is given, or if data from 2 groups is given, 3 vols will be returned)
%   (this file is also saved out to outPath)
%
% NOTES:

% TO DO:
%      make this more general so that group B doesn't have to be given
%
%
%
% author: Kelly, kelhennigan@gmail.com, 14-Jun-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% get group data in desired format (subjects in rows and voxels in columns)
if numel(size(A))==4
    A = reshape(A,prod([size(A,1) size(A,2) size(A,3)]),[]);
end
if numel(size(B))==4
    B = reshape(B,prod([size(B,1) size(B,2) size(B,3)]),[]);
end

if notDefined('outPath')
    outPath = [tempname '.nii'];
end

if notDefined('stat')
    stat='z';
end


dim = size(mask.data); % get dimensions of nifti template


%% calculate t statistics for input single-subject stats


% one-sample t-test for values in group A
[~,~,~,stats] = ttest(A);
t = reshape(stats.tstat,dim(1),dim(2),dim(3)).*mask.data;
df = reshape(stats.df,dim(1),dim(2),dim(3));


if ~isempty(B)
    
    % one-sample t-test for values in group B; convert to Z scores
    [~,~,~,stats] = ttest(B);
    t(:,:,:,2) = reshape(stats.tstat,dim(1),dim(2),dim(3)).*mask.data;
    df(:,:,:,2) = reshape(stats.df,dim(1),dim(2),dim(3));
    
    
    % two-sample t-test for group A vs group B; convert to Z scores
    [~,~,~,stats] = ttest2(A,B);
    t(:,:,:,3) = reshape(stats.tstat,dim(1),dim(2),dim(3)).*mask.data;
    df(:,:,:,3) = reshape(stats.df,dim(1),dim(2),dim(3));
    
    
end


%% save out t or z stats

%%%%%%%%% if t stats are desired:

if strcmpi(stat,'t')
    
    % create new nifti & save it
    writeFileNifti(createNewNii(mask,t,outPath));
    
    
    % change header info to play nice with afni
    cmd =sprintf('3drefit -fbuc -sublabel 0 %s -substatpar 0 fitt %d ',...
        groups{1},mode(squish(df(:,:,:,1),3)));
    
    if ~isempty(B)
        
        cmd =[cmd sprintf(['-sublabel 1 %s -substatpar 1 fitt %d '...
            '-sublabel 2 %s -substatpar 2 fitt %d '],...
            groups{2},mode(df(2,:)),[groups{1} '_vs_' groups{2}],mode(df(3,:)))];
        
    end
    
    cmd = [cmd outPath];
    disp(cmd)
    system(cmd);
    
    
    % after changing header info, load it to return as output
    out = niftiRead(outPath);
    
    
    %%%%%%%%% if z stats are desired:
    
elseif strcmpi(stat,'z')
    
    
    % convert t to Z scores:
    Z = t2z(t,df);
    
    
    %%%%%% if there are -Inf or Inf Zscores, do the weird work-around of
    %%%%%% using afni's 3dcalc command to convert t to Z scores:
    if any(abs(Z(:))==Inf)
        
        fprintf('\n\nUSING AFNI FOR T > Z CONVERSION...\n\n')
        
        Z = zeros(size(Z));  % get Z scores from afni's 3dcalc function
        
        for i=1:size(Z,4)
            
            
            % save out each t-volume as a temporary file
            outStr = tempname;
            tmap = [outStr 'T.nii.gz']; zmap = [outStr 'Z.nii.gz'];
            zmap
            writeFileNifti(createNewNii(mask,t(:,:,:,i),tmap));
            
            cmd = sprintf('3dcalc -datum float -a %s -expr ''fitt_t2z (a,%d)'' -prefix %s',...
                tmap,mode(squish(df(:,:,:,i),3)),zmap);
            disp(cmd)
            system(cmd);
            
            % after changing header info, load z maps it to return as output
            this_nii = niftiRead(zmap);
            Z(:,:,:,i) = this_nii.data;
            
        end
        
    end % afni work around
    
    % create new nifti & save it
    writeFileNifti(createNewNii(mask,Z,outPath));
    
    
    % change header info to play nice with afni
    cmd =sprintf('3drefit -fbuc -sublabel 0 %s -substatpar 0 fizt ',groups{1});
    
    if ~isempty(B)
        
        cmd =[cmd sprintf('-sublabel 1 %s -substatpar 1 fizt -sublabel 2 %s -substatpar 2 fizt ',...
            groups{2},[groups{1} '_vs_' groups{2}])];
        
    end
    
    cmd = [cmd outPath];
    disp(cmd)
    system(cmd);
    
    
    % after changing header info, load it to return as output
    out = niftiRead(outPath);
    
    
end  % strcmp(z or t)


function out = glm_fmri_ttest3d(A,B,groups,nii,outPath,stat)
% -------------------------------------------------------------------------
% usage: takes in single-subject statistics for groups A and B and creates
% an out file of summary group stats that is similar to whats created by
% 3dttest++
%
%
% INPUT:
%   A - matrix of single-subject statistics with subjects in rows, voxels
%       in columns for group A
%   B - " " for group B; leave empty to do tests on just group A
%   nii - template nifti that will be used for saving out group stats
%   groups - 1x2 cell array with group names
%   outPath - out path for saving out file
%   stat - (optional); either 't' or 'z'. Returns Z score maps by default.

% OUTPUT:
%   out - out nifti that contains 2 volumes: a z-map for each group, and a
%   z map comparing the groups
%   (this file is also saved out to outPath)
%
% NOTES:

% TO DO: make this more general so that group B doesn't have to be given
%
% author: Kelly, kelhennigan@gmail.com, 14-Jun-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('outPath')
    outPath = [tempname '.nii'];
end

if notDefined('stat')
    stat='z';
end


if strcmpi(stat,'z')
    
    
    % to get z stats:
    
    % one-sample t-test for values in group A; convert to Z scores
    [~,~,~,stats] = ttest(A);
    this_z = t2z(stats.tstat,stats.df);
    
    % for some reason, really high t vals go to Inf, though this isn't the
    % case for equally low t vals. So calc Z vals for those using this
    % hack:
    idx = find(this_z==Inf);
    idx
    if numel(idx)>0
        tvals=stats.tstat(idx);
        Zvals=t2z(tvals.*-1,stats.df(idx)).*-1;
        this_z(idx) = Zvals;
    end
    
    Z(1,:) = this_z;
    
    
    
    % one-sample t-test for values in group B; convert to Z scores
    [~,~,~,stats] = ttest(B);
    this_z = t2z(stats.tstat,stats.df);
    
    
    % for some reason, really high t vals go to Inf, though this isn't the
    % case for equally low t vals. So calc Z vals for those using this
    % hack:
    idx = find(this_z==Inf);
    if numel(idx)>0
        tvals=stats.tstat(idx);
        Zvals=t2z(tvals.*-1,stats.df(idx)).*-1;
        this_z(idx) = Zvals;
    end
    
    Z(2,:) = this_z;
    
    
    
    % two-sample t-test for group A vs group B; convert to Z scores
    [~,~,~,stats] = ttest2(A,B);
    this_z = t2z(stats.tstat,stats.df);
    
     % for some reason, really high t vals go to Inf, though this isn't the
    % case for equally low t vals. So calc Z vals for those using this
    % hack:
    idx = find(this_z==Inf);
    if numel(idx)>0
        tvals=stats.tstat(idx);
        Zvals=t2z(tvals.*-1,stats.df(idx)).*-1;
        this_z(idx) = Zvals;
    end
    
    Z(3,:) = this_z;
    
    
    %% 

    dim = size(nii.data); % get dimensions of nifti template
    
    
    % create 3d vols of Z-score maps
    Zvol = reshape(Z',dim(1),dim(2),dim(3),3);
    
    
    % create new nifti & save it
    writeFileNifti(createNewNii(nii,Zvol,outPath));
    
    
    % change header info to play nice with afni
    cmd = sprintf(['3drefit -fbuc -sublabel 0 %s -substatpar 0 fizt '...
        '-sublabel 1 %s -substatpar 1 fizt '...
        '-sublabel 2 %s -substatpar 2 fizt %s'],...
        groups{1},groups{2},[groups{1} '_vs_' groups{2}],outPath);
    disp(cmd)
    system(cmd);
    
    
    % after changing header info, load it to return as output
    out = niftiRead(outPath);
    
    
    
    %% to get t-stats:
    
elseif strcmpi(stat,'t')
    
    
    % one-sample t-test for values in group A; convert to Z scores
    [~,~,~,stats] = ttest(A);
    t(1,:) = stats.tstat; df(1,:) = stats.df;
    
    % one-sample t-test for values in group B; convert to Z scores
    [~,~,~,stats] = ttest(B);
    t(2,:) = stats.tstat; df(2,:) = stats.df;
    
    
    % two-sample t-test for group A vs group B; convert to Z scores
    [~,~,~,stats] = ttest2(A,B);
    t(3,:) = stats.tstat; df(3,:) = stats.df;
    
    
    
    dim = size(nii.data); % get dimensions of nifti template
    
    
    % create 3d vols of Z-score maps
    tvol = reshape(t',dim(1),dim(2),dim(3),3);
    
    
    % create new nifti & save it
    writeFileNifti(createNewNii(nii,tvol,outPath));
    
    
    % change header info to play nice with afni
    cmd =sprintf(['3drefit -fbuc -sublabel 0 %s -substatpar 0 fitt %d '...
        '-sublabel 1 %s -substatpar 1 fitt %d '...
        '-sublabel 2 %s -substatpar 2 fitt %d %s'],...
        groups{1},mode(df(1,:)),groups{2},mode(df(2,:)),'patients_vs_controls',mode(df(3,:)),outPath);
    disp(cmd)
    system(cmd);
    
    
    % after changing header info, load it to return as output
    out = niftiRead(outPath);
    
    
end
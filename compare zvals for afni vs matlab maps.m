

%% compare Z vals for afni B vs matlab B at the non-extreme Z values
% calculating Z and t stats manually on the fly


clear all
close all

cd /Users/kelly/cueexp/data/zmap_comp

mask=niftiRead('../templates/bmask.nii');
dim=mask.dim;

mapfiles = {'Zafni.nii'      % afni B map
    'Zmatlab.nii.gz'
    'Z3dcalc.nii.gz'};     % matlab B map using afni's T>Z conversion

mapnames = {'afni','matlab','3dcalc'}

%%%%%%% vol index to compare:

% for controls vs patients:
% vi = [2 3 3];

% for just controls: 
 vi = [6 1 1];

% for just patients:
%  vi = [4 2 2];


% put afni file in same format as matlab files
for i=1:numel(mapfiles)
    
    ni = niftiRead(mapfiles{i});
    ni.data = squeeze(ni.data);
    vol{i} = ni.data(:,:,:,vi(i)).*mask.data; % pull out vol of interest & mask it
    
end

% if doing controls vs patients comparison, flip the afni vol (which was
% patients vs controls)
if vi(1)==2
    vol{1} = vol{1}.*-1;
end

%% compare non-zero voxels

idx = find(vol{1}); % index for non-zero voxels

% plot index
pi = [1 2;
    1 3;
    2 3];
    
figure = setupFig;

% determine axis limits
maxval = max(cell2mat(cellfun(@(x) max(abs(x(:))), vol,'uniformoutput',0)));
axl =[-maxval maxval];

for j=1:size(pi,1)
subplot(1,size(pi,1),j)
plot(vol{pi(j,1)}(idx),vol{pi(j,2)}(idx),'.')
xlabel(mapnames(pi(j,1)))
ylabel(mapnames(pi(j,2)))
xlim(axl)
ylim(axl)
end


% afni and matlab methods produce the similar results for the majority of the
% voxels, but they treat fringe cases w/high z values differently...

% what 


%% conclusion: just use the afni method for converting t-scores to z-scores...









%% compare Z and t values at a given voxel coord on finished Z map niftis vs 
% calculating Z and t stats manually on the fly 


clear all
close all

cd /Users/kelly/cueexp/data/FC_temp

[subjects,gi]=getCueSubjects('cue');
groups = {'controls','patients'}; % order corresponding to gi=0, gi=1

mask=niftiRead('../templates/bmask.nii');
dim=mask.dim;


%%%%%% Z map:
ni = niftiRead('ZrestB_ventralcaud.nii.gz');
ni.data = ni.data.*mask.data;

Zvols=ni.data;


%%%%%%% B maps:
load('restB.mat')

% make sure single subject b vols are masked out
Bvols = reshape(Z{1}',dim(1),dim(2),dim(3),[]);
Bvols=Bvols.*mask.data;
Z{1} = reshape(Bvols,prod(dim(1:3)),[])';


%% get values at a single voxel 

% xyz=[20 4 -30]; 
 xyz=[12 4 10];  % striatal voxel 
% xyz=[8 4 55];  

ijk=round(mrAnatXformCoords(ni.qto_ijk,xyz))

voxZ=squeeze(Zvols(ijk(1),ijk(2),ijk(3),:));

voxB = squeeze(Bvols(ijk(1),ijk(2),ijk(3),:));


%% now manually calculate Z and t vals on the fly from b maps:

[~,p(1),~,stats]=ttest(voxB(gi==0))
t(1)=stats.tstat;
df(1)=stats.df

[~,p(2,1),~,stats]=ttest(voxB(gi==1))
t(2,1)=stats.tstat;
df(2,1)=stats.df

[~,p(3,1),~,stats]=ttest2(voxB(gi==0),voxB(gi==1));
t(3,1)=stats.tstat;
df(3,1)=stats.df


%% now compare Z map to Z values computed on the fly: 

t2z(t,df)
voxZ

%% now compare t values calculated on the fly vs with glm_fmri_ttest3d:

out=glm_fmri_ttest3d(Z{1}(gi==0,:),Z{1}(gi==1,:),groups,mask,'','t');
squeeze(out.data(ijk(1),ijk(2),ijk(3),:));


%% so it looks like: 

% - everything is good with stats that are within a "normal" range (e.g.,
% abs(z)<8 or so),

% but when z vals are greater than that, though the t values are ok, the t
% > z values conversion gets weird...

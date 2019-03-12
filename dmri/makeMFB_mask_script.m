clear all
close all


cd /Users/kelly/cueexp/data/ROIs
da=niftiRead('DA.nii');
nacc=niftiRead('nacc_desai.nii');
[di dj dk]=ind2sub(size(da.data),find(da.data));
[ni nj nk]=ind2sub(size(nacc.data),find(nacc.data));
dacoords=mrAnatXformCoords(da.qto_xyz,[di dj dk]);
nacccoords=mrAnatXformCoords(nacc.qto_xyz,[ni nj nk]);

cd /Users/kelly/cueexp/data/fgMeasures/voxelwise_tlrc


ni=niftiRead('all_md_controls.nii.gz');

mask=niftiRead('MFB_mask_.5thresh.nii.gz');
% mask=niftiRead('MFBR_mask_.5thresh.nii.gz');

%% 

[min(dacoords(:,2)) max(dacoords(:,2))]
[min(nacccoords(:,2)) max(nacccoords(:,2))]

mask.data(da.data==1)=0;
mask.data(nacc.data==1)=0;

% get middle 50% of mask
idx=find(mask.data);
[i j k]=ind2sub(size(mask.data),idx);
coords=mrAnatXformCoords(mask.qto_xyz,[i j k]);
[min(coords(:,2)) max(coords(:,2))]

ythresh=[-11 -5];

omit_idx=find(coords(:,2)<ythresh(1));
omit_idx=[omit_idx;find(coords(:,2)>ythresh(2))]
% omit_idx=find(j<=min(j)+round(range(j)./4));
% omit_idx=[omit_idx;find(j>=max(j)-round(range(j)./4))];
idx(omit_idx)=[];
[i j k]=ind2sub(size(mask.data),idx); % to check out new mask vals
mask.data=zeros(size(mask.data));
mask.data(idx)=1;


subjects= getCueSubjects('dti',0);
bis=getCueData(subjects,'bis')

for s=1:numel(subjects)
    
    thismd=double(ni.data(:,:,:,s)).*mask.data;
    md(s,1)=mean(thismd(idx));
    
end


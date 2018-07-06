% calculate ROI coords


cd /Users/kelly/cueexp/data/ROIs

roi=niftiRead('VTA_func.nii');


[i j k]=ind2sub(size(roi.data),find(roi.data));

xyz=mrAnatXformCoords(roi.qto_xyz,[i j k]);

fprintf('# of voxels in mask: %d\n',numel(i));


x=xyz(:,1);

fprintf('mean X coords left, rounded: %d\n',round(mean(x(x>=0))));
fprintf('mean X coords right, rounded: %d\n',round(mean(x(x<0))));

fprintf('mean Y coord, rounded: %d\n',round(mean(xyz(:,2))));
fprintf('mean Z coord, rounded: %d\n',round(mean(xyz(:,3))));


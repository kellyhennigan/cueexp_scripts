% make habenula ROI sphere

clear all

cd /Users/kelly/cueexp/data/ROIs

roiL = niftiRead('PVTL.nii.gz')
roiR = niftiRead('PVTR.nii.gz')


subjects = getSASubjects('fmri')
N=length(subjects);
roiStr = 'lhabenula';

r = 4; % radius of roi sphere


for s=1:length(subjects)
        
    subject=subjects{s};
    
    expPaths = getSAPaths(subject);
    cd(expPaths.subj);
    % t1 = readFileNifti('t1.nii');
    cd ROIs
    roi = readFileNifti([roiStr,'.nii']);
    idx=find(roi.data);
    [i j k]=ind2sub(roi.dim,idx);
    ci = round(mean(i));
    cj = round(mean(j));
    ck = round(mean(k));
    roiSphere=dtiNewRoi([roiStr,'_',num2str(r),'mm_sphere'],'r',dtiBuildSphereCoords([ci cj ck],r));
    roiSphereNii = roi;
    roiSphereNii.fname = [roiSphere.name,'.nii'];
    idx=sub2ind(size(roiSphereNii.data),roiSphere.coords(:,1),roiSphere.coords(:,2),roiSphere.coords(:,3));
    roiSphereNii.data(idx)=1;
    writeFileNifti(roiSphereNii);
      
end



#! /bin/csh

setenv PATH $PATH\:/Users/Kelly/repos/antsbin/bin/

cd /Users/Kelly/cueexp/data/coreg_test/ants_just_norm


#foreach subject ( aa151010 as160129 bp160213 nb160221 ps151001 tf151127 tm160117 wh160130 zl150930)

foreach subject ( nb ps tf tm wh zl)

	echo "working on subject " $subject

####### skull strip: 

	# afni: 
	#3dAutomask -apply_prefix ${subject}_refvol_ns ${subject}_ref_vol.nii
	#3dSkullStrip -prefix ${subject}_t1_ns -input ${subject}_t1_raw.nii
	
	# fsl: 
	#bet ${subject}_ref_vol.nii ${subject}_refvol_ns
	#bet ${subject}_t1_raw.nii ${subject}_t1_ns
	

####### coreg and normalization: 

	# AFNI: t1 > tlrc; func > t1; func > tlrc 
	
	# @auto_tlrc -no_ss -base ../TT_N27.nii -input ${subject}_t1.nii
	# mv ${subject}_t1_at.Xat.1D ${subject}_t12tlrc_xform
	# mv ${subject}_t1_at.nii_WarpDrive.log ${subject}_t12tlrc_log
	# rm ${subject}_t1_at.nii.Xaff12.1D
	
	# align_epi_anat.py -anat ${subject}_t1.nii -epi ${subject}_refvol.nii -epi_base 0 -tlrc_apar ${subject}_t1_at.nii -epi_strip None -anat_has_skull no -tshift off -volreg off -rigid_body -epi2anat
	# mv ${subject}_t1_al_mat.aff12.1D ${subject}_t12func_xform
	# mv ${subject}_refvol_al_mat.aff12.1D ${subject}_func2t1_xform
	# mv ${subject}_refvol_al_tlrc_mat.aff12.1D ${subject}_func2tlrc_xform


	# AFNI: t1 > tlrc; func > tlrc (no coregistration)
	
	# t1 > tlrc
	# @auto_tlrc -no_ss -base ../TT_N27.nii -input ${subject}_t1.nii
	# mv ${subject}_t1_at.Xat.1D ${subject}_t12tlrc_xform
	# mv ${subject}_t1_at.nii_WarpDrive.log ${subject}_t12tlrc_log
	# rm ${subject}_t1_at.nii.Xaff12.1D
	
	# func > tlrc
	#@auto_tlrc -apar ${subject}_t1_at.nii -input ${subject}_refvol.nii -dxyz 2.9


	# FSL: t1 > func (rigid-body); t1 > tlrc (affine); func > tlrc

	# t1 > func
	#/usr/local/fsl/bin/flirt -in ${subject}_t1.nii -ref ${subject}_refvol.nii -out ${subject}_t1_al.nii -omat ${subject}_t12func.mat -bins 256 -cost corratio -dof 6 -interp trilinear

	# t1 > tlrc
	#/usr/local/fsl/bin/flirt -in  ${subject}_t1.nii -ref ../TT_N27.nii -out ${subject}_t1_tlrc.nii -omat ${subject}_t12tlrc.mat -bins 256 -cost corratio -dof 12 -interp trilinear
	
	# get inverse of t1 > func xform 
	#convert_xfm -omat ${subject}_func2t1.mat -inverse ${subject}_t12func.mat

	# combine func > t1 and t1 > tlrc xforms
	#convert_xfm -omat ${subject}_func2tlrc.mat -concat ${subject}_t12tlrc.mat ${subject}_func2t1.mat

	# apply func > tlrc xform on functional data 
	#flirt -ref ../TT_N27_func_dim.nii -in ${subject}_refvol.nii -applyxfm -init ${subject}_func2tlrc.mat -out ${subject}_refvol_tlrc
	

	# FSL: t1 > tlrc; func > tlrc (no coregistration)

	# t1 > tlrc
	#/usr/local/fsl/bin/flirt -in  ${subject}_t1.nii -ref ../TT_N27.nii -out ${subject}_t1_tlrc.nii -omat ${subject}_t12tlrc.mat -bins 256 -cost corratio -dof 12 -interp trilinear
	
	# apply func > tlrc xform on functional data 
	#flirt -ref ../TT_N27_func_dim.nii -in ${subject}_refvol.nii -applyxfm -init ${subject}_t12tlrc_xform -out ${subject}_refvol_tlrc
	

	############### bbregister and ants: 
	#bbregister --s tm160117 --mov ref_vol.nii --bold --reg func2anat.dat --init-fsl --o ref_vol_al_bbreg.nii

	# mri_convert orig.mgz freesurfer file to nifti and move it to working directory
	# mri_convert --out_orientation RAS orig.mgz zl_t1_fs.nii
	# 3dSkullStrip -prefix ${subject}_t1_fs_ns -input ${subject}_t1_fs.nii 
	# 3dAFNItoNIFTI ${subject}_t1_fs_ns+orig
	# mv ${subject}_t1_fs_ns.nii ${subject}_t1.nii

	# ants normalization command
	# useful walk through of ants commands here: 
	# explains http://polaris.ssc.uwo.ca/mediawiki/index.php/Spatial_warping_with_ANTs#Applying_the_Inverse_Warp
	
	# compute warp field
	#/Users/Kelly/repos/antsbin/bin/ANTS 3 -m CC[/Users/Kelly/cueexp/data/coreg_test/TT_N27.nii,${subject}_t1.nii,1,4] -r Gauss[3,0] -o ${subject}_2tlrc -i 100x50x30x10 -t SyN[.25]
	# 'CC' for cross-correlaton metric


	# t1 > func
	
	# apply warp field to t1
	# /Users/Kelly/repos/antsbin/bin/WarpImageMultiTransform 3 ${subject}_t1.nii \
	# ${subject}_t1_tlrc.nii.gz \
	# ${subject}_2tlrcWarp.nii.gz \
	# ${subject}_2tlrcAffine.txt

	# # # resample functional data to have 1x1x1 mm voxels
	# # /Users/Kelly/repos/antsbin/bin/ResampleImageBySpacing 3 \
 # # 	${subject}_refvol.nii \
 # # 	${subject}_refvol_resamp.nii 1 1 1 

	# # apply warp field to func data
	# /Users/Kelly/repos/antsbin/bin/WarpImageMultiTransform 3 ${subject}_refvol.nii \
	# ${subject}_refvol_tlrc.nii.gz \
	# -R ../TT_N27_func_dim.nii ${subject}_2tlrcWarp.nii.gz \
	# ${subject}_2tlrcAffine.txt


# /Users/Kelly/repos/antsbin/bin/ResampleImageBySpacing 3 \
 # 	${subject}_refvol.nii \
 # 	${subject}_refvol_resamp.nii 1 1 1 

	echo "Done."

end


	
	# commands to get the inverse transform: 

	# fsl func > t1
	# /usr/local/fsl/bin/flirt -in ${subject}_refvol_ns.nii -ref ${subject}_t1_ns.nii -out ${subject}_refvol_ns_al.nii -omat ${subject}_func2t1.mat -bins 256 -cost corratio -dof 6 -interp trilinear

# cat_matvec aa_refvol_ns_al_mat.aff12.1D -I # afni
	 #convert_xfm -omat ${subject}_func2t1.mat -inverse ${subject}_t12func.mat # fsl





	

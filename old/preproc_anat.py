#!/usr/bin/python

# filename: preproc_anat.py
# script to do the following with anatomical data: 

# skull-strip
# estimate xform to tlrc space
# apply xform 

# if you want to run, say, only motion correction on data that's already been 
# processed up to slice time correction, set the earlier step to 0 and define:
	#  inStr = 'a'+inStr 
# on the line above 'if doCorrectionMotion:' in the main function 	

#### TO DO: 
# add error checks to see if files actually exist
# change hard-coded 2.9 voxel size when normalizing functional data to find 
# 	that info in the file header
# add fieldmap undistortion step
# ideally, do slice time & motion correction & undistortion resampling in 1 interpolated step
# find a way to save out evidence from each step on how well it did (e.g., like
# 	how it currently saves out a png file showing head movement estimation)

# for Claudia's data, maybe add deoblique step: 
# 3dwarp -overwrite -deoblique -prefix cue_epid cue_epi+orig


import os,sys,glob


##################### define global variables #################################
# EDIT AS NEEDED:


# data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
data_dir = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data')


subjects = ['187']

 
inDir = 'raw' # name of directory containing raw data, relative to subject dir
outDir = 'func_proc'

templateFilePath = os.path.join(data_dir,'templates','TT_N27.nii')

justPrint = 0 # if true, commands will just be printed to screen but not executed


# add ants directory to path
os.system('export PATH=$PATH:'+os.path.join(os.path.expanduser('~')+'/repos/antsbin/bin'))


for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject+'\n'
	
		
	# define subject's raw & pre-processed directories 
	this_inDir = os.path.join(data_dir,subject,inDir)
	this_outDir =  os.path.join(data_dir,subject,outDir)
	
	# make out directory if doesn't already exist 
	if not os.path.exists(this_outDir):
		os.makedirs(this_outDir)

	# cd to subject's outDir
	os.chdir(this_outDir)				
	
	
	# skull-strip anatomy 
	cmd = '3dSkullStrip -prefix t1_ns -input '+os.path.join(this_inDir,'t1_raw.nii.gz')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	###### ANTS NORMALIZATION:
	# convert to nifti 
	cmd = '3dAFNItoNIFTI t1_ns+orig; rm t1_ns+orig*'
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	# if coregistering to functional data, do that here
	
	# estimate transform to tlrc template
	cmd = 'ANTS 3 -m CC['+templateFilePath+',t1_ns.nii,1,4] -r Gauss[3,0] -o t12tlrc -i 100x50x30x10 -t SyN[.25]'
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	# apply transform to put t1 in tlrc space
	cmd = 'WarpImageMultiTransform 3 t1_ns.nii t1_tlrc.nii.gz t12tlrcWarp.nii.gz t12tlrcAffine.txt'
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	# change header to place nice with afni
	cmd = '3drefit -view tlrc -space tlrc t1_tlrc.nii.gz'
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)


	######## AFNI NORMALIZATION:
	cmd = '@auto_tlrc -no_ss -base '+templateFilePath+' -suffix _afni -input t1_ns.nii'
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	
	cmd = 'mv t1_ns_afni.nii t1_tlrc_afni.nii; mv t1_ns_afni.Xat.1D t12tlrc_afni_xform; mv t1_ns_afni.nii_WarpDrive.log t12tlrc_afni.log; rm t1_ns_afni.nii.Xaff12.1D'
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	
	print 'FINISHED SUBJECT '+subject













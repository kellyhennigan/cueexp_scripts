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


data_dir = os.path.join(os.path.expanduser('~'),'%s','data')

in_dir = os.path.join(data_dir,'%s','raw')  # first %s is data_dir & 2nd is subject id

out_dir = os.path.join(data_dir,'%s','func_proc')

templateFilePath = os.path.join(data_dir,'templates','TT_N27.nii') # %s is data_dir

justPrint = 1 # if true, commands will just be printed to screen but not executed


# add ants directory to path
os.system('export PATH=$PATH:'+os.path.join(os.path.expanduser('~')+'/repos/antsbin/bin'))


###############################################################################
############################### DO IT #########################################
###############################################################################

#########  get subjects to process	
def whichBaseDir():
	
	base_dirs = ['','cueexp','cueexp_claudia']
	print 'Which project directory?\n'
	print '\t1) '+base_dirs[1]
	print '\t2) '+base_dirs[2]+'\n'
	i = input('enter 1 or 2: ') # get directory index

	return base_dirs[i]
	

#########  get main data directory and subjects to process	
def whichSubs(base_dir='cueexp'):

	
	if base_dir=='cueexp':
		from getCueSubjects import getsubs 
		subjects,gi = getsubs()
	elif base_dir=='cueexp_claudia':
		from getCueSubjects import getsubs_claudia
		subjects,gi = getsubs_claudia()

	print ' '.join(subjects)

	input_subs = raw_input('subject id(s) (hit enter to process all subs): ')
	print '\nyou entered: '+input_subs+'\n'

	if input_subs:
		subjects=input_subs.split(' ')

	return subjects
	



	
#########  convert file from afni to nifti format & delete afni file
def convertToNifti(inFile,out_str=''):

	# use inFile's prefix as out_str by default, + '_tlrc' if in tlrc space
	if not out_str:
		a=inFile.split('+') # split inFile to get fname & space string
		out_str = a[0] # use inFile's prefix for out file name
		if a[1][0:4]=='tlrc' and a[0].find('tlrc')==-1:
			out_str = out_str+'_tlrc'
	
	outFile = out_str+'.nii.gz'

	cmd = ('3dAFNItoNIFTI -prefix '+outFile+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	# delete inFile in afni format
	cmd = ('rm '+inFile+'*')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)


	return outFile



if __name__ == '__main__':

	base_dir = whichBaseDir()

	subjects = whichSubs(base_dir)

	for subject in subjects:

		
		print 'WORKING ON SUBJECT '+subject+'\n'
		
			
		# define subject's raw & pre-processed directories 
		this_inDir = in_dir % (base_dir,subject)
		this_outDir =  out_dir % (base_dir,subject)
		
		# make out directory if doesn't already exist 
		if not justPrint:
			if not os.path.exists(this_outDir):
				os.makedirs(this_outDir)

		# cd to subject's outDir
		if not justPrint:
			os.chdir(this_outDir)				

		
		# skull-strip anatomy 
		cmd = '3dSkullStrip -prefix t1_ns -input '+os.path.join(this_inDir,'t1_raw.nii.gz')
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
		
		
		# convert to nifti 
		cmd = '3dAFNItoNIFTI -prefix t1_ns.nii.gz t1_ns+orig; rm t1_ns+orig*'
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)

		
		######## ANTS NORMALIZATION:
		# estimate transform to tlrc template using ANTS
		cmd = 'ANTS 3 -m CC['+templateFilePath % (base_dir)+',t1_ns.nii.gz,1,4] -r Gauss[3,0] -o t12tlrc -i 100x50x30x10 -t SyN[.25]'
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)

		# apply transform to put t1 in tlrc space
		cmd = 'WarpImageMultiTransform 3 t1_ns.nii.gz t1_tlrc.nii.gz t12tlrcWarp.nii.gz t12tlrcAffine.txt'
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)

		# change header to play nice with afni
		cmd = '3drefit -view tlrc -space tlrc t1_tlrc.nii.gz'
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)


		######## AFNI NORMALIZATION:
		cmd = '@auto_tlrc -no_ss -base '+templateFilePath % (base_dir)+' -suffix _afni -input t1_ns.nii.gz'
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
		
		
		cmd = 'mv t1_ns_afni.nii t1_tlrc_afni.nii; mv t1_ns_afni.Xat.1D t12tlrc_afni_xform; mv t1_ns_afni.nii_WarpDrive.log t12tlrc_afni.log; rm t1_ns_afni.nii.Xaff12.1D'
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
		
		
		print 'FINISHED SUBJECT '+subject












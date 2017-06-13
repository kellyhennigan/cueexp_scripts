#!/usr/bin/python


# at this point, func data should be pre-processed but still in native space. 

# during preprocessing, a reference volume nifti file should have been made 
# for each of the 3 tasks: cue, mid, and midi. This script assumes that the 
# task performed closest to t1 acquisition is in the best alignment with 
# t1 anatomy, and estimates a rigid-body transform from the other ref vols to 
# the one closest to t1 alignment, which will be applied when normalizing to 
# tlrc space. 

# this script does the following: 

# coregisters functional reference volumes to the ref volume that was acquired 
# just after t1 scan was acquired using a rigid body xform, 

# transforms func data from native to group space using the following xforms:
 # 1) rigid-body xform to func ref volume acquired closest to t1 scan (if applicable), 
 # 2) affine t1 native space to tlrc space, 
 # 3) non-linear warp field to tlrc space

# saves out wm and csf time series to be used as nuisance regressors 

import os,sys,glob


##################### define global variables #################################
# EDIT AS NEEDED:

data_dir = os.path.join(os.path.expanduser('~'),'%s','data')  # %s is base_dir

in_dir = os.path.join(data_dir,'%s','func_proc') # %s' are data_dir and subject 

#justPrint = 1 # if true, commands will just be printed but not executed 
print 'just print commands?' 
justPrint = input('enter 1 for yes, or 0 to print & execute: ')


refStr = 'ref_%s_ns.nii.gz' # may need refStr for coreg ref file, too
funcStr = 'pp_%s.nii.gz'	# pre-processed data where %s is task

# this is the task performed closest to t1 acquisition; assumed to have best 
# coregistration to t1 anatomy
# coreg_refvol = 'mid'

# xf1 is a rigid body xform to the task ref vol acquired closest to t1 scan 
xf2 = 't12tlrcAffine.txt' # affine xform from t1 native space to tlrc template
xf3 = 't12tlrcWarp.nii.gz' # non-linear warp from t1 native space to tlrc

vox_dim = 2.9 	# voxel dimensions and template for group space

# file path to template for group space func data (uses vox dim, fov, etc.)
templateFilePath = os.path.join(os.path.expanduser('~'),'cueexp','data','templates','TT_N27_func_dim.nii')

# filepaths for white matter and CSF ROI masks
roiPath = os.path.join(data_dir,'ROIs','%s_func.nii')
roiNames = ['csf','wm','nacc','ins']




###############################################################################
############################### DO IT #########################################
###############################################################################
###### HOPEFULLY DON T HAVE TO EDIT BELOW HERE. OR THATS THE PLAN ANYWAY. #####
###############################################################################
	

#########  get base directory 
def whichBaseDir():
	
	base_dirs = ['','cueexp','cueexp_claudia']
	print 'Which project directory? FOR NOW, DONT USE THIS SCRIPT FOR CLAUDIAS DATA\n'
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
	


#########  coregister one func ref volume to another using a rigid body xform
def coregRBAnts(movingFile,fixedFile,xfStr):

	# add ants directory to path
	cmd = ('export PATH=$PATH:'+os.path.join(os.path.expanduser('~')+
	'/repos/antsbin/bin'))
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	# estimate rigid-body xform from moving file to fixed file
	cmd = ('ANTS 3 -m MI['+fixedFile+','+movingFile+',1,32] -o '+xfStr+
	' -i 0 --rigid-affine true')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	xfName = xfStr+'Affine.txt' # ants appends 'Affine.txt to xform string
	return xfName



#########  normalize functional data
def normalizeAfniFunc(inFile):
	
	inStr,_ = os.path.splitext(inFile)
	inStr,_ = os.path.splitext(inStr)
	outStr = inStr+'_afni_tlrc'			# out file string

	#print 'outStr: '+outStr
	cmd = ('adwarp -apar t1_tlrc_afni.nii -dpar '+inFile+' '
	'-prefix '+outStr+' -dxyz '+str(vox_dim))
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	outFile = convertToNifti(outStr+'+tlrc')

	########## remove intermediary steps
	#cmd = ('rm '+outStr+'+tlrc*')
	#print cmd+'\n'
	#if not justPrint:
	#	os.system(cmd)

	return outFile



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



#########  normalize functional data
def normalizeANTSFunc(inFile,xf1='',xf2='',xf3=''):

	inStr,_ = os.path.splitext(inFile)
	inStr,_ = os.path.splitext(inStr)
	outFile = inStr+'_tlrc.nii.gz'

	# add ants directory to path
	cmd = ('export PATH=$PATH:'+os.path.join(os.path.expanduser('~')+'/repos/antsbin/bin'))
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	# apply ANTs xform to functional data	
	cmd =('antsApplyTransforms -d 3 -e 3 -i '+inFile+' -r '+templateFilePath+
	' -o '+outFile+' --float -t '+xf1+' '+xf2+' '+xf3) 
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	cmd = ('3drefit -space tlrc -view tlrc '+outFile)
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	return outFile	



#########  extract average time series of white matter & csf masks 
def extractRoiTS(inFile,roiFilePath,outTsName):

	# uses global variables csfFilePath & wmFilePath & baseStr
	
	cmd = ('3dmaskave -mask '+roiFilePath+' -quiet -mrange 1 2 '+inFile+
	' > '+outTsName)
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	


###########################  MAIN FUNCTION ###########################

if __name__ == '__main__':

	base_dir = whichBaseDir()

	subjects = whichSubs(base_dir)

	print 'which task to process?'
	task=raw_input('enter cue, mid, or midi: ')

	funcFile = funcStr % (task)  # task ref volume
	refFile = refStr % (task)  # task ref volume

	for subject in subjects:
	
		print '\nPROCESSING SUBJECT: '+subject+'\n'	
		
		# cd to subject specific data dir
		if not justPrint:
	 		os.chdir(in_dir % (base_dir,subject))


		# do functional coregistration if desired
		xf1 = ''
		doCoreg = raw_input('coregister functional data? (y or n) ')
		if doCoreg=='y':
			coreg_ref = raw_input('\nwhich task to use as functional reference for coreg? (cue, mid, or midi):')
			print '\ncoregistering functional data using task '+coreg_ref+' as reference\n'
			if task!=coreg_ref:
				xf1 = coregRBAnts(refFile,refStr % (coreg_refvol),
 				task+'2bestRef')
		else: 
			print 'skipping coregistration...'


		############# transform to group space using ANTS non-linear xform
 		normalizeANTSFunc(refFile,xf1,xf2,xf3)
 		tlrcFile = normalizeANTSFunc(funcFile,xf1,xf2,xf3)


 		##### save out roi time series 
 		for r in roiNames:
 			this_roiPath = roiPath % (base_dir,r)
 			outTsName = task+'_'+r+'.1D'
			extractRoiTS(tlrcFile,this_roiPath,outTsName)


		############# transform to group space using AFNI affine xform 
 		normalizeAfniFunc(refFile)
 		afni_tlrcFile = normalizeAfniFunc(funcFile)


		##### save out roi time series 
		for r in roiNames:
 			this_roiPath = roiPath % (base_dir,r)
 			outTsName = task+'_'+r+'_afni.1D'
			extractRoiTS(afni_tlrcFile,this_roiPath,outTsName)


		print '\n\nDONE WITH '+task+' TASK DATA, SAVED OUT AS '+tlrcFile+'\n\n'


		print 'FINISHED SUBJECT '+subject
		







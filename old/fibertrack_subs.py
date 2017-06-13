#!/usr/bin/python

# filename: fibertrack_subs.py
# this script loops over subjects to perform fiber tracking using the mrtrix command tckgen

# see here for more info on tckgen: https://github.com/jdtournier/mrtrix3/wiki/tckgen


import os,sys

dataDir = '/Users/Kelly/cueexp/data'		# experiment main data directory

# subjects = ['9','10','11','12','13','15','16','17','18','19','20','21',
# 	'23','24','25','28','29','30']  # subjects to process
subjects = ['jh160702']

##########################################################################################
# EDIT AS NEEDED:



# define input directory and files relative to subject's directory 
inDir = 'dti96trilin/bin'			# directory w/in diffusion data and b-gradient file and mask
infile = 'CSD8.mif'					# tensor or CSD file 
alg = 'iFOD2'						# will do iFOD2 by default
gradfile = 'b_file' 				# b-gradient encoding file in mrtrix format
#maskfile = 'brainMask.nii.gz' 		# this should be included
maskfile = 'wmMask_fs.nii.gz' 		# this should be included

# define ROIs 
roiDir = 'ROIs' 					# directory w/ROI files
seedStr = 'DAR'						# if false, will use the mask as seed ROI by default
# roi2Strs = ['naccR_dilated','caudateR','putamenR']		# can be many or none; if not defined, fibers will just be tracked from the seed ROI
roi2Strs = ['naccR']		# can be many or none; if not defined, fibers will just be tracked from the seed ROI
excPath = ''
#excPath = '/Users/Kelly/dti/data/AC_coronal_wall.nii.gz'


# fiber tracking options; leave blank or comment out to use defaults:
number = '1000'						# number of tracks to produce
maxnum = str(int(number)*1000)		# max number of candidate fibers to generate (default is number x 100)
maxlength = ''						# max length (in mm) of the tracks
stop = True							# stop track once it has traversed all include ROIs
step_size = ''						# define step size for tracking alg (in mm); default is .1* voxel size
cutoff = ''							# determine FA cutoff value for terminating tracks (default is .1)
initdir = '0,1,0.5' 		        # vector specifying the initial direction to track fibers from seed to target

# define directory for resulting fiber files (relative subject's directory)
outDir = 'fibers/mrtrix'			# directory for saving out fiber file


##########################################################################################
# DO IT 
	
	
# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	if not os.path.exists(outDir):
		os.makedirs(outDir)
 		
	for roi in roi2Strs:
		
		
		outfile = roi+'_wmmask.tck' 			 # name out file based on roi string

	
		cmd = 'tckgen'
		if alg:
			cmd = cmd+' -algorithm '+alg
		if gradfile: 
			cmd = cmd+' -grad '+os.path.join(inDir,gradfile)
		if maskfile: 
			cmd = cmd+' -mask '+os.path.join(inDir,maskfile)
		if seedStr:
			cmd = cmd+' -seed_image '+os.path.join(roiDir,seedStr+'.nii.gz')
		if roi:
			cmd = cmd+' -include '+os.path.join(roiDir,roi+'.nii.gz')
		if excPath:
			cmd = cmd+' -exclude '+excPath
		if number:
			cmd = cmd+' -number '+str(number)
		if maxnum:
			cmd = cmd+' -maxnum '+str(maxnum)
		if maxlength:
			cmd = cmd+' -maxlength '+str(maxlength)
		if stop:
			cmd = cmd+' -stop'
		if step_size:
			cmd = cmd+' -step '+str(step_size)
		if cutoff:
			cmd = cmd+' -cutoff '+str(cutoff)
		if initdir:
			cmd = cmd+' -initdirection '+str(initdir)
	
		cmd = cmd+' -info '+os.path.join(inDir,infile)+' '+os.path.join(outDir,outfile)
		print cmd
		os.system(cmd)		

		
	print 'FINISHED SUBJECT '+subject
			





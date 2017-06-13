#!/usr/bin/python

# filename: preproc_midi.py
# script to do pre-processing of functional data. Does the following: 

# 1) drops first X volumes from each scan run
# 2) slice time correction
# 3) pulls out a functional reference volume from the 1st run for each task 
# 4) motion correction
# 5) smooths data
# 6) converts to % change units
# 6) applies a high-pass filter 


import os,sys,glob


##################### define global variables #################################
# EDIT AS NEEDED:

data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
from getCueSubjects import getsubs 
subjects = ['rt160420']

# tasks = ['cue','mid','midi'] 
tasks = ['mid','midi'] 

# runs = [[1],[1,2],[1,2]] # # of runs corresponding to each task 
runs = [[1,2],[1,2]] # # of runs corresponding to each task 
rawDir = 'raw' # name of directory containing raw data, relative to subject dir

rawFileStr = '%s%d.nii.gz'	# raw file names, %s is task and %d is run #

ppDir = 'func_proc'  # name of directory for pre-processed data, " " 

justPrint = 0 # if true, commands will just be printed but not executed 


############### define relevant variables for each pre-processing step as needed

# how many volumes to drop from the beginning of each scan? 
omitNVols = 6 


# if using a fieldmap, specify filepath
fmapFilePath = ''


# slice timing correction parameter string
st_param_str = '-slice 0 -tpattern altplus'  


# which volume to use from 1st func run as a reference volume? 
refvol_str = 'refvol_%s'  # reference volume file name; %s is task
refvol_idx = 4	 
	
	
# motion correction parameter string
mc_param_str = '-Fourier -twopass -zpad 4'  # mc params
censor_lim = 0.5  # euclidian norm limit for censoring vols due to motion


# fwhm gaussian kernel to use for smoothing (in mm)
smooth_mm = 4 		


# high-pass filter cutoff (.011 hz ~= 1 cycle/90 sec)
hz_limit = .011		



###############################################################################
############################### DO IT #########################################
###############################################################################
###### HOPEFULLY DON T HAVE TO EDIT BELOW HERE. OR THATS THE PLAN ANYWAY. #####
###############################################################################




#########  raw to afni format, omit first TRs if desired
def rawToAfni(inFilePath,outStr):
	
	inFile = os.path.basename(inFilePath)
	outFile = outStr+'+orig'
		
	# convert nifti file to afni format, omitting first TRs (if desired)
	cmd = ('3dTcat -prefix '+outStr+' '+inFilePath+'['+str(int(omitNVols))+'..$]')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	return outFile



#########  slice time correct  
def correctSliceTiming(inFile):
	
	# uses global variable st_param_str	
	outFile = 't'+inFile
		
	cmd = ('3dTshift -prefix '+outFile[0:outFile.find('+')]+' '
	+st_param_str+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
		
	return outFile
	
		
#########  make functional reference volume 
def makeRefVol(inFile):

	
	this_refvol_str = refvol_str % (task) # define refvol string for this task 
	refFile = this_refvol_str+'.nii' # name of refvol nifti file for this task

	# check if task refvol already exists 
	filelist = glob.glob(refFile)  # list of files w/ ref_vol_str
		
	if not filelist: 
			
		# create separate ref vol file using volume refvol_idx
		cmd =('3dTcat -prefix '+this_refvol_str+' '
		+inFile+'['+str(refvol_idx)+']')
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)

		# convert to nifti 
		cmd =('3dAFNItoNIFTI '+this_refvol_str+'+orig; '
		'rm '+this_refvol_str+'+orig*')
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)


	return refFile
	

#########  motion correct  
def correctMotion(inFile,r,refFile):

	# uses global variable mc_param_str and censor_lim
	
	outFile = 'm'+inFile
	mc_str = task+str(r)+'_vr'
	
	# motion correct 
	cmd = ('3dvolreg '+mc_param_str+' -dfile '+mc_str+'.1D -base '+refFile+' '
	'-prefix '+outFile[0:outFile.find('+')]+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
						
	# make motion_censor file to feed 3dDeconvolve to censor vols w/motion
	cmd = ('1d_tool.py -infile '+mc_str+'.1D[1..6] -show_censor_count '
	'-censor_prev_TR -censor_motion '+str(censor_lim)+' '+task+str(r))
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	# make a list that contains all motion-correction related generated files
	mc_files = [mc_str+'.1D',task+str(r)+'_censor.1D',task+str(r)+'_enorm.1D']
	return (outFile, mc_files)



#########  smooth
def smooth(inFile):
		
	# uses global variable smooth_mm
		
	outFile = 's'+inFile
	
	cmd = ('3dmerge -1blur_fwhm '+str(smooth_mm)+' -doall -quiet '
	'-prefix '+outFile[0:outFile.find('+')]+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
		
	return outFile



#########  convert BOLD data to units of % signal change 
def convertUnits(inFile):

	outFile = 'p'+inFile
	tempFile = 'mean_'+inFile
	
	cmd = ('3dTstat -mean -prefix '+tempFile[0:tempFile.find('+')]+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	cmd = ('3dcalc -a '+inFile+' -b '+tempFile+" -expr '((a-b)/b)*100' "
	'-prefix '+outFile[0:outFile.find('+')]+' -datum float; rm '+tempFile+'*')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
		
	return outFile	



#########  high-pass filter 
def hpFilter(inFile):
	
	# uses global variable hz_limit
	
	outFile = 'f'+inFile
	
	cmd = ('3dFourier -highpass '+str(hz_limit)+' '
	'-prefix '+outFile[0:outFile.find('+')]+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
		
	return outFile	


	
#########  convert pre-processed files to nifti & concat if >1 run
def convertToNifti(inFiles,outFile_str):

	cmd = ('3dTcat -prefix '+outFile_str+' '+' '.join(inFiles))
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	cmd = ('3dAFNItoNIFTI '+outFile_str+'+orig')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	return outFile_str+'.nii'



#########  concatenate motion files across runs - this is very specific!!
def concatRunMCFiles(mcFiles):

	########## create master motion regs file for all runs 
		cmd = ('cat '+mcFiles[0]+' >> '+task+'_vr.1D; rm '+mcFiles[0])
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
		
		########## create master motion censor file for all runs 
		cmd = ('cat '+mcFiles[1]+' >> '+task+'_censor.1D; rm '+mcFiles[1])
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
		
		########## create master motion enorm file for all runs 
		cmd = ('cat '+mcFiles[2]+' >> '+task+'_enorm.1D; rm '+mcFiles[2])
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
	


###########################  MAIN PREPROC FUNCTION ############################

if __name__ == '__main__':
    
	
	# now loop through subjects, clusters and bricks to get data
	for subject in subjects:
	
		print '\nWORKING ON SUBJECT '+subject+'\n'
	
		# define subject's raw & pre-processed directories 
		inDir = os.path.join(data_dir,subject,rawDir)
		outDir =  os.path.join(data_dir,subject,ppDir)
		
		# make out directory if doesn't already exist 
		if not os.path.exists(outDir):
			os.makedirs(outDir)

		# cd to processed data directory 
		os.chdir(outDir)				
		

		# task loop
		for t in range(0,len(tasks)): 

			task = tasks[t]	# cue, mid, or midi 
			task_runs = runs[t] # number of scan runs in this task

			print 'PROCESSING '+task+' DATA\n'
	
			ppFiles = [] # list of pre-processed file names
			mcFiles = ['','',''] # motion file names from each run 
		
			for r in task_runs:
				
					
				#########  raw to afni format, omit first TRs if desired
				rawFuncFilePath = os.path.join(inDir,rawFileStr % (task,r))
				funcFile = rawToAfni(rawFuncFilePath,task+str(r))
				
					
				#########  slice time correct  
				funcFile = correctSliceTiming(funcFile)
					
				
				#########  make a functional reference volume if it doesn't exist yet
				if r==1: 
					refFile = makeRefVol(funcFile)
				

				#########  motion correct
				funcFile,these_mc_files = correctMotion(funcFile,r,refFile)
	 			mcFiles = ["%s %s" % t for t in zip(mcFiles,these_mc_files)]	


				#########  smooth
				funcFile = smooth(funcFile)
			

				#########  convert to % change units
				funcFile = convertUnits(funcFile)
		

				#########  high pass filter 
				funcFile = hpFilter(funcFile)
	 		

	 			#########  list of pre-processed file names for concatenating 
	 			ppFiles = ppFiles + [funcFile]


 				print '\n\nFINISHED RUN '+str(r)+'\n\n'


	 		######### convert pre-processed files to nifti & concat runs
	 		outFile = convertToNifti(ppFiles,'pp_'+task)
		
			
			######### concatenate motion files across runs 
			concatRunMCFiles(mcFiles)


			########## remove intermediary steps
			cmd = ('rm *'+task+'*+orig*')
			print cmd+'\n'
			if not justPrint:
		 		os.system(cmd)
			

			print '\n\npre-processed '+task+' data saved to '+outFile+'\n\n'


	print 'FINISHED SUBJECT '+subject
		
########### end of subject loop
	
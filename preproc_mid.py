#!/usr/bin/python

# filename: preproc_mid.py
# script to do pre-processing of functional data. Does the following: 

# 1) drops first X volumes from each scan run
# 2) slice time correction
# 3) pulls out a functional reference volume from the 1st run (for coreg, etc.)
# 4) motion correction
# 5) smooths data
# 6) converts to % change units
# 6) applies a high-pass filter 
# 7) transforms data to group space 
# 8) extracts mean times series for white matter and CSF ROI masks 


#### TO DO: 
# add error checks to see if files actually exist
# change hard-coded 2.9 voxel size when normalizing functional data to find 
#   that info in the file header
# add fieldmap undistortion step
# ideally, do slice time, motion correction & undistortion resampling 
#   in 1 interpolated step
# find a way to save out evidence from each step on how well it did (e.g., like
# 	how it currently saves out a png file showing head movement estimation)

# for Claudia's data, maybe add deoblique step: 
# 3dwarp -overwrite -deoblique -prefix mid_epid mid_epi+orig


import os,sys,glob


##################### define global variables #################################
# EDIT AS NEEDED:

data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
#from getCueSubjects import getsubs 
#subjects,gi = getsubs()
subjects = ['xx180626']
print subjects
#data_dir = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data')

 

runs = [1,2] 					# scan runs to process
rawDir = 'raw' # name of directory containing raw data, relative to subject dir
rawFileStr = 'mid%d.nii.gz'	# name of raw files, where %d is the run number

ppDir = 'func_proc_mid'  # name of directory for pre-processed data, " " 
baseStr = 'mid'			# base name of processed data (e.g., 'cue', or 'epi')

truncate = 0 # set to 1 to truncate the last 4 vols from each scan run, otherwise 0

# if this is set to 1 or True, commands will be printed to the screen but not 
#executed (for troubleshooting, etc.)
justPrint = 1

############### define relevant variables for each pre-processing step as needed

# how many volumes to drop from the beginning of each scan? 
omitNVols = 6 


# if using a fieldmap, specify filepath
fmapFilePath = ''


# slice timing correction parameter string
st_param_str = '-slice 0 -tpattern altplus'  


# which volume to use from 1st func run as a reference volume? 
ref_file = 'ref_vol+orig'  # reference volume file string 
ref_vol_idx = 4	 
	
	
# motion correction parameter string
mc_param_str = '-Fourier -twopass -zpad 4'  # mc params
	

# fwhm gaussian kernel to use for smoothing (in mm)
smooth_mm = 4 		


# high-pass filter cutoff (.011 hz ~= 1 cycle/90 sec)
hz_limit = .011		


# voxel dimensions and template for group space
vox_dim = 2.9
templateFilePath = os.path.join(data_dir,'templates','TT_N27_func_dim.nii')


# filepaths for white matter and CSF ROI masks
csfFilePath = os.path.join(data_dir,'ROIs','csf_func+tlrc' )
wmFilePath =  os.path.join(data_dir,'ROIs','wm_func+tlrc' )



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

	# uses global variables ref_file & ref_vol_idx
	cmd = ('3dTcat -prefix '+ref_file[0:ref_file.find('+')]+' '
	+inFile+'['+str(ref_vol_idx)+']')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
	
	

#########  motion correct  
def correctMotion(inFile,r):

	# uses global variable mc_param_str and ref_file
	
	outFile = 'm'+inFile
	mc_str = 'vr'
	
	cmd = ('3dvolreg '+mc_param_str+' -dfile '+mc_str+str(r)+'.1D -base '+ref_file+' '
	'-prefix '+outFile[0:outFile.find('+')]+' '+inFile)
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
		
	# save out plots of the motion correction params
	cmd = ('1dplot -dx 1 -xlabel Time -volreg -png '+mc_str+str(r)+' '+mc_str+str(r)+'.1D')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
					
	
	# make censor_tr file to be given to 3dDeconvolve to censor motion trs
	cmd = ('1d_tool.py -infile '+mc_str+str(r)+'.1D[1..6] -censor_motion 0.5 motion'+str(r)+' '
		'-show_censor_count -censor_prev_TR')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)

	# concatenate motion regs and censor idx across runs in a separate file
	if r==1:
		cmd = ('touch '+mc_str+'.1D')
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)
		cmd = ('touch motion_censor.1D')
		print cmd+'\n'
		if not justPrint:
			os.system(cmd)

	cmd = ('cat '+mc_str+str(r)+'.1D >> '+mc_str+'.1D')
	print cmd+'\n'
	if not justPrint:
			os.system(cmd)

	cmd = ('cat motion'+str(r)+'_censor.1D >> motion_censor.1D')
	print cmd+'\n'
	if not justPrint:
			os.system(cmd)

	return outFile	



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
	'-prefix '+outFile[0:outFile.find('+')]+' -datum float')
	print cmd+'\n'
	if not justPrint:
		os.system(cmd)
		os.remove(tempFile+'.BRIK')
		os.remove(tempFile+'.HEAD')

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


	
#########  normalize functional data
def normalizeAfniFunc(inFile):
	
	inStr = inFile[0:inFile.find('+')] # in file string
	outStr = inStr+'_afni'			# out file string

	cmd = ('adwarp -apar t1_ns_afni+tlrc. -dpar '+inFile+' '
	'-prefix '+outStr+' -dxyz '+str(vox_dim))
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	
	return outStr+'+tlrc'  # return out filename 


#########  normalize functional data
def normalizeANTSFunc(inFile):

	inStr = inFile[0:inFile.find('+')] # in file string
	outFile = inStr+'_tlrc.nii'

	# add ants directory to path
	cmd = ('export PATH=$PATH:'+os.path.join(os.path.expanduser('~')+'/repos/antsbin/bin'))
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	

	# convert to nifti 
	cmd = ('3dAFNItoNIFTI '+inFile)
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	# apply ANTs xform to functional data	
	cmd =('antsApplyTransforms -d 3 -e 3 -i '+inStr+'.nii -r '+templateFilePath+
	' -o '+outFile+' --float -t t12tlrcAffine.txt t12tlrcWarp.nii.gz')
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	cmd = ('3drefit -space tlrc -view tlrc '+outFile)
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	
	return outFile	


#########  extract average time series of white matter & csf masks 
def extractCsfWmTS(inFile,r='',astr=''):

	# uses global variables csfFilePath & wmFilePath
	
	cmd = ('3dmaskave -mask '+csfFilePath+' -quiet -mrange 1 2 '+inFile+
	' > csf'+str(r)+astr+'.1D')
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)

	cmd = ('3dmaskave -mask '+wmFilePath+' -quiet -mrange 1 2 '+inFile+
	' > wm'+str(r)+astr+'.1D')
	print cmd+'\n'
	if not justPrint:
	 	os.system(cmd)
	

###########################  MAIN PREPROC FUNCTION ############################

if __name__ == '__main__':
    
	
	# now loop through subjects, clusters and bricks to get data
	for subject in subjects:
	
		print 'WORKING ON SUBJECT '+subject+'\n'
	
		
		# define subject's raw & pre-processed directories 
		inDir = os.path.join(data_dir,subject,rawDir)
		outDir =  os.path.join(data_dir,subject,ppDir)
		
		# make out directory if doesn't already exist 
		if not os.path.exists(outDir):
			os.makedirs(outDir)

		# cd to processed data directory 
		os.chdir(outDir)				
		
		for r in runs:
			
				
			#########  raw to afni format, omit first TRs if desired
			rawFuncFilePath = os.path.join(inDir,rawFileStr % (r))
			funcFile = rawToAfni(rawFuncFilePath,baseStr+str(r))
			
				
			#########  slice time correct  
			funcFile = correctSliceTiming(funcFile)
				
			
			#########  make a functional reference volume if it doesn't exist yet
			filelist = glob.glob(ref_file+'*')  # list of files w/ ref_vol_str
			if not filelist and r==1: 
				makeRefVol(funcFile)
			

			#########  motion correct
			funcFile = correctMotion(funcFile,r)
 				

			#########  smooth
			funcFile = smooth(funcFile)
		

			#########  convert to % change units
			funcFile = convertUnits(funcFile)
	

			#########  high pass filter 
			funcFile = hpFilter(funcFile)
 		
 		
 		print 'FINISHED RUN '+str(r)


 		# concatenate runs 
 		cmd = ('3dTcat -prefix pp_mid fpsmtmid1+orig fpsmtmid2+orig')
	 	print cmd+'\n'
		if not justPrint:
	 		os.system(cmd)

	 	if not truncate:

	 		###########  normalize to group template - ANTS 
			funcFile = normalizeANTSFunc('pp_mid+orig')
		

			##########  extract csf and wm time series
			extractCsfWmTS(funcFile)
	

			########## normalize reference vol
	 		normalizeANTSFunc(ref_file)
		

		# if truncating last 4 vols of data, do that before normalizing & wm/csf extracting time series
	 	else:	
		
			cmd = ('3dTcat -prefix pp_mid_trunc pp_mid+orig.[0..251,256..543]')
			print cmd+'\n'
			if not justPrint:
		 		os.system(cmd)


 			# #########  normalize to group template - ANTS 
			funcFile = normalizeANTSFunc('pp_mid_trunc+orig')
			

			# #########  extract csf and wm time series
			extractCsfWmTS(funcFile,'_trunc')


			# make motion regs & motion censor idx fiiles without last 4 vols of each run
			cmd = ('head -n252 vr1.1D >> temp1; head -n288 vr2.1D >> temp2; cat temp1 temp2 >> vr_trunc.1D; rm temp*')
			print cmd+'\n'
			if not justPrint:
		 		os.system(cmd)
		
			cmd = ('head -n252 motion1_censor.1D >> temp1; head -n288 motion2_censor.1D >> temp2; cat temp1 temp2 >> motion_censor_trunc.1D; rm temp*')
			print cmd+'\n'
			if not justPrint:
		 		os.system(cmd)
		

		########## remove intermediary steps
		cmd = ('rm *mid1* *mid2* *pp_mid+*')
		print cmd+'\n'
		if not justPrint:
	 		os.system(cmd)
			

	print 'FINISHED SUBJECT '+subject
		
########### end of subject loop
	

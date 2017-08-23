 #!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

# this script is designed to regress out variance from nuisance regressors and then 
# correlate (regress) signal from an ROI on all voxel time series. 

# if this is performed on resting state data, it gives resting state connectivity 
# between an ROI and each voxel. 


data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')

afniStr = '_afni' # set this to '' if not using afni coreg version
#afniStr = '' # set this to '' if not using afni coreg version


# pre-processed functional data to analyze
func_dir = 'func_proc'  	# relative to subject-specific directory
func_files = 'pp_cue_tlrc'+afniStr+'.nii.gz'

out_dir = os.path.join(data_dir,'results_cue'+afniStr+'_Choi_caudate2')  	# directory for out files 
out_str = 'glm'					# string for output files


# provide ROI name(s) - this will be used to find a file with the roi time series
#roi1 = 'Choi_rostralcaudateL'
roi2 = 'Choi_ventralcaudateL'

		

##########################################################################################

# make out directory if its not already defined
if not os.path.exists(out_dir):
	os.makedirs(out_dir)

subjects = raw_input('subject id (enter "all" to process all subs): ')
print '\nyou entered: '+subjects+'\n'

subjects=subjects.split(' ')

if subjects[0]=='all':
	from getCueSubjects import getsubs 
	subjects,gi = getsubs('cue')


for subject in subjects:

	print '\n********** GLM FITTING FOR SUBJECT '+subject+' **********\n'

	this_out_str = subject+'_'+out_str

	# define subject-specific directories
	subj_dir = os.path.join(data_dir,subject) # subject dir
	os.chdir(subj_dir) 				 # cd to subj directory
	cdir = os.getcwd()
	print '\nCurrent working directory: '+cdir+'\n\n'
	# NOTE: all input file paths in the 3dDeconvolve command are relative to the subject's directory
	


#-#-#-#-#-#-#-#-#-#-#-		Run 3dDeconvolve:		-#-#-#-#-#-#-#-#-#-#-#

	cmd = ('3dDeconvolve '		
		'-jobs 2 '
		'-input '+func_dir+'/'+func_files+' '
		'-censor '+func_dir+'/'+'cue_censor.1D '
		'-num_stimts 9 '
		'-polort 2 '
		'-dmbase '						# de-mean baseline regressors
		'-xjpeg '+os.path.join(out_dir,'Xmat')+' '
		'-stim_file 1 "'+func_dir+'/cue_vr.1D[1]" -stim_base 1 -stim_label 1 roll '
		'-stim_file 2 "'+func_dir+'/cue_vr.1D[2]" -stim_base 2 -stim_label 2 pitch '
		'-stim_file 3 "'+func_dir+'/cue_vr.1D[3]" -stim_base 3 -stim_label 3 yaw '
		'-stim_file 4 "'+func_dir+'/cue_vr.1D[4]" -stim_base 4 -stim_label 4 dS ' 
		'-stim_file 5 "'+func_dir+'/cue_vr.1D[5]" -stim_base 5 -stim_label 5 dL ' 
		'-stim_file 6 "'+func_dir+'/cue_vr.1D[6]" -stim_base 6 -stim_label 6 dP ' 
		'-stim_file 7 '+func_dir+'/cue_csf'+afniStr+'.1D -stim_base 7 -stim_label 7 csf ' 
		'-stim_file 8 '+func_dir+'/cue_wm'+afniStr+'.1D -stim_base 8 -stim_label 8 wm ' 
		#'-stim_file 9 '+func_dir+'/cue_'+roi1+afniStr+'.1D -stim_label 9 rostralcaud ' 
		'-stim_file 9 '+func_dir+'/cue_'+roi2+afniStr+'.1D -stim_label 9 ventralcaud ' 
		#'-tout ' 					# output the partial and full model F
 		#'-rout ' 					# output the partial and full model R2
 		#'-xout '						# print design matrix to the screen
 		#'-errts errts '						# print design matrix to the screen
 		#'-bucket '+os.path.join(out_dir,this_out_str)+' ' 			# save out all info to filename w/prefix
 		'-cbucket '+os.path.join(out_dir,this_out_str+'_B')+' ' 		# save out only regressor coefficients to filename w/prefix
		)
	
# #############
# # RUN IT
# 
	print cmd+'\n'
	os.system(cmd)

	# z-score results
	# this_out_str_z = 'z_'+this_out_str
	# cmd = '3dmerge -doall -1zscore -prefix '+os.path.join(out_dir,this_out_str_z)+' '+os.path.join(out_dir,this_out_str+'+tlrc')
	# print cmd+'\n'
	# os.system(cmd)

	
	print '********** DONE WITH SUBJECT '+subject+' **********'


print 'finished subject loop'







 #!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

data_dir = '/Users/Kelly/cueexp/data'			# moxie
#data_dir = '/home/hennigan/cueexp/data'			# nims 


# subjects = ['aa151010','ag151024','al151016','dw151003','ie151020',
# 	'ja151218','jg151121','jv151030','nd150921','ps151001','si151120',
# 	'sr151031','tf151127','vm151031','wr151127','zl150930'] # subjects to process
# subjects = ['zl150930']  # subjects to process 
subjects = ['aa151010','ag151024','al151016','dw151003','ie151020',
	'ja151218','jg151121','jv151030','nd150921','ps151001','si151120',
	'sr151031','tf151127','vm151031','wr151127','zl150930'] # subjects to process


# pre-processed functional data to analyze
in_dir = 'func_proc_cue'  	# relative to subject-specific directory
in_files = 'cue_mbnf+tlrc.HEAD'


out_dir = os.path.join(data_dir,'results_base')  	# directory for out files 
out_str = 'glm'					# string for output files


##########################################################################################


# make out directory if its not already defined
if not os.path.exists(out_dir):
	os.makedirs(out_dir)


for subject in subjects:

	print '\n********** GLM FITTING FOR SUBJECT '+subject+' **********\n'


	this_out_str = subject+'_'+out_str
	
	
	# cd to subject dir
	os.chdir(os.path.join(data_dir,subject)) 				 # cd to subj directory
	cdir = os.getcwd()
	print 'Current working directory: '+cdir
	# NOTE: all input file paths in the 3dDeconvolve command are relative to the subject's directory
	


#-#-#-#-#-#-#-#-#-#-#-		Run 3dDeconvolve:		-#-#-#-#-#-#-#-#-#-#-#

	glm_cmd = ('3dDeconvolve '		
		'-jobs 2 '
		'-input '+os.path.join(in_dir,in_files)+' '
		'-nfirst 0 '
		'-num_stimts 6 '
		'-polort 2 '
		'-dmbase '						# de-mean baseline regressors
		'-xout '
		'-xjpeg '+os.path.join(out_dir,'Xmat')+' '
		'-stim_file 1 "'+in_dir+'/3dmotioncue.1D[1]" -stim_base 1 -stim_label 1 roll '
		'-stim_file 2 "'+in_dir+'/3dmotioncue.1D[2]" -stim_base 2 -stim_label 2 pitch '
		'-stim_file 3 "'+in_dir+'/3dmotioncue.1D[3]" -stim_base 3 -stim_label 3 yaw '
		'-stim_file 4 "'+in_dir+'/3dmotioncue.1D[4]" -stim_base 4 -stim_label 4 dS ' 
		'-stim_file 5 "'+in_dir+'/3dmotioncue.1D[5]" -stim_base 5 -stim_label 5 dL ' 
		'-stim_file 6 "'+in_dir+'/3dmotioncue.1D[6]" -stim_base 6 -stim_label 6 dP ' 
	#	'-stim_file 7 '+in_dir+'/csf1.1D -stim_base 7 -stim_label 7 csf ' 
#		'-stim_file 8 '+in_dir+'/wm1.1D -stim_base 8 -stim_label 8 wm ' 
 		'-errts '+os.path.join(out_dir,this_out_str+'_errts')+' ' 		# to save out the residual time series
 		#'-rout ' 					# output the partial and full model R2
 		#'-cbucket '+os.path.join(out_dir,this_out_str+'_B')+' ' 		# save out only regressor coefficients to filename w/prefix
		)
		
		
	print glm_cmd+'\n'
	os.system(glm_cmd)

	os.chdir(out_dir)  # cd to out_dir
	
	cmd = '3dAFNItoNIFTI '+this_out_str+'_errts+tlrc'
	print cmd+'\n'
	os.system(cmd)

	
	print '********** DONE WITH SUBJECT '+subject+' **********'


print 'finished subject loop'







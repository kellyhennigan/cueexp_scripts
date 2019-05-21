#!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

os.chdir('../')
main_dir=os.getcwd()
data_dir=main_dir+'/data'

#data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')


afniStr = '_afni' # set this to '' if not using afni coreg version
#afniStr = ''

# pre-processed functional data to analyze
func_dir = 'func_proc'  	# relative to subject-specific directory
func_files = 'pp_mid_tlrc'+afniStr+'.nii.gz'

out_dir = os.path.join(data_dir,'results_mid'+afniStr)  	# directory for out files 
out_str = 'glm'					# string for output files


##########################################################################################

# make out directory if its not already defined
if not os.path.exists(out_dir):
	os.makedirs(out_dir)


subjects = raw_input('subject id (enter "all" to process all subs): ')
print '\nyou entered: '+subjects+'\n'

subjects=subjects.split(' ')

if subjects[0]=='all':
	from getCueSubjects import getsubs 
	subjects,gi = getsubs('mid')



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
		'-concat '+main_dir+'/scripts/mid_runs_wEnd.1D '
		'-censor '+func_dir+'/'+'mid_censor.1D '
		'-num_stimts 14 '
		'-polort 2 '
		'-dmbase '						# de-mean baseline regressors
		'-xjpeg '+os.path.join(out_dir,'Xmat')+' '
		'-stim_file 1 "'+func_dir+'/mid_vr.1D[1]" -stim_base 1 -stim_label 1 roll '
		'-stim_file 2 "'+func_dir+'/mid_vr.1D[2]" -stim_base 2 -stim_label 2 pitch '
		'-stim_file 3 "'+func_dir+'/mid_vr.1D[3]" -stim_base 3 -stim_label 3 yaw '
		'-stim_file 4 "'+func_dir+'/mid_vr.1D[4]" -stim_base 4 -stim_label 4 dS ' 
		'-stim_file 5 "'+func_dir+'/mid_vr.1D[5]" -stim_base 5 -stim_label 5 dL ' 
		'-stim_file 6 "'+func_dir+'/mid_vr.1D[6]" -stim_base 6 -stim_label 6 dP ' 
		'-stim_file 7 '+func_dir+'/mid_csf'+afniStr+'.1D -stim_base 7 -stim_label 7 csf ' 
		'-stim_file 8 '+func_dir+'/mid_wm'+afniStr+'.1D -stim_base 8 -stim_label 8 wm ' 
		'-stim_file 9 regs/ant_midc.1D -stim_label 9 ant '
		'-stim_file 10 regs/out_midc.1D -stim_label 10 out '
		'-stim_file 11 regs/gvn_ant_midc.1D -stim_label 11 gvnant ' 
		'-stim_file 12 regs/lvn_ant_midc.1D -stim_label 12 lvnant ' 
		'-stim_file 13 regs/gvn_out_midc.1D -stim_label 13 gvnout ' 
		'-stim_file 14 regs/nvl_out_midc.1D -stim_label 14 nvlout ' 
		#'-xout '						# print design matrix to the screen
		'-tout ' 					# output the partial and full model F
 		'-rout ' 					# output the partial and full model R2
 		'-bucket '+os.path.join(out_dir,this_out_str)+' ' 			# save out all info to filename w/prefix
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



 #!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:


data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
from getCueSubjects import getsubs 
subjects,gi = getsubs()
#subjects = ['aa151010']

# data_dir = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data')
# from getCueSubjects import getsubs_claudia
# subjects,gi = getsubs_claudia()



# pre-processed functional data to analyze
func_dir = 'func_proc_cue'  	# relative to subject-specific directory
func_files = 'fpsmtcue1_tlrc.nii'
#func_files = 'fpsmtcue1_afni+tlrc'

out_dir = os.path.join(data_dir,'results_img_type_ants_orth')  	# directory for out files 
out_str = 'glm'					# string for output files


##########################################################################################


# make out directory if its not already defined
if not os.path.exists(out_dir):
	os.makedirs(out_dir)


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
		'-censor '+func_dir+'/'+'motion_censor.1D '
		'-num_stimts 15 '
		'-polort 2 '
		'-dmbase '						# de-mean baseline regressors
		'-xout '
		'-xjpeg '+os.path.join(out_dir,'Xmat')+' '
		'-stim_file 1 "'+func_dir+'/vr1.1D[1]" -stim_base 1 -stim_label 1 roll '
		'-stim_file 2 "'+func_dir+'/vr1.1D[2]" -stim_base 2 -stim_label 2 pitch '
		'-stim_file 3 "'+func_dir+'/vr1.1D[3]" -stim_base 3 -stim_label 3 yaw '
		'-stim_file 4 "'+func_dir+'/vr1.1D[4]" -stim_base 4 -stim_label 4 dS ' 
		'-stim_file 5 "'+func_dir+'/vr1.1D[5]" -stim_base 5 -stim_label 5 dL ' 
		'-stim_file 6 "'+func_dir+'/vr1.1D[6]" -stim_base 6 -stim_label 6 dP ' 
		'-stim_file 7 '+func_dir+'/csf1.1D -stim_base 7 -stim_label 7 csf ' 
		'-stim_file 8 '+func_dir+'/wm1.1D -stim_base 8 -stim_label 8 wm ' 
		'-stim_file 9 regs/cueca.1D -stim_label 9 cue '
		'-stim_file 10 regs/imgca.1D -stim_label 10 img ' 
		'-stim_file 11 regs/choiceca.1D -stim_label 11 choice '
		#'-stim_file 12 regs/cue_rtca.1D -stim_label 12 cue_rt ' 
		'-stim_file 12 regs/choice_rtca.1D -stim_label 12 choice_rt ' 
		'-stim_file 13 regs/img_food_vs_neutral_ca.1D -stim_label 13 food_vs_neutral ' 
		'-stim_file 14 regs/img_drugs_vs_alcohol_ca.1D -stim_label 14 drugs_vs_alc ' 
		'-stim_file 15 regs/img_alcdrugs_vs_foodneutral_ca.1D -stim_label 15 alcdrugs_vs_foodneutral ' 
		#'-stim_file 16 regs/cue_neutralca.1D -stim_label 16 neutral ' 
		# '-stim_file 17 regs/choice_strong_dontwantca.1D -stim_label 17 strong_dontwant ' 
		# '-stim_file 18 regs/choice_somewhat_dontwantca.1D -stim_label 18 somewhat_dontwant ' 
		# '-stim_file 19 regs/choice_somewhat_wantca.1D -stim_label 19 somewhat_want '
		# '-stim_file 20 regs/choice_strong_wantca.1D -stim_label 20 strong_want ' 
		#'-num_glt 3 '					 # of contrasts
		#'-glt_label 1 alcohol-neutral -gltsym "SYM: +alcohol -neutral" ' 
		#'-glt_label 2 drugs-neutral -gltsym "SYM: +drugs -neutral" '
		#'-glt_label 3 food-neutral -gltsym "SYM: +food -neutral" '
		# '-glt_label 1 preference -gltsym "SYM: -3*strong_dontwant -somewhat_dontwant +somewhat_want +3*strong_want" '
 		#'-errts '+os.path.join(out_dir,this_out_str+'_errts')+' ' 		# to save out the residual time series
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







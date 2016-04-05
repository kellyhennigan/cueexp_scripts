#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob


# set up study-specific directories and file names, etc.

data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
from getCueSubjects import getsubs
subjsA,_ = getsubs(0)	# controls
subjsB,_ = getsubs(1)   # patients
print subjsB

subjsA.remove('al151016')
subjsB.remove('ag151024')



# data_dir = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data')

# from getCueSubjects import getsubs_claudia
# subjects,gi = getsubs_claudia()
# subjsA = subjects
# subjsA.remove('286')
# subjsB=[]

# print subjsA
# print subjsB

res_dir = os.path.join(data_dir,'results_pref')  # directory containing glm stat files


in_str = '_glm+tlrc'  # identify file string

#labels of sub-bricks to test
# sub_labels = ['Full_R^2',
# 'Full_Fstat',
# 'cue#0_Coef',
# 'img#0_Coef',
# 'choice#0_Coef',
# 'cue_rt#0_Coef',
# 'choice_rt#0_Coef',
# 'strong_dontwant#0_Coef',
# 'somewhat_dontwant#0_Coef',
# 'somewhat_want#0_Coef',
# 'strong_want#0_Coef',
# 'preference_GLT#0_Coef']


# labels for out files 
# out_labels =  ['zFull_R2',
# 'zFull_Fstat',
# 'zcue',
# 'zimg',
# 'zchoice',
# 'zcue_rt',
# 'zchoice_rt',
# 'zstrong_dontwant',
# 'zsomewhat_dontwant',
# 'zsomewhat_want',
# 'zstrong_want',
# 'zpreference']

#labels of sub-bricks to test
sub_labels = ['strong_want#0_Coef',]

# labels for out files 
out_labels =  ['zstrong_want',]







##########################################################################################


os.chdir(res_dir) 		 			# cd to results dir 


for i, sub_label in enumerate(sub_labels): 
	print i, sub_label

	# get part of command for subjects in setA
	subjA_cmd = ' '
	if subjsA:
		subjA_cmd = '-setA '
		for subj in subjsA:
			print subj
			cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str
			#print cmd
			vol_idx=int(os.popen(cmd).read())
			subjA_cmd+="'"+subj+in_str+'['+str(vol_idx)+']'+"' " 

	# get part of command for subjects in setA
	subjB_cmd = ''
	if subjsB:
		subjB_cmd = '-setB '
		for subj in subjsB:
			print subj
			cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str
			vol_idx=int(os.popen(cmd).read())
			subjB_cmd+="'"+subj+in_str+'['+str(vol_idx)+']'+"' " 



	cmd = '3dttest++ -prefix '+out_labels[i]+' -toz '+subjA_cmd+subjB_cmd
	print cmd
	os.system(cmd)


	

	
	
	



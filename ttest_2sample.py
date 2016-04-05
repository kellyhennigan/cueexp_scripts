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
#data_dir = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data')

res_dir = os.path.join(data_dir,'results')  # directory containing glm stat files


in_str = '_glm+tlrc'  # identify file string

# labels of sub-bricks to test
sub_labels = ['Full_R^2',
'Full_Fstat',
'cue#0_Coef',
'img#0_Coef',
'choice#0_Coef',
'cue_rt#0_Coef',
'choice_rt#0_Coef',
'alcohol#0_Coef',
'drugs#0_Coef',
'food#0_Coef',
'neutral#0_Coef',
'alcohol-neutral_GLT#0_Coef',
'drugs-neutral_GLT#0_Coef',
'food-neutral_GLT#0_Coef',
'preference_GLT#0_Coef']


# labels for out files 
out_labels =  ['zFull_R2',
'zFull_Fstat',
'zcue',
'zimg',
'zchoice',
'zcue_rt',
'zchoice_rt',
'zalcohol',
'zdrugs',
'zfood',
'zneutral',
'zalc-neutral',
'zdrug-neutral',
'zfood-neutral',
'zpreference']

from getCueSubjects import getsubs
subjsA,_ = getsubs(0)	# controls
subjsB,_ = getsubs(1)   # patients




##########################################################################################


os.chdir(res_dir) 		 			# cd to results dir 



for i, sub_label in enumerate(sub_labels): 
	print i, sub_label

	# get part of command for subjects in setA
	subjA_cmd = ''
	for subj in subjsA:
		vol_idx=int(os.popen("3dinfo -label2index '"+sub_label+"' "+subj+in_str).read())
		subjA_cmd+="'"+subj+in_str+'['+str(vol_idx)+']'+"' " 

	# get part of command for subjects in setA
	subjB_cmd = ''
	for subj in subjsB:
		vol_idx=int(os.popen("3dinfo -label2index '"+sub_label+"' "+subj+in_str).read())
		subjB_cmd+="'"+subj+in_str+'['+str(vol_idx)+']'+"' " 



	cmd = '3dttest++ -prefix '+out_labels[i]+' -toz -setA '+subjA_cmd+ '-setB '+subjB_cmd
	print cmd
	os.system(cmd)

	# 3dttest++ -prefix '+z_cue -toz -setA 'aa151010_glm+tlrc[2]' 'nd150921_glm+tlrc[2]' -setB 'ag151024_glm+tlrc[2]' 'si151120_glm+tlrc[2]' 

	

	
	
	



#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob,numpy as np


# set up study-specific directories and file names, etc.

data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')

from getCueSubjects import getsubs
subjsA,_ = getsubs('cue',1)	# patients
subjsB,_ = getsubs('cue',0) # controls

print subjsA
print subjsB

res_dir = os.path.join(data_dir,'results_cue_mchugh_nacc')  # directory containing glm stat files

in_str = '_glm_B+tlrc'  # identify file string of coefficients file 

# labels of sub-bricks to test
sub_labels = ['nacc#0']

# labels for out files 
out_labels =  ['Znacc']


# # glt contrasts, arent in coeff bucket so get them from glm bucket: 
in_str2 = '_glm+tlrc'

sub_labels2 = ['nacc_R^2']

# labels for out files 
out_labels2 =  ['Znacc_R^2']

# concatenate lists 
in_str = np.append(np.tile(in_str,len(sub_labels)),np.tile(in_str2,len(sub_labels2)))
sub_labels = sub_labels+sub_labels2
out_labels = out_labels+out_labels2

##########################################################################################

	

os.chdir(res_dir) 		 			# cd to results dir 
print res_dir


for i, sub_label in enumerate(sub_labels): 
	print i, sub_label
	
	# get part of command for subjects in setA
	subjA_cmd = ' '
	if subjsA:
		subjA_cmd = '-setA '
		for subj in subjsA:
			cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
			vol_idx=int(os.popen(cmd).read())
			subjA_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 
			print subjA_cmd


	# get part of command for subjects in setB
	subjB_cmd = ''
	if subjsB:
		subjB_cmd = '-setB '
		for subj in subjsB:
			cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
			vol_idx=int(os.popen(cmd).read())
			subjB_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 



	cmd = '3dttest++ -prefix '+out_labels[i]+' -toz '+subjA_cmd+subjB_cmd
	print cmd
	os.system(cmd)

	# 3dttest++ -prefix '+z_cue -toz -setA 'aa151010_glm+tlrc[2]' 'nd150921_glm+tlrc[2]' -setB 'ag151024_glm+tlrc[2]' 'si151120_glm+tlrc[2]' 

	

	
	
	



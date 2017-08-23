#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob,numpy as np

justPrint = 0 # 1 to just print, 0 to print and execute

# set up study-specific directories and file names, etc.
if os.path.exists('/Volumes/G-DRIVE/cueexp/data'):
	data_dir = '/Volumes/G-DRIVE/cueexp/data'
else: 
	data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')


from getCueSubjects import getsubs
subjsA,_ = getsubs('cue',1)	# patients
subjsB,_ = getsubs('cue',0) # controls

 

print(subjsA)
print(subjsB)

#res_dir = os.path.join(data_dir,'results_cue')  # directory containing glm stat files
res_dir = os.path.join(data_dir,'results_cue_afni_Choi_caudate2')  # directory containing glm stat files

in_str = '_glm_B+tlrc'  # identify file string of coefficients file 

out_str = ''
#out_str = '_age_match'  # suffix to add to the end of enach out file

# labels of sub-bricks to test
sub_labels = ['csf#0',
'wm#0',
'ventralcaud#0']


# labels for out files 
out_labels =  ['Zcsf'+out_str,
'Zwm'+out_str,
'Zventralcaud'+out_str]


# concatenate lists 
in_str = np.tile(in_str,len(sub_labels))


# define mask file if masking is desired; otherwise leave blank
mask_file = os.path.join(data_dir,'templates','bmask.nii')  # directory containing glm stat files
#mask_file = ''

##########################################################################################

	

os.chdir(res_dir) 		 			# cd to results dir 
print(res_dir)


for i, sub_label in enumerate(sub_labels): 
	#print i, sub_label
	
	# get part of command for subjects in setA
	subjA_cmd = ' '
	if subjsA:
		subjA_cmd = '-setA '
		for subj in subjsA:
			cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
			vol_idx=int(os.popen(cmd).read())
			subjA_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 
			print(subjA_cmd)


	# get part of command for subjects in setB
	subjB_cmd = ''
	if subjsB:
		subjB_cmd = '-setB '
		for subj in subjsB:
			cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
			vol_idx=int(os.popen(cmd).read())
			subjB_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 


	# define mask command, if desired
	if mask_file:
		mask_cmd = ' -mask '+mask_file
	else:
		mask_cmd = ''


	cmd = '3dttest++ -prefix '+out_labels[i]+mask_cmd+' -toz '+subjA_cmd+subjB_cmd
	print(cmd+'\n')
	if not justPrint:
		os.system(cmd)

	# 3dttest++ -prefix '+z_cue -toz -setA 'aa151010_glm+tlrc[2]' 'nd150921_glm+tlrc[2]' -setB 'ag151024_glm+tlrc[2]' 'si151120_glm+tlrc[2]' 

	

	
	
	



#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob,numpy as np

justPrint = 0 # 1 to just print, 0 to print and execute

# # set up study-specific directories and file names, etc.
# if os.path.exists('/Volumes/G-DRIVE/cueexp/data'):
# 	data_dir = '/Volumes/G-DRIVE/cueexp/data'
# else: 
# 	data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
scripts_dir=os.getcwd()
os.chdir('../')
main_dir=os.getcwd()
data_dir=main_dir+'/data'
os.chdir(scripts_dir)


from getCueSubjects import getsubs
#subjsA,_ = getsubs('cue',1)	# patients
subjsB,_ = getsubs('cue',0) # controls
subjsA=['cd171130','ab171208','kk180117','rl180205','jc180212','ct180224','rm180316','cm180506','sh180518','rm180525','dl180602','ap180613','jj180618','lh180622','dr180715','md181018','lh181030','td181116','kd181119','zg181207','lm181213','wa181217','sp190209','pf190214','rc190221','kc190225','mm190226','sd190315','hh190412','ds190510','tc190628','ah190717','jj190821','rc191015','jm191125','mk191218']

print(subjsA)
print(subjsB)

#res_dir = os.path.join(data_dir,'results_cue')  # directory containing glm stat files
res_dir = os.path.join(data_dir,'results_cue_afni')  # directory containing glm stat files

out_str = '_sample2'
#out_str = '_n35'  # suffix to add to the end of enach out file


doClustSim = 0 # 1 to do clustsim, otherwise 0 (it takes a while)


# file containing covariate data 
#cv_file = os.path.join(res_dir,'subj_age.txt')  
#out_str = out_str+'_CVage'
cv_file = ''


in_str = '_glm_B+tlrc'  # identify file string of coefficients file 

# labels of sub-bricks to test
sub_labels = ['cue#0',
'img#0',
'choice#0',
'choice_rt#0',
'alcohol#0',
'drugs#0',
'food#0',
'neutral#0'] 

# labels for out files 
out_labels =  ['Zcue'+out_str,
'Zimg'+out_str,
'Zchoice'+out_str,
'Zchoice_rt'+out_str,
'Zalcohol'+out_str,
'Zdrugs'+out_str,
'Zfood'+out_str,
'Zneutral'+out_str]

# glt contrasts, arent in coeff bucket so get them from glm bucket: 
in_str2 = '_glm+tlrc'

sub_labels2 = ['Full_R^2',
'Full_Fstat',
'alcohol-neutral_GLT#0_Coef',
'drugs-neutral_GLT#0_Coef',
'food-neutral_GLT#0_Coef',
'drugs-food_GLT#0_Coef']


# labels for out files 
out_labels2 =  ['ZFull_R^2'+out_str,
'ZFull_Fstat'+out_str,
'Zalc-neutral'+out_str,
'Zdrug-neutral'+out_str,
'Zfood-neutral'+out_str,
'Zdrug-food'+out_str]

# concatenate lists 
in_str = np.append(np.tile(in_str,len(sub_labels)),np.tile(in_str2,len(sub_labels2)))
sub_labels = sub_labels+sub_labels2
out_labels = out_labels+out_labels2
print('\n\n\nIN STR:\n\n\n')
print(in_str)
print('\n\n\n\n\n\n')

# define mask file if masking is desired; otherwise leave blank
mask_file = os.path.join(data_dir,'templates','tt29_bmask.nii')  
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
			#print(subjA_cmd)


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


	# covariate command, if desired
	if cv_file:
		cv_cmd = ' -covariates '+cv_file
	else:
		cv_cmd = ''


	# clustsim command, if desired
	if doClustSim:
		clustsim_cmd = ' -Clustsim '
	else:
		clustsim_cmd = ''

	cmd = '3dttest++ -prefix '+out_labels[i]+mask_cmd+' -toz '+clustsim_cmd+subjA_cmd+subjB_cmd+cv_cmd
	print(cmd+'\n')
	if not justPrint:
		os.system(cmd)

	# 3dttest++ -prefix '+z_cue -toz -setA 'aa151010_glm+tlrc[2]' 'nd150921_glm+tlrc[2]' -setB 'ag151024_glm+tlrc[2]' 'si151120_glm+tlrc[2]' 

	

	
	
	



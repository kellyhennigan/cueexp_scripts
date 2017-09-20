#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob,numpy as np

justPrint = 1 # 1 to just print, 0 to print and execute

# set up study-specific directories and file names, etc.
if os.path.exists('/Volumes/G-DRIVE/cueexp/data'):
	data_dir = '/Volumes/G-DRIVE/cueexp/data'
else: 
	data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')


from getCueSubjects import getsubs
subjsA,_ = getsubs('cue',1)	# patients
subjsB,_ = getsubs('cue',0) # controls

 
    
### to do age matched control group: 
#subjsB.remove('zl150930')
#subjsB.remove('ps151001')
#subjsB.remove('aa151010')
#subjsB.remove('al151016')
## subjsB.remove('jv151030')
#subjsB.remove('kl160122')
#subjsB.remove('ss160205')
#subjsB.remove('bp160213')
#subjsB.remove('cs160214')
#subjsB.remove('yl160507')
#subjsB.remove('li160927')
#subjsB.remove('gm161101')

print(subjsA)
print(subjsB)

#res_dir = os.path.join(data_dir,'results_cue')  # directory containing glm stat files
res_dir = os.path.join(data_dir,'results_cue_afni')  # directory containing glm stat files

in_str = '_glm_B+tlrc'  # identify file string of coefficients file 

out_str = ''
#out_str = '_age_match'  # suffix to add to the end of enach out file

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

	

	
	
	




3dANOVA3 –type 5 –alevels 2 –blevels 3 –clevels 8 \
-dset 1 1 1 control1/glm_out_5mm+tlrc[4] \

-dset 1 1 2 control2/glm_out_5mm+tlrc[4] \

-dset 1 1 3 control3/glm_out_5mm+tlrc[4] \

-dset 1 1 4 control4/glm_out_5mm+tlrc[4] \

-dset 1 1 5 control5/glm_out_5mm+tlrc[4] \

-dset 1 1 6 control6/glm_out_5mm+tlrc[4] \

-dset 1 1 7 control7/glm_out_5mm+tlrc[4] \

-dset 1 1 8 control8/glm_out_5mm+tlrc[4] \

-dset 1 2 1 control1/glm_out_5mm+tlrc[5] \

-dset 1 2 2 control2/glm_out_5mm+tlrc[5] \

-dset 1 2 3 control3/glm_out_5mm+tlrc[5] \

-dset 1 2 4 control4/glm_out_5mm+tlrc[5] \

-dset 1 2 5 control5/glm_out_5mm+tlrc[5] \

-dset 1 2 6 control6/glm_out_5mm+tlrc[5] \

-dset 1 2 7 control7/glm_out_5mm+tlrc[5] \

-dset 1 2 8 control8/glm_out_5mm+tlrc[5] \

-dset 1 3 1 control1/glm_out_5mm+tlrc[6] \

-dset 1 3 2 control2/glm_out_5mm+tlrc[6] \

-dset 1 3 3 control3/glm_out_5mm+tlrc[6] \

-dset 1 3 4 control4/glm_out_5mm+tlrc[6] \

-dset 1 3 5 control5/glm_out_5mm+tlrc[6] \

-dset 1 3 6 control6/glm_out_5mm+tlrc[6] \

-dset 1 3 7 control7/glm_out_5mm+tlrc[6] \

-dset 1 3 8 control8/glm_out_5mm+tlrc[6] \

-dset 2 1 1 patient1/glm_out_5mm+tlrc[4] \

-dset 2 1 2 patient2/glm_out_5mm+tlrc[4] \

-dset 2 1 3 patient3/glm_out_5mm+tlrc[4] \

-dset 2 1 4 patient4/glm_out_5mm+tlrc[4] \

-dset 2 1 5 patient5/glm_out_5mm+tlrc[4] \

-dset 2 1 6 patient6/glm_out_5mm+tlrc[4] \

-dset 2 1 7 patient7/glm_out_5mm+tlrc[4] \

-dset 2 1 8 patient8/glm_out_5mm+tlrc[4] \

-dset 2 2 1 patient1/glm_out_5mm+tlrc[5] \

-dset 2 2 2 patient2/glm_out_5mm+tlrc[5] \

-dset 2 2 3 patient3/glm_out_5mm+tlrc[5] \

-dset 2 2 4 patient4/glm_out_5mm+tlrc[5] \

-dset 2 2 5 patient5/glm_out_5mm+tlrc[5] \

-dset 2 2 6 patient6/glm_out_5mm+tlrc[5] \

-dset 2 2 7 patient7/glm_out_5mm+tlrc[5] \

-dset 2 2 8 patient8/glm_out_5mm+tlrc[5] \

-dset 2 3 1 patient1/glm_out_5mm+tlrc[6] \

-dset 2 3 2 patient2/glm_out_5mm+tlrc[6] \

-dset 2 3 3 patient3/glm_out_5mm+tlrc[6] \

-dset 2 3 4 patient4/glm_out_5mm+tlrc[6] \

-dset 2 3 5 patient5/glm_out_5mm+tlrc[6] \

-dset 2 3 6 patient6/glm_out_5mm+tlrc[6] \

-dset 2 3 7 patient7/glm_out_5mm+tlrc[6] \

-dset 2 3 8 patient8/glm_out_5mm+tlrc[6] \

We now specify the output that we want:

-fa group –fb face –fab groupByFace \

This line specifies that we want the F-test for the group main effect, the F-test for the face main effect, and the F-test for the group by face interaction.

Next we can look at specific contrasts:

-acontr 1 0 controls –acontr 0 1 patients \

-bcontr 1 0 0 happy –bcontr 0 1 0 fearful –bcontr 0 0 1 neutral \

These two lines specify that we want the factor level means and statistical tests of whether those means are significantly different from 0.

-acontr 1 –1 contr_pat_diff \

-bcontr 1 –1 0 happ_fear_diff –bcontr 1 0 –1 happ_neut_diff –bcontr 0 1 –1 fear_neut_diff –bcontr 0.5 0.5 –1 emo_neut_diff \

These lines test specific contrasts for each factor, averaged across the levels of the other factors.

-aBcontr 1 –1 : 1 cont_pat_diff_happ –aBcontr 1 –1 : 2 cont_pat_diff_fear –aBcontr 1 –1 : 3 cont_pat_diff_neut \

-Abcontr 1 : 1 –1 0 happ_fear_diff_cont –Abcontr 2 : 1 –1 0 happ_fear_diff_pat \

These two lines test contrasts for one factor calculated within a specific level of the other factor.

There are abviously many more contrasts that could be specified than the ones we have here. Bear in mind that you should really only be looking at these contrasts if i) you have an apriori hypothesis about a specific contrast, ii) the main effect F-test for a given factor is significant and you want to know which factor level differences are driving the main effect, or ii) the interaction of two factors is significant and you need to know what differences are driving the interaction. Don’t fall victim to a fishing expedition in which you test every single possible contrast, and possibly wind up with a catch of junk. If you must do exploratory analyses, then you should guard against Type I error by adopting a suitably more stringent threshold.

-bucket anova

Finally, we specify that all the results should be saved in a statistical bucket dataset called anova+tlrc.

At this stage you have completed a basic statistical analysis of fMRI data.



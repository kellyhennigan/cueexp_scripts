#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob,numpy as np


# set up study-specific directories and file names, etc.

# data_dir = os.path.join(os.path.expanduser('~'),'cueexp','data')
scripts_dir=os.getcwd()
os.chdir('../')
main_dir=os.getcwd()
data_dir=main_dir+'/data'
os.chdir(scripts_dir)

from getCueSubjects import getsubs
# subjsA,_ = getsubs('midi',1)	# patients
# subjsB,_ = getsubs('midi',0)    # controls

# relapsers @ 6months 
subjsA = ['si151120','wr151127','rv160413','rc161007','al170316','jd170330','jw170330','tg170423','jc170501','as170730','rt170816','cd171130','rm180316','sh180518','rm180525','jj180618','lh180622','tv181019','wa181217','sp190209','pf190214','rc190221','mm190226','jm191125']

# non-relapsers @ 6 months 
subjsB = ['ag151024','ja160416','cm160510','zm160627','jf160703','cg160715','nc160905','mr161024','rl170603','mr170621','ds170728','ds170915','ts170927','kk180117','jc180212','ct180224','cm180506','td181116','kd181119','zg181207','jj190821']


# data_dir = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data')

# from getCueSubjects import getsubs_claudia
# subjects,gi = getsubs_claudia()
# subjsA = subjects
# subjsB=[]

print subjsA
print subjsB

#res_dir = os.path.join(data_dir,'results_midi')  # directory containing glm stat files
res_dir = os.path.join(data_dir,'results_midi_afni')  # directory containing glm stat files

in_str = '_glm_B+tlrc'  # identify file string

out_str = '_REL'  # suffix to add to the end of enach out file

# labels of sub-bricks to test
sub_labels = ['ant#0',
'out#0',
'target#0',
'gvng_tar#0',
'gvngXwin_out#0',
'gvn_ant#0',
'lvn_ant#0',
'gvnXgvng_tar#0',
'lvnXgvng_tar#0',
'gvn_out#0',
'nvl_out#0',
'gvnXgvngXwin_tar#0',
'lvnXgvngXwin_tar#0',
'csf#0',
'wm#0']

			
# labels for out files 
out_labels =  ['Zant'+out_str,
'Zout'+out_str,
'Ztarget'+out_str,
'Zgvng_tar'+out_str,
'ZgvngXwin_out'+out_str,
'Zgvn_ant'+out_str,
'Zlvn_ant'+out_str,
'ZgvnXgvng_tar'+out_str,
'ZlvnXgvng_tar'+out_str,
'Zgvn_out'+out_str,
'Znvl_out'+out_str,
'ZgvnXgvngXwin_tar'+out_str,
'ZlvnXgvngXwin_tar'+out_str,
'Zcsf'+out_str,
'Zwm'+out_str]

# glt contrasts, arent in coeff bucket so get them from glm bucket: 
in_str2 = '_glm+tlrc'

sub_labels2 = ['Full_R^2',
'Full_Fstat']

# labels for out files 
out_labels2 =  ['ZFull_R^2'+out_str,
'ZFull_Fstat'+out_str] 

# concatenate lists 
in_str = np.append(np.tile(in_str,len(sub_labels)),np.tile(in_str2,len(sub_labels2)))
sub_labels = sub_labels+sub_labels2
out_labels = out_labels+out_labels2

# define mask file if masking is desired; otherwise leave blank
mask_file = os.path.join(data_dir,'templates','bmask.nii')  # directory containing glm stat files
#mask_file = ''

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


	# define mask command, if desired
	if mask_file:
		mask_cmd = ' -mask '+mask_file
	else:
		mask_cmd = ''


	cmd = '3dttest++ -prefix '+out_labels[i]+mask_cmd+' -toz '+subjA_cmd+subjB_cmd
	print cmd
	os.system(cmd)


	

	
	
	



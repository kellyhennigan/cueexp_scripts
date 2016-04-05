#!/usr/bin/python

# filename: setup_raw_data.py
# script to set up a subject's data folder and to create symbolic links to raw data


import os,sys, glob

# define study-specific directories and file names, etc.

nims_exp_dir = '/nimsfs/knutson/cuefmri/'	# experiment main dir on nims
data_dir = '/home/hennigan/cueexp/data/'	# main data dir 


subject = 'jn160403'				# subject id (string)
exam_no = '12135'				# cni exam number (string)


# define the scan numbers associated with each scan (or set to 0 to not do anything): 
t1 = 3
func_cue = 6
func_mid1 = 7
func_mid2 = 8
func_midi1 = 9
func_midi2 = 10
dti=13


####################################################


# define subject's directory on nims
flist = glob.glob(os.path.join(nims_exp_dir,'*'+exam_no))
if len(flist)!=1:
	print '\n\n\nhey wait! somethings not right with the exam no for this subject\n\n\n'
	
subj_nims_dir = flist[0] 	# define subject exam directory on nims


# make subject directories if not already made 
subject_dir=data_dir+subject
if not os.path.exists(subject_dir):
    os.makedirs(subject_dir)
raw_dir=subject_dir+'/raw/'
if not os.path.exists(raw_dir):
    os.makedirs(raw_dir)
roi_dir=subject_dir+'/ROIs/'
if not os.path.exists(roi_dir):
    os.makedirs(roi_dir)
t1_dir=subject_dir+'/t1/'
if not os.path.exists(t1_dir):
    os.makedirs(t1_dir)


# cd to subject's raw data dir    
os.chdir(raw_dir)


################## CREATE SYMBOLIC LINKS TO NIMS DATA ##################

print 'setting up symbolic links for subject '+subject
	
# cue task data
if func_cue!=0:

	n = str(func_cue) 	# get scan number as string
	thisStr = '_1_BOLD_EPI_29mm_2sec_CUE'
	outName = 'cue1.nii.gz'
	
	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	
	

# MID data
if func_mid1!=0:
	
	n = str(func_mid1) 	# get scan number as string
	thisStr = '_1_BOLD_EPI_29mm_2sec_MID_1'
	outName = 'mid1.nii.gz'

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	


if func_mid2!=0:

	n = str(func_mid2) 	# get scan number as string
	thisStr = '_1_BOLD_EPI_29mm_2sec_MID_2'
	outName = 'mid2.nii.gz'

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	


# MIDI data
if func_midi1!=0:
	
	n = str(func_midi1) 	# get scan number as string
	thisStr = '_1_BOLD_EPI_29mm_2sec_MIDI_1'
	outName = 'midi1.nii.gz'

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	


if func_midi2!=0:

	n = str(func_midi2) 	# get scan number as string
	thisStr = '_1_BOLD_EPI_29mm_2sec_MIDI_2'
	outName = 'midi2.nii.gz'

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	



# t1 data
if t1!=0:

	n = str(t1) 	# get scan number as string
	thisStr = '_1_T1w_9mm_BRAVO'
	outName = 't1_raw.nii.gz'

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	
	

# dti data 
if dti!=0:

	n = str(dti) 	# get scan number as string
	thisStr = '_1_DTI_2mm_b2500_96dir1'
	outName = 'dwi.nii.gz'
	
	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.nii.gz')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' '+outName
		os.system(cmd)	

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.bval')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' bval'
		os.system(cmd)	

	fp = os.path.join(subj_nims_dir,exam_no+'_'+n+thisStr,exam_no+'_'+n+'_1.bvec')
	if os.path.exists(fp):
		cmd = 'ln -s '+fp+' bvec'
		os.system(cmd)		

	

print 'done with subject '+subject



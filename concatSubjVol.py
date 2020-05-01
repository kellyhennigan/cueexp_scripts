#!/usr/bin/python

# script to take a 3d file from each subject, get the mean, and then concatenate
# the mean volume along with each subject's volume into one 4d file. 

# this is meant to be useful for, e.g., checking inter-subject alignment 
# in group space. 

import os,sys,glob


#########  get base directory 
def whichBaseDir():
	
	base_dirs = ['','cueexp','cueexp_claudia']
	print 'Which project directory?\n'
	print '\t1) '+base_dirs[1]
	print '\t2) '+base_dirs[2]+'\n'
	i = input('enter 1 or 2: ') # get directory index

	return base_dirs[i]
	

#########  get main data directory and subjects to process	
def whichSubs(base_dir='cueexp'):

	
	if base_dir=='cueexp':
		from getCueSubjects import getsubs 
		subjects,gi = getsubs()
	elif base_dir=='cueexp_claudia':
		from getCueSubjects import getsubs_claudia
		subjects,gi = getsubs_claudia()

	print ' '.join(subjects)

	input_subs = raw_input('subject id(s) (hit enter to process all subs): ')
	print '\nyou entered: '+input_subs+'\n'

	if input_subs:
		subjects=input_subs.split(' ')

	return subjects
	


if __name__ == '__main__':
	
	
	# get full path for main project directory & return to current dir
	os.chdir('../')
	main_dir=os.getcwd()
	os.chdir('scripts')

	data_dir = os.path.join(main_dir,'data')  
	os.chdir(data_dir) 		

	subjects = whichSubs()

	filepath = raw_input('filepath to process, relative to subject dir: ')
	print filepath

	out_dir = raw_input('out directory, relative to data dir (will create if it doesnt exist): ')
	if not os.path.exists(out_dir):
		os.makedirs(out_dir)

	out_str = raw_input('prefix for outfile: ')

	outpath = os.path.join(out_dir,out_str+'.nii.gz') # e.g., 'tlrc_vols/all_ref'
	
	flist = []

	for subject in subjects: 

		subj_filepath = os.path.join(data_dir,subject,filepath)
		print subj_filepath

		if os.path.isfile(subj_filepath):
			flist.append(subj_filepath)
		else: 
			print 'no file found for subject, '+subject

	flist = ' '.join(flist)

	cmd = ('3dTcat -prefix '+outpath+' '+flist)
	print cmd
	os.system(cmd)

	mean_outpath = os.path.join(out_dir,'mean_'+out_str+'.nii.gz') 
	cmd = ('3dTstat -mean -prefix '+mean_outpath+' '+outpath)
	print cmd
	os.system(cmd)

	
	# mean_outfile = convertToNifti(mean_outpath)
	# print 'mean outfile: '+mean_outFile
	

	



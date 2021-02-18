#!/usr/bin/python

# script to return subject ids for subjects in cue fmri experiment. To use in a python script, do: 

		# from getCueSubjects import getsubs
		# subjects,gi = getsubs()

# returns subjects as a list of subject id strings and gi is a group index of group membership 
# (0 for controls, 1 for patients). Alternatively, do subjsA,_ = getsubs(0)	to return just 
# control subjects, or: subjsB,_ = getsubs(1) for just patients.   

import os,sys,socket,csv
from itertools import compress

#########  get main data directory and subjects to process	
def getMainDir():

	hostname=socket.gethostname()

	if hostname=='vta': 					# linux 
		main_dir='/home/span/lvta/cueexp'
	elif hostname=='sr15-9bb16ea2f9':		# Kelly's laptop
		main_dir='/Users/kelly/cueexp'
	else: 
		main_dir='/Users/kelly/cueexp'

	return main_dir


def getsubs(task='',group='all'):

	main_dir=getMainDir()

	# data directory
	data_dir=main_dir+'/data'
	#print 'data_dir:'+data_dir

	# define path to subject file
	subjFile = os.path.join(data_dir,'subjects_list','subjects_list.csv')
	

	## define variables to pull out of csv file
	subjects = [] # list of subject ids
	gi = []		  # list of corresponding group indices
		
	# these will be indices of which subjects to keep for each task	
	cue_idx = []
	mid_idx = []
	midi_idx = []
	dti_idx = []
	cue_sample1_idx = []
	cue_sample2_idx = []
	dti_mfb_idx = []
	relapse6mo_idx = []

	with open(subjFile) as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=',')
		line_count = 0
		for line in csv_reader:
			if line_count == 0:
				colnames=line
				#print(colnames)
				line_count += 1
			else:
				subjects.append(line[0])
				gi.append(int(line[1]))
				cue_idx.append(bool(int(line[2])))
				mid_idx.append(bool(int(line[3])))
				midi_idx.append(bool(int(line[4])))
				dti_idx.append(bool(int(line[5])))
				cue_sample1_idx.append(bool(int(line[6])))
				cue_sample2_idx.append(bool(int(line[7])))
				dti_mfb_idx.append(bool(int(line[8])))

				# # deal with relapse NaN values
				# if (line[10][-3:]=='NaN')
				# relapse6mo_idx.append(bool(int(line[10])))

	# if a task string is given, return subset of subjects for that task
	if task=='cue': 
		subjects=list(compress(subjects,cue_idx))
		gi=list(compress(gi,cue_idx))

	elif task=='mid':
	
		subjects=list(compress(subjects,mid_idx))
		gi=list(compress(gi,mid_idx))

	elif task=='midi':
	
		subjects=list(compress(subjects,midi_idx))
		gi=list(compress(gi,midi_idx))

	elif task=='dti':
	
		subjects=list(compress(subjects,dti_idx))
		gi=list(compress(gi,dti_idx))

	elif task=='cue_sample1':
	
		subjects=list(compress(subjects,cue_sample1_idx))
		gi=list(compress(gi,cue_sample1_idx))

	elif task=='cue_sample2':
	
		subjects=list(compress(subjects,cue_sample2_idx))
		gi=list(compress(gi,cue_sample2_idx))

	elif task=='dti_mfb':
	
		subjects=list(compress(subjects,dti_mfb_idx))
		gi=list(compress(gi,dti_mfb_idx))

	# elif task=='relapse_6months':
	
	# 	subjects=list(compress(subjects,relapse6mo_idx))
	# 	gi=list(compress(gi,relapse6mo_idx))

	# elif task=='nonrelapse_6months':
	
	# 	subjects=list(compress(subjects,relapse6mo_idx))
	# 	gi=list(compress(gi,relapse6mo_idx))

	# if desired, return only controls or patients ids
	if str(group)=='controls' or str(group)=='0':
		idx = [i for i, x in enumerate(gi) if x == 0]
		gi = [gi[i] for i in idx]
		subjects = [subjects[i] for i in idx]
	
	if str(group)=='patients' or str(group)=='1':
		idx = [i for i, x in enumerate(gi) if x > 0]
		gi = [gi[i] for i in idx]
		subjects = [subjects[i] for i in idx]


	# return subjects and gi
	return subjects, gi


# def getsubs_claudia(task=''):

# 	# define subjects and gi lists
# 	subjects = [] # list of subject ids
# 	gi = []			# list of corresponding group indices

# 	# define path to subject file
# 	subjFile = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data','subjects_list','subjects')
	
# 	with open(subjFile, 'r') as f:
# 		next(f) # omit header line
# 		for line in f:	
# 			subjects.append(line[0:line.find(',')])
# 			gi.append(line[line.find(',')+1:line.find(',')+3])
				
	
# 	# if a task string is given, return subset of subjects for that task
# 	if task: 

# 		omit_subs = [] # list of subjects to omit specific to this task
		
# 		omitSubjsFile = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data','subjects_list','omit_subs_'+task)
	
# 		with open(omitSubjsFile, 'r') as f:
# 			next(f) # omit header line
# 			for line in f:	
# 				omit_subs.append(line[0:line.find(',')])
			
# 		for omit_sub in omit_subs:
# 			if omit_sub in subjects:
# 				gi.pop(subjects.index(omit_sub))
# 				subjects.remove(omit_sub)
	

# 	# make group indices integers
# 	gi = map(int,gi)		


# 	# return subjects and gi
# 	return subjects, gi



if __name__ == "__main__":
	subjects,gi = getsubs(sys.argv[1])
	print ' '.join(subjects)

#if __name__ == "__main__":
#	subjects,gi = getsubs(sys.argv[1])
#	print subjects
#	print gi


#	if __name__ == "__main__":
 #   	getsubs()
 # getsubs(int(sys.argv[1]))


#!/usr/bin/python

# script to return subject ids for subjects in cue fmri experiment. To use in a python script, do: 

		# from getCueSubjects import getsubs
		# subjects,gi = getsubs()

# returns subjects as a list of subject id strings and gi is a group index of group membership 
# (0 for controls, 1 for patients). Alternatively, do subjsA,_ = getsubs(0)	to return just 
# control subjects, or: subjsB,_ = getsubs(1) for just patients.   

import os,sys


#########  get main data directory and subjects to process	
def getMainDir():

	# get full path for main project directory & return to current dir
	# this is a jenky work around to deal with running scripts from different directories
	# and running this from differnt computers that have different paths to the main project dir
	
	currentdir=os.getcwd()

	os.chdir('../')

	# move up 1 more level if still in scripts dir
	temp=os.path.split(os.getcwd())
	if temp[1]=='scripts':
		os.chdir('../')

	main_dir=os.getcwd()
	os.chdir(currentdir)

	return main_dir


def getsubs(task='',group='all'):


	# define subjects and gi lists
	subjects = [] # list of subject ids
	gi = []			# list of corresponding group indices

	main_dir=getMainDir()

	# data directory
	data_dir=main_dir+'/data'

	# define path to subject file
	subjFile = os.path.join(data_dir,'subjects_list','subjects')
	
	with open(subjFile, 'r') as f:
		next(f) # omit header line
		for line in f:	
			subjects.append(line[0:line.find(',')])
			gi.append(line[line.find(',')+1:line.find(',')+3])
				
	
	# if a task string is given, return subset of subjects for that task
	if task: 

		omit_subs = [] # list of subjects to omit specific to this task
		
		omitSubjsFile = os.path.join(data_dir,'subjects_list','omit_subs_'+task)
	
		with open(omitSubjsFile, 'r') as f:
			next(f) # omit header line
			for line in f:	
				omit_subs.append(line[0:line.find(',')])
			
		for omit_sub in omit_subs:
			if omit_sub in subjects:
				gi.pop(subjects.index(omit_sub))
				subjects.remove(omit_sub)
	

	# make group indices integers
	gi = map(int,gi)		


	# if desired, return only controls or patients ids
	if str(group)=='controls' or str(group)=='0':
		idx = [i for i, x in enumerate(gi) if x == 0]
		gi = [gi[i] for i in idx]
		subjects = [subjects[i] for i in idx]
	
	if str(group)=='patients' or str(group)=='1':
		idx = [i for i, x in enumerate(gi) if x == 1]
		gi = [gi[i] for i in idx]
		subjects = [subjects[i] for i in idx]



	# return subjects and gi
	return subjects, gi


def getsubs_claudia(task=''):

	# define subjects and gi lists
	subjects = [] # list of subject ids
	gi = []			# list of corresponding group indices

	# define path to subject file
	subjFile = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data','subjects_list','subjects')
	
	with open(subjFile, 'r') as f:
		next(f) # omit header line
		for line in f:	
			subjects.append(line[0:line.find(',')])
			gi.append(line[line.find(',')+1:line.find(',')+3])
				
	
	# if a task string is given, return subset of subjects for that task
	if task: 

		omit_subs = [] # list of subjects to omit specific to this task
		
		omitSubjsFile = os.path.join(os.path.expanduser('~'),'cueexp_claudia','data','subjects_list','omit_subs_'+task)
	
		with open(omitSubjsFile, 'r') as f:
			next(f) # omit header line
			for line in f:	
				omit_subs.append(line[0:line.find(',')])
			
		for omit_sub in omit_subs:
			if omit_sub in subjects:
				gi.pop(subjects.index(omit_sub))
				subjects.remove(omit_sub)
	

	# make group indices integers
	gi = map(int,gi)		


	# return subjects and gi
	return subjects, gi




#if __name__ == "__main__":
#	subjects,gi = getsubs(sys.argv[1])
#	print subjects
#	print gi


#	if __name__ == "__main__":
 #   	getsubs()
 # getsubs(int(sys.argv[1]))


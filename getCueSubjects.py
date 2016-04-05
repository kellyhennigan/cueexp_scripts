#!/usr/bin/python


import os,sys


def getsubs(group='all'):

	# define subjects and gi lists
	subjects = [] # list of subject ids
	gi = []			# list of corresponding group indices

	# get base directory (this may differ for each computer
	basedir = os.path.join(os.path.expanduser('~'),'cueexp')

	
	with open(os.path.join(basedir,'data','subjects'), 'r') as f:
		next(f) # omit header line
		for line in f:	
			subjects.append(line[0:line.find(',')])
			gi.append(line[line.find(',')+1:line.find(',')+3])
				
	
			
	# omit any subjects that have been commented out
	omit_idx=[]
	for i, s in enumerate(subjects):	
		if '#' in s:
			omit_idx.append(i)
	
	for i in sorted(omit_idx, reverse=True): 
		del subjects[i]
		del gi[i]

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


def getsubs_claudia(group='all'):

	# define subjects and gi lists
	subjects = [] # list of subject ids
	gi = []			# list of corresponding group indices

	# get base directory (this may differ for each computer
	basedir = os.path.join(os.path.expanduser('~'),'cueexp_claudia')

	
	with open(os.path.join(basedir,'data','subjects'), 'r') as f:
		next(f) # omit header line
		for line in f:	
			subjects.append(line[0:line.find(',')])
			gi.append(line[line.find(',')+1:line.find(',')+3])
				

	# omit any subjects that have been commented out
	omit_idx=[]
	for i, s in enumerate(subjects):	
		if '#' in s:
			omit_idx.append(i)
	
	for i in sorted(omit_idx, reverse=True): 
		del subjects[i]
		del gi[i]

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

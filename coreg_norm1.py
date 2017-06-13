#!/usr/bin/python

# filename: coreg_norm1.py
# script to do the following with anatomical data: 

# skull-strip
# estimate xform to tlrc space
# apply xform 
# estimate xform between t1 and functional native space (use 1st vol from each task, bc that has best contrast)
# apply that func2t1 xforms to 1st task vols


#### TO DO: 
# add error checks to see if files actually exist
# plot out QA figs


import os,sys,glob


##################### define global variables #################################
# EDIT AS NEEDED:


data_dir = os.path.join(os.path.expanduser('~'),'%s','data')

in_dir = os.path.join(data_dir,'%s','raw')  # first %s is data_dir & 2nd is subject id

out_dir = os.path.join(data_dir,'%s','func_proc')

t1_template = os.path.join(data_dir,'templates','TT_N27.nii') # %s is data_dir
func_template = os.path.join(data_dir,'templates','TT_N27_func_dim.nii') # %s is data_dir

# functional volumes to coreister with t1 in native space using affine xform
tasks = ['cue']


print 'execute commands?'
xc = bool(input('enter 1 for yes, or 0 to only print: '))


# add ants directory to path
cmd = 'export PATH=$PATH:'+os.path.join(os.path.expanduser('~')+'/repos/antsbin/bin')
print cmd+'\n'
os.system(cmd)

###############################################################################
############################### DO IT #########################################
###############################################################################


#########  print commands & execute if xc is True, otherwise just print them
def doCommand(cmd):
	
	print cmd+'\n'
	if xc is True:
		os.system(cmd)


#########  get subjects to process	
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
	


	
#########  convert file from afni to nifti format & delete afni file
def convertToNifti(inFile,out_str=''):

	# use inFile's prefix as out_str by default, + '_tlrc' if in tlrc space
	if not out_str:
		a=inFile.split('+') # split inFile to get fname & space string
		out_str = a[0] # use inFile's prefix for out file name
		if a[1][0:4]=='tlrc' and a[0].find('tlrc')==-1:
			out_str = out_str+'_tlrc'
	
	outFile = out_str+'.nii.gz'

	cmd = ('3dAFNItoNIFTI -prefix '+outFile+' '+inFile)
	doCommand(cmd)

	# delete inFile in afni format
	cmd = ('rm '+inFile+'*')
	doCommand(cmd)


	return outFile




if __name__ == '__main__':

	#base_dir = whichBaseDir()
	base_dir = 'cueexp'
	subjects = whichSubs(base_dir)
	
	for subject in subjects:

		
		print 'WORKING ON SUBJECT '+subject+'\n'
		
			
		# define subject's raw & pre-processed directories 
		this_inDir = in_dir % (base_dir,subject)
		this_outDir =  out_dir % (base_dir,subject)
		
		
		# make out & xf directories if doesn't already exist 
		if os.path.exists(this_outDir):
			print '\nsubj dir already exists...\n'
		else:	
			print 'making new dir: '+this_outDir+'\n'
			os.makedirs(this_outDir)
		
		# cd to subject's outDir, and make 'xfs' dir if it doesn't exist
		print 'cd '+this_outDir+'\n'
		os.chdir(this_outDir)		

		# also make a 'xfs' dir within out dir or xforms 		
		if os.path.exists('xfs'):
			print '\ndir xfs already exists...\n'
		else:
			print 'making new dir, xfs...\n'
			os.makedirs('xfs')


		######################### T1 <-> TLRC PIPELINE #########################

		# skull-strip anatomy 
		t1_ns_str = 't1_ns'
		t1_ns_file = t1_ns_str+'.nii.gz'

		if os.path.isfile('t1_ns.nii.gz'):
			print '\n skull stripped t1 file '+t1_ns_file+' already exists...\n'
		else:	
			cmd = '3dSkullStrip -prefix '+t1_ns_file+' -input '+os.path.join(this_inDir,'t1_raw.nii.gz')
			doCommand(cmd)


		########## ANTS ########

		# estimate transform from t1 native space to tlrc template
		xf_str = 'xfs/t12tlrc_xform_'
		xf_affine_file = xf_str+'Affine.txt'
		xf_warp_file = xf_str+'Warp.nii.gz'
		t1_tlrc_file = 't1_tlrc.nii.gz'

		if (os.path.isfile(xf_affine_file) and os.path.isfile(xf_warp_file)):
			print '\n ants xform files already exist...\n'
		else:	
			cmd = ('ANTS 3 -m CC['+t1_template % (base_dir)+','+t1_ns_file+',1,4] '
			'-r Gauss[3,0] -o '+xf_str+' -i 100x50x30x10 -t SyN[.25]')
			doCommand(cmd)

		# apply transform to put t1 in tlrc space
		if os.path.isfile(t1_tlrc_file):
			print '\n ants xformed t1_tlrc file already exists...\n'
		else:	
			cmd =('WarpImageMultiTransform 3 t1_ns.nii.gz '+t1_tlrc_file+
			' '+xf_warp_file+' '+xf_affine_file)
			doCommand(cmd)

			# change header to play nice with afni
			cmd = '3drefit -view tlrc -space tlrc '+t1_tlrc_file
			doCommand(cmd)

		
		
		########## AFNI ########

		# estimate & apply xform from t1 native space to tlrc template 
		t1_tlrc_afni_str = 't1_tlrc_afni'
		t1_tlrc_afni_file = t1_tlrc_afni_str +'.nii.gz'

		if os.path.isfile(t1_tlrc_afni_file):
			print '\n afni xformed t1_tlrc_afni file already exists...\n'
		else:
			cmd =('@auto_tlrc -no_ss -base '+t1_template % (base_dir)+' -suffix _afni '
			'-input '+t1_ns_file)
			doCommand(cmd)

			# clean up/rename files 
			cmd = ('gzip '+t1_ns_str+'_afni.nii; '
			'mv '+t1_ns_str+'_afni.nii.gz '+t1_tlrc_afni_file+'; '
			'mv '+t1_ns_str+'_afni.Xat.1D xfs/t12tlrc_xform_afni; '
			'mv '+t1_ns_str+'_afni.nii_WarpDrive.log xfs/t12tlrc_xform_afni.log; '
			'rm '+t1_ns_str+'_afni.nii.Xaff12.1D')
			doCommand(cmd)


		###################### FUNC <-> T1 PIPELINE ############################
	

		# get 1st volume of functional data & skullstrip
		for task in tasks:
			

			vol1_file = os.path.join(this_inDir,'vol1_'+task+'.nii.gz')
			vol_ns_str = 'vol1_'+task+'_ns'
			vol_ns_file = vol_ns_str+'.nii.gz'
			
			 # pull out 1st vol from 1st scan of this task
			if os.path.isfile(vol1_file):
				print '\nfile '+vol1_file+' already exists...\n'
			else:	
				cmd = ('3dTcat -output '+vol1_file+' '
				+os.path.join(this_inDir,task+'1.nii.gz[0]'))
				doCommand(cmd)


			# skull strip 		
			if os.path.isfile(vol_ns_file):
				print '\nfile '+vol_ns_file+' already exists...\n'
			else:	
				cmd = ('3dSkullStrip -prefix '+vol_ns_file+' '
				'-input '+os.path.join(this_inDir,'vol1_'+task+'.nii.gz'))
				doCommand(cmd)
		

			########## ANTS ########
		
			# estimate affine func vol > t1 
			task_xf_str = 'xfs/'+task+'2t1_xform_'
			task_xf_file = task_xf_str+'Affine.txt'
			task_tlrc_file = 'vol1_'+task+'_tlrc.nii.gz'
			
			print '\n task_xf_file: '+task_xf_file+'\n'

			if os.path.isfile(task_xf_file):
				print '\n ants xform file '+task_xf_file+' already exists...\n'
			else:	
				cmd =('ANTS 3 -m MI[t1_ns.nii.gz,'+vol_ns_file+',1,32] '
				'-o '+task_xf_str+' -i 0 --rigid-affine true')
				doCommand(cmd)


			# apply xforms to put func ref vol in tlrc template space
			if os.path.isfile(task_tlrc_file):
				print '\n ants xformed file '+task_tlrc_file+' already exists...\n'
			else:	
				cmd =('antsApplyTransforms -d 3 -e 3 -i '+vol_ns_file+' '
				'-r '+func_template % (base_dir)+' ' 
				'-o '+task_tlrc_file+' --float '
				'-t '+task_xf_file+' '+xf_affine_file+' '+xf_warp_file)
				doCommand(cmd)

				# change header to play nice with afni
				cmd = '3drefit -view tlrc -space tlrc '+task_tlrc_file
				doCommand(cmd)
	

			########## AFNI ########

			# do estimation & apply with this one command:
			task_tlrc_afni_str = 'vol1_'+task+'_tlrc_afni'
			task_tlrc_afni_file = task_tlrc_afni_str+'.nii.gz'

			if os.path.isfile(task_tlrc_afni_file):
				print '\n afni xformed file '+task_tlrc_afni_file+' already exists...\n'
			else:	
				cmd =('align_epi_anat.py -epi2anat -epi '+vol_ns_file+' '
				'-anat '+t1_ns_file+' -epi_base 0 -tlrc_apar '+t1_tlrc_afni_file+' '
				'-epi_strip None -anat_has_skull no')
				doCommand(cmd)


				# convert to func vol in tlrc space to nifti format: 	
				convertToNifti(vol_ns_str+'_tlrc_al+tlrc',task_tlrc_afni_str)


				# clean up/rename files 
				cmd =('mv '+t1_ns_str+'_al_mat.aff12.1D xfs/t12'+task+'_xform_afni; '
				'mv '+vol_ns_str+'_al_mat.aff12.1D xfs/'+task+'2t1_xform_afni; '
				'mv '+vol_ns_str+'_al_tlrc_mat.aff12.1D xfs/'+task+'2tlrc_xform_afni; '
				'rm '+vol_ns_str+'_al_reg_mat.aff12.1D; '
				'rm '+vol_ns_str+'_al+orig*')
				doCommand(cmd)

		
		print 'FINISHED SUBJECT '+subject












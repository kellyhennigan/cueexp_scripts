#!/bin/bash

##############################################

# usage: pre-processing pipeline for MID data 
# in cue reactivity project

# written by Kelly, 27-Jun-2018, 
# based on Brian's & Nick's c shell scripts

# assumes the directory structure is: 
# $dataDir/$subjid/raw (e.g. "~/cuefmri/data/jj180618/raw")

# assumes there are 2 runs of mid data in the raw directory
# named "mid1.nii.gz" and "mid2.nii.gz"

##############################################


########################## DEFINE VARIABLES #############################


# dataDir is the parent directory of subject-specific directories
dataDir='/Users/kelly/cueexp/data' 


# subject ids to process
subjects='jj180618'  # e.g. 'jj180618 ab180619 cd180620'


runs='2' # 2 runs of data

############################# RUN IT ###################################

for subject in $subjects
do
	
	echo WORKING ON SUBJECT $subject

	# subject input & output directories
	inDir=$dataDir/$subject/raw
	outDir=$dataDir/$subject/func_proc2


	# make outDir & cd to it: 
	mkdir $outDir
	cd $outDir


	for run in $runs
	do

		echo WORKING ON RUN $RUN

		# drop the first 6 volumes to allow longitudinal magentization (t1) to reach steady state
		3dTcat -output mid$run.nii.gz $inDir/mid$run.nii.gz[6..$]


		# correct for slice time differences
		3dTshift -prefix tmid$run.nii.gz -slice 0 -tpattern altplus mid$run.nii.gz


		# pull out a reference volume for motion correction and for later checking out coregistration between functional and structural data 
		if [ $run='1' ];
		then
			3dTcat -output ref_mid.nii.gz tmid1.nii.gz[4]
		fi


		# motion correction & saves out the motion parameters in file, 'mid1_vr.1D' 
		3dvolreg -Fourier -twopass -zpad 4 -dfile vr_mid$run.1D -base ref_mid.nii.gz -prefix mtmid$run.nii.gz tmid$run.nii.gz


		# create a “censor vector” that denotes bad movement volumes with a 0 and good volumes with a 1
		# to be used later for glm estimation and making timecourses
		1d_tool.py -infile vr_mid$run.1D[1..6] -show_censor_count -censor_prev_TR -censor_motion 0.5 mid$run


		# smooth data with a 4 mm full width half max gaussian kernel
		3dmerge -1blur_fwhm 4 -doall -quiet -prefix smtmid$run.nii.gz mtmid$run.nii.gz


		# calculate the mean timeseries for each voxel
		3dTstat -mean -prefix mean_mid$run.nii.gz smtmid$run.nii.gz


		# convert voxel values to be percent signal change
		cmd="3dcalc -a smtmid${run}.nii.gz -b mean_mid${run}.nii.gz -expr \"((a-b)/b)*100\" -prefix psmtmid${run}.nii.gz -datum float"
		echo $cmd	# print it out in terminal 
		eval $cmd	# execute the command
	

		# # high-pass filter the data 
		3dFourier -highpass 0.011 -prefix fpsmtmid$run.nii.gz psmtmid$run.nii.gz

	
		echo DONE WITH RUN $RUN


	done # run loop


	# # concatenate pre-processed data for runs 1 & 2
	# 3dTcat -output pp_mid.nii.gz fpsmtmid1.nii.gz fpsmtmid2.nii.gz


	# # clear out any pre-existing concatenated motion files 
	# rm mid_vr.1D; rm mid_censor.1D; rm mid_enorm.1D


	# # concatenate motion files 
	# cat  vr_mid1.1D vr_mid2.1D >> mid_vr.1D
	# cat  mid1_censor.1D mid2_censor.1D >> mid_censor.1D
	# cat  mid1_enorm.1D mid2_enorm.1D >> mid_enorm.1D


	# # remove intermediate files 
	# # NOTE: ONLY DO THIS ONCE YOU'RE CONFIDENT THAT THE PIPELINE IS WORKING! 
	# # (because you may want to view intermediate files to troubleshoot the pipeline)
	# #rm *mid2*
	# #rm *mid1*


done # subject loop




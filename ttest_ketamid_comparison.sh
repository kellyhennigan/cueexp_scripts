#!/bin/bash

##############################################

# usage: do t-tests on single subject GLMs

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories
cd ..
mainDir=$(pwd)
dataDir=$mainDir/data

resultsDir=$dataDir/results_mid_afni

# mask file
maskfile=$dataDir/templates/bmask.nii


# labels of sub-bricks to test
labels=('Full_R^2' 'ant#0_Coef' 'gvnant#0_Coef' 'lvnant#0_Coef' 'out#0_Coef' 'gvnout#0_Coef' 'nvlout#0_Coef')

outlabels=('ZR2' 'Zant' 'Zgvnant' 'Zlvnant' 'Zout' 'Zgvnout' 'Znvlout')


# suffix to add to outfiles to denote something about the test version? 
outsuffix='_baseline_iter3'
##########################################################################################


cd $resultsDir

for i in ${!labels[@]};
do 

	label=${labels[$i]}; # this func run 
	outlabel=${outlabels[$i]}; # string for anatomy file corresponding to func run

	echo label: $label
	echo outlabel: $outlabel

	echo -e "\n\nWORKING ON $label\n"

	# get volume index; THIS ASSUMES ITS THE SAME VOL INDEX FOR ALL SUBJECTS
	volnum=$(3dinfo -label2index ${label} tm160117_glm+tlrc.)

	########### t-test command
	outname=$outlabel$outsuffix
	cmd="3dttest++ -prefix ${outname} -mask ${maskfile} -toz -setA 
		'er170121_glm+tlrc.[${volnum}]'
		'kn160918_glm+tlrc.[${volnum}]'
		'ie151020_glm+tlrc.[${volnum}]'
		'dw151003_glm+tlrc.[${volnum}]'
		'aa151010_glm+tlrc.[${volnum}]'
		'zl150930_glm+tlrc.[${volnum}]' "

		# add -Clustsim to this command to determine correction for multiple comparisons 

	echo $cmd	# print it out in terminal 
	eval $cmd	# execute the command

	echo -e "\ndone with ttest file: $outname\n"

done # labels



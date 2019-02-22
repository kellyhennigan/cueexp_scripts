#!/bin/bash

##############################################

# usage: download raw data using flywheel CLI

# WARNING: IF A SCAN WAS RE-RUN, THIS SCRIPT WILL DO THE WRONG THING 
# AND TAKE JUST THE FIRST (BAD) SCAN. THIS REQUIRES CAREFULLY MANUAL 
# CHECKING OF THE SCANS!!!! 
# (I haven't figured out how to correct this with flywheel CLI yet...)

	
# ALSO NOTE: before running this, I need to log into flywheel first:
# fw login cni.flywheel.io:GM52n5tciGhJHBZX6C

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories
dataDir='/Users/kelly/cueexp/data' 


# subject ids to process
subject='lm181213'  # e.g. '301 308 309'

cniID='19342'


# set to 0 to skip a file
t1num=3
cuenum=6
mid1num=7
mid2num=8
midi1num=9
midi2num=10
dwinum=13

#########################################################################
############################# RUN IT ###################################
#########################################################################

	
echo WORKING ON SUBJECT $subject

# subject input & output directories
inDir=$dataDir/$subject/raw


# make inDir & cd to it: 
mkdir $inDir
cd $inDir


# t1 file
if [ "$t1num" != "0" ]; then
cmd="fw download \"knutson/cuefmri/${cniID}/T1w .9mm BRAVO/files/${cniID}_${t1num}_1.nii.gz\" -o t1_raw.nii.gz"
eval $cmd	# execute the command
fi


# cue data file
if [ "$cuenum" != "0" ]; then
cmd="fw download \"knutson/cuefmri/${cniID}/BOLD EPI 2.9mm 2sec CUE/files/${cniID}_${cuenum}_1.nii.gz\" -o cue1.nii.gz"
eval $cmd	# execute the command
fi


# MID data files
if [ "$mid1num" != "0" ]; then
cmd="fw download \"knutson/cuefmri/${cniID}/BOLD EPI 2.9mm 2sec MID_1/files/${cniID}_${mid1num}_1.nii.gz\" -o mid1.nii.gz"
eval $cmd	# execute the command
fi

if [ "$mid2num" != "0" ]; then
cmd="fw download \"knutson/cuefmri/${cniID}/BOLD EPI 2.9mm 2sec MID_2/files/${cniID}_${mid2num}_1.nii.gz\" -o mid2.nii.gz"
eval $cmd	# execute the command
fi


# MIDI data files
if [ "$midi1num" != "0" ]; then
cmd="fw download \"knutson/cuefmri/${cniID}/BOLD EPI 2.9mm 2sec MIDI_1/files/${cniID}_${midi1num}_1.nii.gz\" -o midi1.nii.gz"
eval $cmd	# execute the command
fi

if [ "$midi2num" != "0" ]; then
cmd="fw download \"knutson/cuefmri/${cniID}/BOLD EPI 2.9mm 2sec MIDI_2/files/${cniID}_${midi2num}_1.nii.gz\" -o midi2.nii.gz"
eval $cmd	# execute the command
fi

# DWI files
if [ "$dwinum" != "0" ]; then

cmd="fw download \"knutson/cuefmri/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.nii.gz\" -o dwi.nii.gz"
eval $cmd	# execute the command

cmd="fw download \"knutson/cuefmri/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.bvec\" -o bvec"
eval $cmd	# execute the command

cmd="fw download \"knutson/cuefmri/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.bval\" -o bval"
eval $cmd	# execute the command

fi

echo DONE


	



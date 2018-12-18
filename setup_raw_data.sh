#!/bin/bash

##########################################

# usage: get raw data off nims server for addictmid analysis 

# 



########################## DEFINE VARIABLES #############################


# 
nimsExpDir='/nimsfs/knutson/cuefmri/'	# experiment main dir on nims
dataDir='/Volumes/pegasus/addictmid/data'	# main data dir 


subject='cd171130'				# subject id (string)
exam_no='16605'				# cni exam number (string)

# define the scan numbers associated with each scan 
# NOTE: MANUALLY DOUBLE CHECK THAT THESE NUMBERS ARE CORRECT THROUGH THE NIMS INTERFACE!!
t1=3
mid1=7 # run 1 of mid
mid2=8 # run 2 of mid


############################# RUN IT ###################################


echo COPYING OVER RAW DATA FOR SUBJECT $subject

# create subject's raw directory and cd to it
subjDir=$dataDir/$subject
mkdir $subjDir
rawDir=$subjDir/raw
mkdir $rawDir
cd $rawDir

# copy over t1 
cmd="scp hennigan@cnic2:${nimsExpDir}/*_${exam_no}/${exam_no}_${t1}_*/${exam_no}_${t1}* t1_raw.nii.gz"
eval $cmd

# copy over MID data 
cmd="scp hennigan@cnic2:${nimsExpDir}/*_${exam_no}/${exam_no}_${mid1}_*/${exam_no}_${mid1}* mid1.nii.gz"
eval $cmd

cmd="scp hennigan@cnic2:${nimsExpDir}/*_${exam_no}/${exam_no}_${mid2}_*/${exam_no}_${mid2}* mid2.nii.gz"
eval $cmd


echo DONE WITH SUBJECT $subject



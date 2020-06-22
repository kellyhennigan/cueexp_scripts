#!/bin/bash

##############################################

# usage: download raw data using flywheel CLI

# WARNING: IF A SCAN WAS RE-RUN, THIS SCRIPT WILL DO THE WRONG THING 
# AND TAKE JUST THE FIRST (BAD) SCAN. THIS REQUIRES CAREFULLY MANUAL 
# CHECKING OF THE SCANS!!!! 
# (I haven't figured out how to correct this with flywheel CLI yet...)

# ALSO NOTE: before running this, I need to log into flywheel first:
# fw login cni.flywheel.io:faKngx7782veTjZPM9

# code to iterate through 2 arrays: 
# A1=( "subj1" "subj2" "subj3" "subj4" )
# A2=( "s1" "s2" "s3" "s4" )
# for ((i=0;i<4;++i)); do
# printf "%s and then %s\n" "${A1[i]}" "${A2[i]}"
# done


# ga181112	19072
# gm181112	19073
# ks181114	19095
# tr181126	19179
# id181126	19180
# ap181126	19181
# pm181126	19182
# js181128	19200

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories;
# path should be relative to where this script is saved
dataDir='../data' 


# subject ids to process
echo enter subject ID e.g., ab180123: 
read subject
echo enter CNI subject ID e.g., 19070: 
read cniID
echo you entered subject ID: $subject and CNI subject ID: $cniID

# set to 0 to skip a file, otherwise set to 1
gett1w=1
getcue=1
getmid1=1
getmid2=1
getmidi1=1
getmidi2=1
getdwi=1

#########################################################################
############################# RUN IT ###################################
#########################################################################

cmd="fw login cni.flywheel.io:faKngx7782veTjZPM9"
eval $cmd
	
echo WORKING ON SUBJECT $subject

# subject directory 
subjDir=$dataDir/$subject
if [ ! -d "$subjDir" ]; then
	mkdir $subjDir
fi 
cd $subjDir

# raw, ROI, and t1 directories
if [ ! -d "raw" ]; then
	mkdir raw
fi 
if [ ! -d "ROIs" ]; then
	mkdir ROIs
fi 
if [ ! -d "t1" ]; then
	mkdir t1
fi 

# cd to subject's raw dir
cd raw

################################################################################


########### t1-weighted file
if [ "$gett1w" != "0" ]; then

	# check how many files there are: 
	scanStr='T1w .9mm BRAVO'
	outFilePath='t1w_raw.nii.gz'
	
	# cmd="fw ls \"knutson/cuefmri/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"

	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
		#	cmd="fw ls \"knutson/cuefmri/${cniID}\" --ids | grep '${scanStr}'"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
		
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
	#		cmd="fw ls \"knutson/cuefmri/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
	
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
	#	cmd="fw ls \"knutson/cuefmri/${cniID}/${scanID}/files\" | grep 'nii'" 
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
	
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr



######### cue data file
if [ "$getcue" != "0" ]; then

	# check how many files there are: 
	scanStr='BOLD EPI 2.9mm 2sec CUE'
	outFilePath='cue1.nii.gz'
	
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr





######### mid1 data file
if [ "$getmid1" != "0" ]; then

	# check how many files there are: 
	scanStr='BOLD EPI 2.9mm 2sec MID_1'
	outFilePath='mid1.nii.gz'
	
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr




######### mid2 data file
if [ "$getmid2" != "0" ]; then

	# check how many files there are: 
	scanStr='BOLD EPI 2.9mm 2sec MID_2'
	outFilePath='mid2.nii.gz'
	
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr





######### midi1 data file
if [ "$getmidi1" != "0" ]; then

	# check how many files there are: 
	scanStr='BOLD EPI 2.9mm 2sec MIDI_1'
	outFilePath='midi1.nii.gz'
	
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr




######### midi2 data file
if [ "$getmidi2" != "0" ]; then

	# check how many files there are: 
	scanStr='BOLD EPI 2.9mm 2sec MIDI_2'
	outFilePath='midi2.nii.gz'
	
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr




############# DWI files
if [ "$dwinum" != "0" ]; then

	# check how many files there are: 
	scanStr='DTI 2mm b2500 96dir1'
	outFilePath=dwi.nii.gz
	
	cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

		# get bval and bvec files too:
		outFilePath=bval
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'bval'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

		outFilePath=bvec
		cmd="fw ls \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/files\" | grep 'bvec'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/cuefmri/ex${cniID}/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

	fi

fi

echo done with $scanStr
	

ls *
	




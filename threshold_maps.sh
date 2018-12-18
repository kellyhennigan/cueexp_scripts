#!/bin/bash

# quick and dirty script for thresholding and clustering brain maps. 
# this script does the following: 
	# - applies a voxelwise and cluster level threshold to brain maps, 
	# - saves out the thresholded brain map along with a .txt file print out w/cluster coords, 
	# - concatenates all brainmaps from the same contrast into 1 .nii file, 
	# - calls afni's whereami function to get brain region labels of clusters, 
	# - saves out a text file ('${outname}_cl_info') that contains each cluster's peak brain region location, x,y,z coords, peak z value, and # of voxels in the cluster
	# - puts all the new files into a sub-folder or the results directory, 
	# - adds an afni startup script and underlay volume to the new sub directory for easier afni viewing


# for 2-sided tests, here are Z scores corresponding to the following p values: 

# p < .05;  Z= ± 1.9600
# p < .01;  Z= ± 2.5758
# p < .005; Z= ± 2.8070
# p < .001; Z= ± 3.2905


############################################################################## 
########################## DEFINE VARIABLES 

#results_dir='/Users/kelly/cueexp/data/results_cue_afni' # results directory
results_dir='/Users/kelly/cueexp/data/results_mid_afni' # results directory

Z_thresh='3.2905'   # desired voxelwise Z-score threshold

#cl_thresh='23'		# desired cluster size threshold
cl_thresh='5'		# desired cluster size threshold

NNx='1' # nearest neighbor cluster connectivity: 1 means voxels must have faces touching, 2 for edges touching, 3 for corners touching

#flist='Zdrug-neutral Zfood-neutral Zdrug-food Zdrugs Zfood Zneutral' # names of files to threshold, minus the file suffix
#flist='Zdrugs Zfood Zneutral' # names of files to threshold 
flist='Zgvnant Zgvnout Zlvnant Znvlout' # names of files to threshold 

fsuffix='+tlrc'. # (if files end in "+tlrc")
#fsuffix='.nii.gz' # (if files end in ".nii.gz")

vols='1 3 5' 	# volume indices that contain Z-scores in the above files; note that this should be zero indexed (i.e., first volume is 0, etc.)
#vols='0' 		

afnistartfile='/Users/kelly/cueexp/data/results_mid_afni/.afni.startup_script' # path to afni startup script to copy into new dir

underlayfile='/Users/kelly/cueexp/data/results_mid_afni/TT_N27.nii' # path to underlay file to copy into new dir

############################################################################## 
############################# DO IT

# cd to results directory 
cd $results_dir
echo working directory: pwd

# make a new dir to contain new thresholded maps and related files 
out_dir="threshmaps_cl${cl_thresh}_Z${Z_thresh}"
mkdir $out_dir
echo "files will be saved out to new directory, ${out_dir}"


for fname in $flist 
do
	echo "processing file, $fname"

	allvolnames="" # this will be a string with all volume file names 

	for vol in $vols
	do
		
		vol_label=$(3dinfo -label ${fname}${fsuffix}[${vol}]) 	# e.g., "SetA_Zscr"
		#echo $vol_label

		outname="${fname}_${vol_label}" 	# (e.g., "Zfood_SetA_Zscr")
		#echo $outname

		cmd="3dclust -prefix ${out_dir}/${outname}.nii -2thresh -${Z_thresh} ${Z_thresh} -NN${NNx} ${cl_thresh} ${fname}${fsuffix}[${vol}] > ${out_dir}/${outname}"
		# e.g., 3dclust -prefix outdir/Zneutral_SetB_Zscr.nii -2thresh -3.2905 3.2905 -NN1 10 Zneutral+tlrc[5] > outdir/Zneutral_SetB_Zscr
		echo $cmd	# print it out in terminal 
		eval $cmd	# execute the command
		
		allvolnames="${allvolnames}${outname}.nii "

		# cd to outdir
		cd $out_dir

		# saves out cluster labels regions to file (long form)
		cmd="whereami -coord_file ${outname}[13,14,15] -atlas TT_Daemon > ${outname}_cl_labels_long"
		echo $cmd	# print it out in terminal 
		eval $cmd	# execute the command
		

		# create a new file to hold desired cluster info w/header 
		cmd="awk 'BEGIN{printf \"Region\tx\ty\tz\tPeak Z\tVoxels\n\"}' > ${outname}_cl_info"
		echo $cmd	# print it out in terminal 
		eval $cmd	# execute the command
	

		# concatenates all desired info into 1 file
		cmd="paste <(grep 'Focus point:' ${outname}_cl_labels_long | cut -d ':' -f 2-) <(grep -v '#' ${outname} | awk '{printf \"%.0f\t%.0f\t%.0f\t%.3f\t%d\n\", \$14*-1, \$15*-1, \$16, \$13, \$1}') >> ${outname}_cl_info"
		echo $cmd	# print it out in terminal 
		eval $cmd	# execute the command
		
		# cd back to results dir
		cd ..

	done 	# vols

	# echo $allvolnames
	
	# concatenate brainmaps from the same contrast into 1 .nii file and then delete individual files 
	cd $out_dir
	cmd="3dTcat -prefix ${fname}.nii ${allvolnames}"
	# e.g. 3dTcat -prefix Zfood-neutral.nii Zfood-neutral_SetA-SetB_Zscr.nii Zfood-neutral_SetA_Zscr.nii Zfood-neutral_SetB_Zscr.nii
	echo $cmd	# print it out in terminal 
	eval $cmd	# execute the command
	rm ${allvolnames}


	cd ..

done	# files in flist

# put afni startup viewer commands & underlay in new dir
cp ${afnistartfile} ${out_dir}/	
cp ${underlayfile}  ${out_dir}/





# Processing pipeline for diffusion MRI 

This repository has code for processing diffusion mri (dmri) data collected for the cue fmri. Pipeline focuses on identifying mpfc-Nacc pathways 


## Getting started


### Software requirements 

* [Python 2.7](https://www.python.org/)
* [Matlab](https://www.mathworks.com/products/matlab.html)
* [matlab package, VISTASOFT](https://github.com/vistalab/vistasoft) (dmri pipeline only)
* [spm as a VISTASOFT dependency](https://www.fil.ion.ucl.ac.uk/spm/) (dmri pipeline only)
* [AFQ](https://github.com/yeatmanlab/AFQ) (dmri pipeline only)
* [mrtrix 3.0](http://www.mrtrix.org/) (dmri pipeline only)
* [freesurfer](https://surfer.nmr.mgh.harvard.edu/) (dmri pipeline only)


### Permissions

make sure the user has permission to execute scripts. From a terminal command line, cd to the directory containing these scripts. Then type:
```
chmod 777 *sh
chmod 777 *py
```
to be able to execute them. This only needs to be run once. 



[dMRI pipeline](#dmri-pipeline)

- [Acpc-align t1 data](#acpc-align-t1-data)
- [Run freesurfer recon](#run-freesurfer-recon)
- [Convert freesurfer files to nifti and save out ROI masks](#convert-freesurfer-files-to-nifti-and-save-out-roi-masks)
- [Convert midbrain ROI from standard > native space](#convert-midbrain-roi-from-standard->-native-space)
- [Pre-process diffusion data](#pre-process-diffusion-data)
- [Mrtrix pre-processing steps](#rtrix-pre-processing-steps)
- [Track fibers](#track-fibers)
- [Clean fiber bundles](#clean-fiber-bundles)
- [Save out measurements from fiber bundles cores](#save-out-measurements-from-fiber-bundles-cores)
- [Correlate diffusivity measures with behavioral and functional measures](#correlate-diffusivity-measures-with-behavioral-and-functional-measures)
- [Create density maps of fiber group endpoints](#create-density-maps-of-fiber-group-endpoints)



## pipeline



### Get raw mri data 
from a terminal command line, type:
```
./setup_raw_data.sh
```
this will copy over the raw MRI data from Flywheel into a BIDs-compatible directory structure.

#### output
this should create a directory, **fmrieat/rawdata_bids/subjid** where subjid is the subject id. This directory should contain: 
* func/cue1.nii.gz 		# fMRI data 
* anat/t1w.nii.gz 		# t1-weighted (anatomical) data 
* dwi/dwi.nii.gz		# diffusion MRI data
* dwi/bval				# b-values 
* dwi/bvec				# b-vectors 
* <i>(quantitative t1 scans are saved as well; pipeline for that to be added later)</i> 



### Acpc-align t1 data
In matlab, run:
```
mrAnatAverageAcpcNifti
```
Use GUI to manually acpc-align t1 data 

#### output
Save out acpc-aligned nifti to **cuefmri/t1_acpc.nii.gz**. 


### Run freesurfer recon
From terminal command line, cd to dir with subject's acpc-aligned t1 and run: 
```
recon-all -i t1_acpc.nii.gz -subjid subjid -all
```
This calls freesurfer's recon command to segment brain tissue

#### output
Saves out a bunch of files to directory, **/usr/local/freesurfer/subjects/subjid**.



### Convert freesurfer files to nifti and save out ROI masks
In matlab, run:
```
convertFsSegFiles_script.m
createRoiMasks_script.m
**(also troubleshoot getting mpfc ROI in native space)**
```
To convert freesurfer segmentation files to be in nifti format & save out desired ROI masks based on FS segmentation labels (as it pertains to us here, this gives a NAcc ROI)

#### output
Saves out files to directory, **cuefmri/data/subjid/ROIs**



### Pre-process diffusion data
In Matlab, run:
```
dtiPreProcess_script
```
To do vistasoft standard pre-processing steps on diffusion data.

#### output
Saves out files to directory, **cuefmri/data/subjid/dti96trilin**



### mrtrix pre-processing steps 
From terminal command line, run:
```
python mrtrix_proc.py
```
This script: 
* copies b_file and brainmask to mrtrix output dir
* make mrtrix tensor file and fa map (for comparison with mrvista maps and for QA)
* estimate response function using lmax of 8
* estimate fiber orientation distribution (FOD) (for tractography)

#### output
Saves out files to directory, **cuefmri/data/subjid/dti96trilin/mrtrix**



### Track fibers
From terminal command line, run:
```
python mrtrix_fibertrack.py
```
tracks fiber pathways between 2 ROIs with desired parameters 

##### output
Saves out files to directory, **cuefmri/data/subjid/fibers/mrtrix_fa**



### Clean fiber bundles
In matlab:
```
cleanFibers_script
```
uses AFQ software to iteratively remove errant fibers 

##### output
Saves out fiber group files to directory, **fmrieat/derivatives/subjid/fibers**



### Save out measurements from fiber bundles cores
In matlab:
```
dtiSaveFGMeasures_script & dtiSaveFGMeasures_csv_script
```



### Correlate diffusivity measurements with personality and/or fMRI measures, e.g., impulsivity



### Create density maps of fiber group endpoints 












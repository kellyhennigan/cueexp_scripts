#!/bin/bash

#scp cue_patient_subjects.txt hennigan@sherlock.stanford.edu:/scratch/PI/knutson/cuesvm
for subject in ('cat subjects_list/cue_subjects.txt')
do
    #cd ~/cueexp/data/$subject/func_proc
    #makeVec.py the group_label_trial_onsets.1D
    #mkdir $subject
    #3dAFNItoNIFTI cue_mbnf+tlrc cue_mbnf.nii
    #cp func_proc/pp_cue_tlrc.afni.nii.gz $subject/
    #cp ../drug_trial_onsets.1D $subject/
    scp $subject/func_proc/pp_cue_tlrc_afni_nuisancereg_errts.nii.gz span@vta.stanford.edu:~/cuesvm/$subject/
    #scp drug_trial_onsets_REL.1D hennigan@sherlock.stanford.edu:~/cuesvm/$subject
done
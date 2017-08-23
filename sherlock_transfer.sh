#!/bin/bash

#scp cue_patient_subjects.txt hennigan@sherlock.stanford.edu:/scratch/PI/knutson/cuesvm
for subject in ('cat cue_patient_subjects_relapse.txt')
do
    #cd ~/cueexp/data/$subject
    #makeVec.py the group_label_trial_onsets.1D
    #mkdir $subject
    #3dAFNItoNIFTI cue_mbnf+tlrc cue_mbnf.nii
    #cp func_proc/pp_cue_tlrc.afni.nii.gz $subject/
    #cp ../drug_trial_onsets.1D $subject/
    #scp $subject hennigan@sherlock.stanford.edu:~/cuesvm
    scp drug_trial_onsets_REL.1D hennigan@sherlock.stanford.edu:~/cuesvm/$subject
done
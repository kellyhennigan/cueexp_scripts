#!/bin/bash

for subject in `cat cue_patients_subjects.txt`
do
    cp survival_analysis/${subject}_neutral.nii ${subject}/neutral.nii
    cp survival_analysis/${subject}_food.nii ${subject}/food.nii
    cp survival_analysis/${subject}_drugs.nii ${subject}/drugs.nii
    #head -n 20 $subject/*REL.1D  | tail -n 1  > $subject/relapse.1D
    echo -1 > $subject/relapse.1D
done

for subject in `cat cue_patients_relIn6Mos.txt`
do 
    echo 1 > $subject/relapse.1D
done

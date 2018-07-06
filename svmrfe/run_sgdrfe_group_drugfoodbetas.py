"""
Script to run svmrfe on a given subject with a number of different parameters.

usage: python run_sgdrfe.py [test subject id]
"""
import os
import sys
from sgdrfe import SGDRFE

######################### USER PARAMS #################################
#SUBJECT_BASE_PATH = '/Users/kelly/cueexp/data/' #where we find subj folder
SUBJECT_BASE_PATH = '/home/span/lvta/cuesvm' #where we find subj folder

#SUBJECT_FILE = '/home/span/lvta/cuesvm/cue_patients.txt'
SUBJECT_FILE = '/home/span/lvta/cuesvm/cue_subjects.txt'

# NIFTII = 'pp_cue_tlrc_afni.nii.gz'
# BEHAVIORAL = 'drug_trial_onsets_REL.1D'
# NIFTII_OUT_NAME = 'cue_drug_relapse.nii.gz'
# TRS = [1, 2, 3, 4]
# LAG = 2 # so really we're looking at trs 2+trs = [3, 4] of every trial (1-indexed)

NIFTII = 'drugfood.nii'
#BEHAVIORAL = 'relapse.1D'
BEHAVIORAL = 'group.1D'
NIFTII_OUT_NAME = 'drugbeta_group.nii.gz'
TRS = [1, 2]
LAG = 0 # so really we're looking at trs 2+trs = [3, 4] of every trial (1-indexed)


CLASSIFIERS = ['linearsvc']
# CLASSIFIERS = ['linearsvc', 'elasticnet']
CUT = .05 # throw out the bottom cut % of features every iteration
STOP_THRESHOLD = .005 # stop at this % of features out of what we start with
TEST = False
######################################################################

class Subject(object):
    def __init__(self, name):
        self.name = name
        self.path = os.path.join(SUBJECT_BASE_PATH, name)
    def file_path(self, filename):
        return os.path.join(self.path, filename)
    def has_file(self, filename):
        return os.path.exists(self.file_path(filename))

class Project(object):
    def __init__(self, subs):
        self.subjects = [Subject(x) for x in subs]


if __name__=="__main__":
    descriptor='group_oversampled'
    if not TEST:
        try:
            test_subject = sys.argv[1]
        except IndexError:
            test_subject = None

    with open(SUBJECT_FILE, 'r') as f:
        subjects = [x for x in f.read().split('\n') if len(x) == 8]


    if not TEST and test_subject not in subjects:
        print("No test subject found, using all subjects...")
        test_subject = None

    if TEST:
        test_subject = subjects[2]
        subjects = subjects[:3]

    for clf in CLASSIFIERS:
        # for i, cval in enumerate([.0001,.001,.01,.1,1.,10.,100.,1000.]):
        for i, cval in enumerate([.1,1.,10.]):
            if cval > .0001 and 'elasticnet'==clf:
                break

            project = Project(subjects)
            rfe = SGDRFE(project, NIFTII, BEHAVIORAL, TRS,
                         test_subj=test_subject, lag=LAG, clftype=clf, cut=CUT,
                         C=cval, stop_threshold=STOP_THRESHOLD, descriptor=descriptor)
            rfe.run()

            test_sub_name = test_subject if test_subject is not None else 'all_subjects'
            niftii_name = '_'.join([test_sub_name, str(cval), descriptor, clf, NIFTII_OUT_NAME ])
            rfe.save_nii(savename=niftii_name)

            if TEST:
                break

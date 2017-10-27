import os
# import time
# import subprocess
# import pdb


SUBJECT_DIR = '/Users/span/projects/cuefmri/scans'
SUBJECTS  = ['zl150930', 'ps151001', 'dw151003', 'aa151010', 'al151016', 'jv151030', 'sr151031',
			 'vm151031', 'kl160122', 'ss160205', 'bp160213', 'cs160214', 'rp160205', 'ag151024', 
			 'si151120', 'tf151127', 'wr151127', 'ja151218', 
			 'wh160130']

REGRESSORS  = ['cue_vs_not', 'pic_vs_not', 'rate_vs_not', 'food_vs_neutral', 'alcodrug_vs_foodneutr', 'drug_vs_alco', 'rate_rt']
SIDES = ['axial', 'coronal','sagittal']

try:
    os.mkdir(os.path.join(SUBJECT_DIR, 'aggregate_plots'))
except:
    pass

for reg in REGRESSORS:
    if reg in os.listdir(SUBJECT_DIR):
        os.system('rm -rf ' + reg)

    try:
        os.mkdir(os.path.join(SUBJECT_DIR, 'aggregate_plots', reg))
    except:
        pass

    for side in SIDES:
        image_dir = os.path.join(SUBJECT_DIR, 'aggregate_plots', reg, side)
        try:
            os.mkdir(image_dir)
        except:
            pass
        image_name = reg + '_' + 'strip' + '_' + side + '.jpg'

        try:
            os.mkdir(images_dir)
        except:
            pass

        for subject in SUBJECTS:
            sp = (os.path.join(SUBJECT_DIR, subject))

            f = os.path.join(sp, 'strip_snapshots', image_name)
            new_image_name = subject + '.jpg'
            copy_command = 'cp ' + f + ' ' + os.path.join(image_dir, new_image_name)
            os.system(copy_command)

for reg in REGRESSORS:
    for side in SIDES:
        image_dir = os.path.join(SUBJECT_DIR, 'aggregate_plots', reg, side)
        new_image = reg + '_' + side + '.jpg'
        magick = 'convert -append ' + image_dir + '/* ' + new_image
        os.system(magick)
os.mkdir('master')
os.system('mv *.jpg master')

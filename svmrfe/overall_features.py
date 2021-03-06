import numpy as np
import nibabel as nib

dir = '/scratch/PI/knutson/cuesvm/svmrfe/relapse_masked/'

#subs = ['ag151024', 'al170316', 'as160317', 'at160601', 'cg160715', 'cm160510', 'gm160909', 'hp170601', 'ja151218', 'ja160416', 'jb161004', 'jc170501', 'jd170330', 'jf160703', 'jw170330', 'mr161024', 'nb160221', 'nc160905', 'rc161007', 'rf170610', 'rs160730', 'rv160413', 'se161021', 'si151120', 'tf151127', 'tj160529', 'wh160130', 'wr151127', 'zm160627']

subs = ['ag151024', 'al170316', 'as160317', 'at160601', 'cg160715', 'cm160510', 'gm160909', 'ja151218', 'ja160416', 'jd170330', 'jf160703', 'jw170330', 'mr161024', 'nb160221', 'nc160905', 'rc161007', 'rs160730', 'rv160413', 'se161021', 'si151120', 'tf151127', 'tj160529', 'wh160130', 'wr151127', 'zm160627']

##-------------------------------------------------------------------------------------------##

overall_feats = [1] * 768768  # 768768 total features

for sub in subs:
    coef = dir + sub + '_0.0001_relapse_elasticnet_cue_drug_relapse.nii.gz'

    x = nib.load(coef)

    betas = x = x.get_data()                                    # get all betas for current sub
    betas_long = np.reshape(betas, np.product(betas.shape))     # reshape betas to vector of all features for current sub

    surviving_feats = np.where(overall_feats==0)                 # find all features with beta > 0 in all previous subs
    print(surviving_feats)

    #print("long shape", betas_long.shape)
    #print(np.count_nonzero(betas_long))


    for f in surviving_feats:                                   # search for feat in current sub - if nonzero, add beta to overall_feats
        if betas_long[f] > 0:                                       # if not, seat feat in overall_feats to zero
            overall_feats[f] = overall_feats[f] + betas_long[f]
        else:
            overall_feats[f] = 0


print(np.count_nonzero(overall_feats))
overall_feats[np.where(overall_feats>0)] = overall_feats[np.where(overall_feats>0)] - 1     # get rid of original padded 1


          
reshaped = overall_feats.reshape(betas.shape)                   # reshape overall_feats back to original betas format



sample_img = nib.load('tt29.nii')                               # save back to nifti
affine = sample_img.affine.copy()
header = sample_img.header.copy()

header.set_data_dtype(np.float64)
assert(header.get_data_dtype()==np.float64)

print("Saving coefs as datatype", header.get_data_dtype())
i = nib.Nifti1Image(reshaped.astype(np.float64), affine, header)
nib.save(i, 'overall_features_relapse_masked_niftii.nii')

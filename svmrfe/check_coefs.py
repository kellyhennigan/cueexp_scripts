import numpy as np
import nibabel as nib

coef = '/home/span/lvta/cuesvm/svmrfe_032918/relapse_masked/si151120_0.0001_relapse_elasticnet_cue_drug_relapse.nii.gz'

x = nib.load(coef)

betas = x = x.get_data()

print("beta shape", betas.shape)

betas_long = np.reshape(betas, np.product(betas.shape))

print("long shape", betas_long.shape)

a = np.where(betas_long==0)
print(a)
print(np.where(betas_long>0))
print(np.count_nonzero(betas_long))

reshaped = betas_long.reshape(betas.shape)



sample_img = nib.load('tt29.nii')
affine = sample_img.affine.copy()
header = sample_img.header.copy()

header.set_data_dtype(np.float64)
assert(header.get_data_dtype()==np.float64)

print("Saving coefs as datatype", header.get_data_dtype())
i = nib.Nifti1Image(reshaped.astype(np.float64), affine, header)
nib.save(i, 'try_niftii.nii')

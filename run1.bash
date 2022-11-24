
# You must be in folder sa/ or st/
LOG_FILE=log_subjectA.err
touch LOG_FILE

echo "mrconvert dwi.nii.gz dwi_raw.mif -fslgrad dwi.bvec dwi.bval"
mrconvert dwi.nii.gz dwi_raw.mif -fslgrad dwi.bvec dwi.bval >> LOG_FILE

echo "dwidenoise dwi_raw.mif dwi_den.mif -noise noise.mif"
dwidenoise dwi_raw.mif dwi_den.mif -noise noise.mif >> LOG_FILE

echo "mrcalc dwi_raw.mif dwi_den.mif –subtract residual.mif"
mrcalc dwi_raw.mif dwi_den.mif –subtract residual.mif >> LOG_FILE

echo "mrdegibbs dwi_den.mif dwi_den_unr.mif –axes 0,1"
mrdegibbs dwi_den.mif dwi_den_unr.mif –axes 0,1 >> LOG_FILE

echo "mrcalc dwi_den.mif dwi_den_unr.mif –subtract residualUnringed.mif"
mrcalc dwi_den.mif dwi_den_unr.mif –subtract residualUnringed.mif >> LOG_FILE

echo "dwifslpreproc dwi_den_unr.mif dwi_den_unr_preproc.mif -rpe_none -pe_dir AP -eddy_options \"--slm=linear\""
dwifslpreproc dwi_den_unr.mif dwi_den_unr_preproc.mif -rpe_none -pe_dir AP -eddy_options "--slm=linear" >> LOG_FILE

echo "dwibiascorrect ants dwi_den_unr_preproc.mif dwi_den_unr_preproc_unbiased.mif -bias bias.mif"
dwibiascorrect ants dwi_den_unr_preproc.mif dwi_den_unr_preproc_unbiased.mif -bias bias.mif >> LOG_FILE

echo "dwi2mask dwi_den_unr_preproc_unbiased.mif mask_den_unr_preproc_unb.mif"
dwi2mask dwi_den_unr_preproc_unbiased.mif mask_den_unr_preproc_unb.mif >> LOG_FILE

echo "dwi2response dhollander dwi_den_unr_preproc_unbiased.mif wm.txt gm.txt csf.txt -voxels voxels.mif"
dwi2response dhollander dwi_den_unr_preproc_unbiased.mif wm.txt gm.txt csf.txt -voxels voxels.mif >> LOG_FILE

echo "dwi2fod msmt_csd dwi_den_unr_preproc_unbiased.mif -mask mask_den_unr_preproc_unb.mif wm.txt wmfod.mif gm.txt gmfod.mif csf.txt csffod.mif"
dwi2fod msmt_csd dwi_den_unr_preproc_unbiased.mif -mask mask_den_unr_preproc_unb.mif wm.txt wmfod.mif gm.txt gmfod.mif csf.txt csffod.mif >> LOG_FILE

echo "mtnormalise wmfod.mif wmfod_norm.mif gmfod.mif gmfod_norm.mif csffod.mif csffod_norm.mif -mask mask_den_unr_preproc_unb.mif"
mtnormalise wmfod.mif wmfod_norm.mif gmfod.mif gmfod_norm.mif csffod.mif csffod_norm.mif -mask mask_den_unr_preproc_unb.mif >> LOG_FILE

echo "dwiextract dwi_den_unr_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_preprocessed.mif -axis 3"
dwiextract dwi_den_unr_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_preprocessed.mif -axis 3 >> LOG_FILE

echo "mrconvert mean_b0_preprocessed.mif mean_b0_preprocessed.nii.gz"
mrconvert mean_b0_preprocessed.mif mean_b0_preprocessed.nii.gz >> LOG_FILE

echo "flirt -in mean_b0_preprocessed.nii.gz -ref ../T1_raw.nii.gz -dof 6 -omat diff2struct_fsl.mat"
flirt -in mean_b0_preprocessed.nii.gz -ref ../T1_raw.nii.gz -dof 6 -omat diff2struct_fsl.mat >> LOG_FILE

echo "transformconvert diff2struct_fsl.mat mean_b0_preprocessed.nii.gz ../T1_raw.mif flirt_import diff2struct_mrtrix.txt"
transformconvert diff2struct_fsl.mat mean_b0_preprocessed.nii.gz ../T1_raw.mif flirt_import diff2struct_mrtrix.txt >> LOG_FILE

echo "mrtransform ../T1_raw.mif -linear diff2struct_mrtrix.txt -inverse T1_coreg.mif"
mrtransform ../T1_raw.mif -linear diff2struct_mrtrix.txt -inverse T1_coreg.mif >> LOG_FILE
# You must be in folder sa/ or st/

CDMRI_PATH=/Users/aringuyen/Desktop/SeniorDesign/cdmri
subjectList=("D" "E" "F" "G" "H" "I" "K" "L" "M" "N" "O")
scannerList=("connectom" "prisma")
protocolList=("st" "sa")

for subject in "${subjectList[@]}"; do
    echo $folder

    for scanner in "${scannerList[@]}"; do
        for protocol in "${protocolList[@]}"; do
            SUBJECT_PATH_DIR=$CDMRI_PATH/$subject/$scanner/$protocol
            
            echo "\n>> cd $SUBJECT_PATH_DIR"
            cd $SUBJECT_PATH_DIR

            echo "\n---mrconvert dwi.nii.gz dwi_raw.mif -fslgrad dwi.bvec dwi.bval"
            mrconvert dwi.nii.gz dwi_raw.mif -fslgrad dwi.bvec dwi.bval 

            echo "\n---dwidenoise dwi_raw.mif dwi_den.mif -noise noise.mif"
            dwidenoise dwi_raw.mif dwi_den.mif -noise noise.mif 

            echo "\n---mrcalc dwi_raw.mif dwi_den.mif -subtract residual.mif"
            mrcalc dwi_raw.mif dwi_den.mif -subtract residual.mif 

            echo "\n---mrdegibbs dwi_den.mif dwi_den_unr.mif -axes 0,1"
            mrdegibbs dwi_den.mif dwi_den_unr.mif -axes 0,1

            echo "\n---mrcalc dwi_den.mif dwi_den_unr.mif -subtract residualUnringed.mif"
            mrcalc dwi_den.mif dwi_den_unr.mif -subtract residualUnringed.mif

            echo "\n---dwifslpreproc dwi_den_unr.mif dwi_den_unr_preproc.mif -rpe_none -pe_dir AP -eddy_options \"--slm=linear\""
            dwifslpreproc dwi_den_unr.mif dwi_den_unr_preproc.mif -rpe_none -pe_dir AP -eddy_options " --slm=linear" 

            DOCKER_PATH=9f7b08983942:/work/cdmri
            echo "\n---docker cp dwi_den_unr_preproc.mif $DOCKER_PATH/$subject/$scanner/$protocol"
            docker cp dwi_den_unr_preproc.mif 9f7b08983942:/work/cdmri/B/prisma/st

            # need to run in docker
            echo "\n---dwibiascorrect ants dwi_den_unr_preproc.mif dwi_den_unr_preproc_unbiased.mif -bias bias.mif"
            dwibiascorrect ants dwi_den_unr_preproc.mif dwi_den_unr_preproc_unbiased.mif -bias bias.mif 

            echo "\n---dwi2mask dwi_den_unr_preproc_unbiased.mif mask_den_unr_preproc_unb.mif"
            dwi2mask dwi_den_unr_preproc_unbiased.mif mask_den_unr_preproc_unb.mif 

            echo "\n---dwi2response dhollander dwi_den_unr_preproc_unbiased.mif wm.txt gm.txt csf.txt -voxels voxels.mif"
            dwi2response dhollander dwi_den_unr_preproc_unbiased.mif wm.txt gm.txt csf.txt -voxels voxels.mif 

            echo "\n---dwi2fod msmt_csd dwi_den_unr_preproc_unbiased.mif -mask mask_den_unr_preproc_unb.mif wm.txt wmfod.mif gm.txt gmfod.mif csf.txt csffod.mif"
            dwi2fod msmt_csd dwi_den_unr_preproc_unbiased.mif -mask mask_den_unr_preproc_unb.mif wm.txt wmfod.mif gm.txt gmfod.mif csf.txt csffod.mif 

            echo "\n---mtnormalise wmfod.mif wmfod_norm.mif gmfod.mif gmfod_norm.mif csffod.mif csffod_norm.mif -mask mask_den_unr_preproc_unb.mif"
            mtnormalise wmfod.mif wmfod_norm.mif gmfod.mif gmfod_norm.mif csffod.mif csffod_norm.mif -mask mask_den_unr_preproc_unb.mif 

            echo "\n---dwiextract dwi_den_unr_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_preprocessed.mif -axis 3"
            dwiextract dwi_den_unr_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_preprocessed.mif -axis 3 

            echo "\n---mrconvert mean_b0_preprocessed.mif mean_b0_preprocessed.nii.gz"
            mrconvert mean_b0_preprocessed.mif mean_b0_preprocessed.nii.gz 
            mrconvert ../T1_raw.mif ../T1_raw.nii.gz

            echo "\n---flirt -in mean_b0_preprocessed.nii.gz -ref ../T1_raw.nii.gz -dof 6 -omat diff2struct_fsl.mat"
            flirt -in mean_b0_preprocessed.nii.gz -ref ../T1_raw.nii.gz -dof 6 -omat diff2struct_fsl.mat 

            echo "\n---transformconvert diff2struct_fsl.mat mean_b0_preprocessed.nii.gz ../T1_raw.mif flirt_import diff2struct_mrtrix.txt"
            transformconvert diff2struct_fsl.mat mean_b0_preprocessed.nii.gz ../T1_raw.mif flirt_import diff2struct_mrtrix.txt 

            echo "\n---mrtransform ../T1_raw.mif -linear diff2struct_mrtrix.txt -inverse T1_coreg.mif"
            mrtransform ../T1_raw.mif -linear diff2struct_mrtrix.txt -inverse T1_coreg.mif 
        done
    done
done

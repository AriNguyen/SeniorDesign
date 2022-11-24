# Run this script for each connectome and prisma folder
PATH_TO_FOLDER=path
cd PATH_TO_FOLDER

LOG5tt_FILE=path
touch LOG5tt_FILE

echo "mrconvert mprage.nii.gz T1_raw.nii.gz"
mrconvert mprage.nii.gz T1_raw.nii.gz

echo "mrconvert T1_raw.nii.gz T1_raw.mif"
mrconvert T1_raw.nii.gz T1_raw.mif

echo "5ttgen fsl T1_raw.mif 5tt_nocoreg.mif"
5ttgen fsl T1_raw.mif 5tt_nocoreg.mif
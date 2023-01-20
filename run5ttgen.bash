# Run this script for each connectome and prisma folder

subjectList=("A" "B" "C" "D" "E" "F" "G" "H" "I" "K" "L" "M" "N" "O")
scannerList=("connectom" "prisma")

for subject in "${subjectList[@]}"; do
    for scanner in "${scannerList[@]}"; do

        SUBJECTS_PATH=/Users/aringuyen/Desktop/SeniorDesign/cdmri/$subject/$scanner
        echo "SUBJECTS_PATH=/Users/aringuyen/Desktop/SeniorDesign/cdmri/$subject/$scanner"

        echo "\n---cd $SUBJECTS_PATH"
        cd $SUBJECTS_PATH

        echo "mrconvert mprage.nii.gz T1_raw.nii.gz"
        mrconvert mprage.nii.gz T1_raw.nii.gz

        echo "mrconvert T1_raw.nii.gz T1_raw.mif"
        mrconvert T1_raw.nii.gz T1_raw.mif

        echo "5ttgen fsl T1_raw.mif 5tt_nocoreg.mif"
        5ttgen fsl T1_raw.mif 5tt_nocoreg.mif
    done
done

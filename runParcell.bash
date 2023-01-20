
CDMRI_PATH=/Users/aringuyen/Desktop/SeniorDesign/cdmri
# subjectList=("D" "E" "F" "G" "H" "I" "K" "L" "M" "N" "O")
# scannerList=("connectom" "prisma")

subjectList=("A" "B" "C" "D" "E" "F" "G" "H" "I" "K" "L" "M" "N" "O")
scannerList=("connectom" "prisma")

export FREESURFER_HOME=/Applications/freesurfer/7.3.2
source $FREESURFER_HOME/SetUpFreeSurfer.sh

for subject in "${subjectList[@]}"; do
    for scanner in "${scannerList[@]}"; do
        SUBJECTS_PATH=/Users/aringuyen/Desktop/SeniorDesign/cdmri/$subject/$scanner
        SUBJECT_NAME=brain$subject$scanner

        echo "SUBJECTS_PATH=/Users/aringuyen/Desktop/SeniorDesign/cdmri/$subject/$scanner"
        echo "SUBJECT_NAME=brain$subject$scanner"

        echo "\n---cd $SUBJECTS_PATH"
        cd $SUBJECTS_PATH

        echo "\n---recon-all -s $SUBJECT_NAME -i T1_raw.nii.gz -all"
        recon-all -s $SUBJECT_NAME -i T1_raw.nii.gz -all

        echo "\n---mri_surf2surf --hemi lh"
        mri_surf2surf --hemi lh --srcsubject fsaverage \
        --trgsubject $SUBJECT_NAME \
        --sval-annot /Users/aringuyen/Downloads/Parcellations/FreeSurfer5.3/fsaverage/label/lh.Schaefer2018_200Parcels_7Networks_order.annot \
        --tval $SUBJECTS_DIR/$SUBJECT_NAME/label/lh.Schaefer2018_200Parcels_7Networks_order.annot 

        echo "\n---mri_surf2surf --hemi rh"
        mri_surf2surf --hemi rh --srcsubject fsaverage \
        --trgsubject $SUBJECT_NAME \
        --sval-annot /Users/aringuyen/Downloads/Parcellations/FreeSurfer5.3/fsaverage/label/rh.Schaefer2018_200Parcels_7Networks_order.annot \
        --tval $SUBJECTS_DIR/$SUBJECT_NAME/label/rh.Schaefer2018_200Parcels_7Networks_order.annot 

        echo "\n---cd $SUBJECTS_PATH/sa/"
        cd $SUBJECTS_PATH/sa/

        echo "\n---mri_aparc2aseg --old-ribbon --s $SUBJECT_NAME --o schaefer2018_200.mgz --annot Schaefer2018_200Parcels_7Networks_order"
        mri_aparc2aseg --old-ribbon --s $SUBJECT_NAME --o schaefer2018_200.mgz --annot Schaefer2018_200Parcels_7Networks_order 

        echo "\n---mrconvert -datatype uint32 schaefer2018_200.mgz schaefer2018_200.mif"
        mrconvert -datatype uint32 schaefer2018_200.mgz schaefer2018_200.mif 

        echo "\n---labelconvert schaefer2018_200.mif /Users/aringuyen/Desktop/Parcellations/project_to_individual/Schaefer2018_200Parcels_7Networks_order_LUT.txt /Users/aringuyen/Desktop/Parcellations/MNI/freeview_lut/Schaefer2018_200Parcels_7Networks_order.txt schaefer2018_200_parcels_nocoreg.mif"
        labelconvert schaefer2018_200.mif /Users/aringuyen/Desktop/Parcellations/project_to_individual/Schaefer2018_200Parcels_7Networks_order_LUT.txt /Users/aringuyen/Desktop/Parcellations/MNI/freeview_lut/Schaefer2018_200Parcels_7Networks_order.txt schaefer2018_200_parcels_nocoreg.mif -force
    done
done
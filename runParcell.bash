export FREESURFER_HOME=/Applications/freesurfer/7.3.2
source $FREESURFER_HOME/SetUpFreeSurfer.sh

LOGPARCELL_FILE=logparcell_subjectA.err
touch LOGPARCELL_FILE

echo "recon-all -s brain -i T1_raw.nii.gz -all"
recon-all -s brain -i T1_raw.nii.gz -all >> LOGPARCELL_FILE

echo "mri_surf2surf --hemi lh"
mri_surf2surf --hemi lh \                
--srcsubject fsaverage \
--trgsubject brain \
--sval-annot /Users/aringuyen/Downloads/Parcellations/FreeSurfer5.3/fsaverage/label/lh.Schaefer2018_200Parcels_7Networks_order.annot \
--tval $SUBJECTS_DIR/brain/label/lh.Schaefer2018_200Parcels_7Networks_order.annot \
>> LOGPARCELL_FILE

echo "mri_surf2surf --hemi rh"
mri_surf2surf --hemi rh \                
--srcsubject fsaverage \
--trgsubject brain \
--sval-annot /Users/aringuyen/Downloads/Parcellations/FreeSurfer5.3/fsaverage/label/rh.Schaefer2018_200Parcels_7Networks_order.annot \
--tval $SUBJECTS_DIR/brain/label/rh.Schaefer2018_200Parcels_7Networks_order.annot \
>> LOGPARCELL_FILE

echo "mri_aparc2aseg --old-ribbon --s brain --o schaefer2018_200.mgz --annot Schaefer2018_200Parcels_7Networks_order"
mri_aparc2aseg --old-ribbon --s brain --o schaefer2018_200.mgz --annot Schaefer2018_200Parcels_7Networks_order >> LOGPARCELL_FILE

echo "mrconvert –datatype uint32 schaefer2018_200.mgz schaefer2018_200.mif"
mrconvert –datatype uint32 schaefer2018_200.mgz schaefer2018_200.mif >> LOGPARCELL_FILE

echo "labelconvert schaefer2018_200.mif $FREESURFER_HOME/FreeSurferColorLUT.txt /Users/aringuyen/Desktop/Parcellations/MNI/freeview_lut/Schaefer2018_200Parcels_17Networks_order.txt schaefer2018_200_parcels_nocoreg.mif"
labelconvert schaefer2018_200.mif $FREESURFER_HOME/FreeSurferColorLUT.txt /Users/aringuyen/Desktop/Parcellations/MNI/freeview_lut/Schaefer2018_200Parcels_17Networks_order.txt schaefer2018_200_parcels_nocoreg.mif >> LOGPARCELL_FILE
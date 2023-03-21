# A. CDMRI Processing Pipeline

Pipeline Overview:

- [1. Preprocessing .nii to .mif file format](#1-preprocessing-nii-to-mif-file-format)
- [2. Fiber orientation distribution](#2-fiber-orientation-distribution)
    - [2.1 Response function estimation](#21-response-function-estimation)
    - [2.2. Estimation of Fiber Orientation Distributions (FOD)](#22-estimation-of-fiber-orientation-distributions-fod)
    - [2.3. Intensity Normalization](#23-intensity-normalization)
- [3. Creating a whole-brain tractogram](#3-creating-a-whole-brain-tractogram)
    - [3.1. Preparing Anatomically Constrained Tractography (ACT)](#31-preparing-anatomically-constrained-tractography-act)
    - [3.2 Preparing a mask of streamline seeding](#32-preparing-a-mask-of-streamline-seeding)
- [4. Connectome construction](#4-connectome-construction)
- [5. Preparing a parcellation image for structural connectivity analysis](#5-preparing-a-parcellation-image-for-structural-connectivity-analysis)
    - [5.1 Convert the raw T1.mif image to nifti-format](#51-convert-the-raw-t1mif-image-to-nifti-format)
    - [5.2 Preprocess the T1 image in FreeSurfer](#52-preprocess-the-t1-image-in-freesurfer)
    - [5.3. Map the annotation files of the HCP MMP 1.0 atlas from fsaverage to you subject for both hemispheres](#53-map-the-annotation-files-of-the-schaefer2018_200parcels_7networks-atlas-from-fsaverage-to-you-subject-for-both-hemispheres)
    - [5.4 Map the HCP MMP 1.0 annotations onto the volumetric image and add subcortical segmentation. Convert the resulting file to .mif format](#54-map-the-schaefer2018_200parcels_7networks-annotations-onto-the-volumetric-image-and-add-freesurfer-specific-subcortical-segmentation)
    - [5.5. Replace the random integers of the hcpmmp1.mif file with integers](#55-replace-the-random-integers-of-the-schaefer2018_200mif-file-with-integers-that-start-at-1-and-increase-by-1)

## 1. Preprocessing .nii to .mif file format 
```console
mrconvert dwi.nii.gz dwi_den_unr_preproc_unbiased.mif -fslgrad dwi.bvec dwi.bval
```

```console
mrconvert mask.nii.gz mask.mif 
```

## 2. Fiber orientation distribution

### 2.1 Response function estimation

```console
dwi2response dhollander dwi_den_unr_preproc_unbiased.mif wm.txt gm.txt csf.txt -voxels voxels.mif 
```

<a name='c2w2.'></a>
### 2.2. Estimation of Fiber Orientation Distributions (FOD)
```console
dwi2fod msmt_csd dwi_den_unr_preproc_unbiased.mif -mask mask.mif wm.txt wmfod.mif gm.txt gmfod.mif csf.txt csffod.mif 
```

### 2.3. Intensity Normalization
```console
mtnormalise wmfod.mif wmfod_norm.mif gmfod.mif gmfod_norm.mif csffod.mif csffod_norm.mif -mask mask.mif 
```

## 3. Creating a whole-brain tractogram

### 3.1. Preparing Anatomically Constrained Tractography (ACT)

Run these commands again for new protocol

```console
dwiextract dwi_den_unr_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_preprocessed.mif -axis 3 

mrconvert mean_b0_preprocessed.mif mean_b0_preprocessed.nii.gz 
mrconvert ../T1_raw.mif ../T1_raw.nii.gz 

flirt -in mean_b0_preprocessed.nii.gz -ref ../T1_raw.nii.gz -dof 6 -omat diff2struct_fsl.mat

transformconvert diff2struct_fsl.mat mean_b0_preprocessed.nii.gz ../T1_raw.mif flirt_import diff2struct_mrtrix.txt 

mrtransform ../T1_raw.mif -linear diff2struct_mrtrix.txt -inverse T1_coreg.mif 

mrtransform schaefer2018_200_parcels_nocoreg.mif -linear diff2struct_mrtrix.txt -inverse -datatype uint32 schaefer2018_200_parcels_coreg.mif 
```

### 3.2 Preparing a mask of streamline seeding
```console
5tt2gmwmi ../5tt_nocoreg.mif gmwmSeed_coreg.mif 
```

### 3.2 Creating streamlines


Creating 10 million streamlines. This command will take hours to finish.

```console
tckgen -act ../5tt_nocoreg.mif -backtrack -seed_gmwmi gmwmSeed_coreg.mif -select 10000000 wmfod_norm.mif tracks_10mio.tck 
```


### 3.3 Reducing the number of streamlines
This command will take hours to finish.
```console
tcksift -act ../5tt_nocoreg.mif -term_number 1000000 tracks_10mio.tck wmfod_norm.mif sift_1mio.tck 
```

## 4. Connectome construction

```console
tck2connectome -symmetric -zero_diagonal -scale_invnodevol sift_1mio.tck schaefer2018_200_parcels_coreg.mif schaefer200.csv -out_assignment assignments_schaefer200.csv -force
```

## 5. Preparing a parcellation image for structural connectivity analysis

You need to install FreeSurfer

```console
export FREESURFER_HOME=/Applications/freesurfer/7.3.2
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

### 5.1 Convert the raw T1.mif image to nifti-format
```console
mrconvert T1_raw.mif T1_raw.nii.gz
```

### 5.2 Preprocess the T1 image in FreeSurfer
This commands take a few hours to run.
```console
recon-all -s brain -i T1_raw.nii.gz -all
```

### 5.3. Map the annotation files of the Schaefer2018_200Parcels_7Networks atlas from fsaverage to you subject for both hemispheres

Left hemisphere:

```console
mri_surf2surf --hemi lh \                
--srcsubject fsaverage \
--trgsubject brain \
--sval-annot /Users/aringuyen/Downloads/Parcellations/FreeSurfer5.3/fsaverage/label/lh.Schaefer2018_200Parcels_7Networks_order.annot \
--tval $SUBJECTS_DIR/brain/label/lh.Schaefer2018_200Parcels_7Networks_order.annot
```

Right hemisphere:

```console
mri_surf2surf --hemi rh \                
--srcsubject fsaverage \
--trgsubject brain \
--sval-annot /Users/aringuyen/Downloads/Parcellations/FreeSurfer5.3/fsaverage/label/rh.Schaefer2018_200Parcels_7Networks_order.annot \
--tval $SUBJECTS_DIR/brain/label/rh.Schaefer2018_200Parcels_7Networks_order.annot
```

### 5.4. Map the Schaefer2018_200Parcels_7Networks annotations onto the volumetric image and add (FreeSurfer-specific) subcortical segmentation. 

```console
mri_aparc2aseg --old-ribbon --s brain --o schaefer2018_200.mgz --annot Schaefer2018_200Parcels_7Networks_order


Convert the resulting file to .mif format (use datatype uint32, which is liked best by MRtrix).

mrconvert –datatype uint32 schaefer2018_200.mgz schaefer2018_200.mif
```

### 5.5. Replace the random integers of the schaefer2018_200.mif file with integers that start at 1 and increase by 1.

```console
labelconvert schaefer2018_200.mif Schaefer2018_200Parcels_7Networks_order_LUT.txt Schaefer2018_200Parcels_7Networks_order.txt schaefer2018_200_parcels_nocoreg.mif
```

# B. Visualize Connectome for subject A 

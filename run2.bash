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

            echo "\n---mrtransform ../5tt_nocoreg.mif -linear diff2struct_mrtrix.txt -inverse 5tt_coreg.mif"
            mrtransform ../5tt_nocoreg.mif -linear diff2struct_mrtrix.txt -inverse 5tt_coreg.mif 

            echo "\n---5tt2gmwmi 5tt_coreg.mif gmwmSeed_coreg.mif"
            5tt2gmwmi 5tt_coreg.mif gmwmSeed_coreg.mif 

            echo "\n---tckgen -act 5tt_coreg.mif -backtrack -seed_gmwmi gmwmSeed_coreg.mif -select 10000000 wmfod_norm.mif tracks_10mio.tck"
            tckgen -act 5tt_coreg.mif -backtrack -seed_gmwmi gmwmSeed_coreg.mif -select 10000000 wmfod_norm.mif tracks_10mio.tck 

            echo "\n---tcksift -act 5tt_coreg.mif -term_number 1000000 tracks_10mio.tck wmfod_norm.mif sift_1mio.tck"
            tcksift -act 5tt_coreg.mif -term_number 1000000 tracks_10mio.tck wmfod_norm.mif sift_1mio.tck 

            echo "\n---tckedit -include -0.6,-16.5,-16.0,3 sift_1mio.tck cst.tck"
            tckedit -include -0.6,-16.5,-16.0,3 sift_1mio.tck cst.tck 

            echo "\n---tck2connectome -symmetric -zero_diagonal -scale_invnodevol sift_1mio.tck schaefer2018_200_parcels_coreg.mif schaefer200.csv -out_assignment assignments_schaefer200.csv -force"
            tck2connectome -symmetric -zero_diagonal -scale_invnodevol sift_1mio.tck schaefer2018_200_parcels_coreg.mif schaefer200.csv -out_assignment assignments_schaefer200.csv -force
        done
    done
done

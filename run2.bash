
# You must be in folder sa/ or st/

# You need to run run5ttgen.bash and have 5tt_nocoreg.mif by this step

echo "mrtransform ../5tt_nocoreg.mif -linear diff2struct_mrtrix.txt -inverse 5tt_coreg.mif"
mrtransform ../5tt_nocoreg.mif -linear diff2struct_mrtrix.txt -inverse 5tt_coreg.mif >> LOG_FILE

echo "5tt2gmwmi 5tt_coreg.mif gmwmSeed_coreg.mif"
5tt2gmwmi 5tt_coreg.mif gmwmSeed_coreg.mif >> LOG_FILE

echo "tckgen -act 5tt_coreg.mif -backtrack -seed_gmwmi gmwmSeed_coreg.mif -select 10000000 wmfod_norm.mif tracks_10mio.tck"
tckgen -act 5tt_coreg.mif -backtrack -seed_gmwmi gmwmSeed_coreg.mif -select 10000000 wmfod_norm.mif tracks_10mio.tck >> LOG_FILE

echo "tcksift –act 5tt_coreg.mif –term_number 1000000 tracks_10mio.tck wmfod_norm.mif sift_1mio.tck"
tcksift –act 5tt_coreg.mif –term_number 1000000 tracks_10mio.tck wmfod_norm.mif sift_1mio.tck >> LOG_FILE

echo "tckedit –include -0.6,-16.5,-16.0,3 sift_1mio.tck cst.tck"
tckedit –include -0.6,-16.5,-16.0,3 sift_1mio.tck cst.tck >> LOG_FILE

echo "tck2connectome -symmetric -zero_diagonal -scale_invnodevol sift_1mio.tck schaefer2018_200_parcels_coreg.mif schaefer200.csv -out_assignment assignments_schaefer200.csv -force"
tck2connectome -symmetric -zero_diagonal -scale_invnodevol sift_1mio.tck schaefer2018_200_parcels_coreg.mif schaefer200.csv -out_assignment assignments_schaefer200.csv >> LOG_FILE


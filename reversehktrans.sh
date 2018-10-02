#!/bin/bash

subjectID=$1
subIDserver=WMT${subjectID:1:4}
fingerDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/
mni2simmat=${subIDserver}"_MNI_to_SIMNIBS.mat"
transmat=${subIDserver}"_SIMNIBS_to_MNI.mat"
transmatloc=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/${transmat}
matlab=/Applications/MATLAB_R2016a.app/bin/matlab

cd ${fingerDir}

${matlab} -nodisplay -nodesktop -r "niiflip,topX,quit"
fslcpgeom brain.nii hk_adj.nii
fslcpgeom brain.nii topXZ_subflip.nii
convert_xfm -omat ${transmat} -inverse ${mni2simmat}
flirt -in hk_adj.nii -ref /usr/local/fsl/data/standard/MNI152_T1_1mm_brain -out hkMNI.nii -init ${transmat} -applyxfm -interp trilinear	
flirt -in rzstat1.nii -ref /usr/local/fsl/data/standard/MNI152_T1_1mm_brain -out rzstatMNI.nii -init ${transmat} -applyxfm -interp trilinear	
flirt -in topXZ_subflip.nii -ref /usr/local/fsl/data/standard/MNI152_T1_1mm_brain -out topXZ_MNI.nii -init ${transmat} -applyxfm -interp trilinear
flirt -in topXE_subflip.nii -ref /usr/local/fsl/data/standard/MNI152_T1_1mm_brain -out topXE_MNI.nii -init ${transmat} -applyxfm -interp trilinear


echo Complete


#!/bin/bash

subjectID=$1
subIDserver=WMT${subjectID:1:4}
fingerDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/
transmat=${subIDserver}"_MNI_to_SIMNIBS.mat"
transmatloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/${transmat}
#transmatloc=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/${transmat}

cd ${fingerDir}

flirt -in MNI.nii.gz -ref brain.nii -out MTloc -omat ${transmatloc} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear
#flirt -in MNI.nii.gz -ref brain.nii -out MTloc -applyxfm -init ${transmat} -interp trilinear	

echo Complete


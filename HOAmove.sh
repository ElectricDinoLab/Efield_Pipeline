#!/bin/bash


subjectID=$1
subIDserver=WMT${subjectID:1:4}
transmat=${subIDserver}"_MNI_to_SIMNIBS.mat"
dlpfcfolder=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/dlpfc/

cd ${dlpfcfolder}
cp /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/hoa_04_wes.nii /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/dlpfc/
flirt -in hoa_04_wes.nii -ref brain.nii -out hoa_brain.nii -applyxfm -init ${transmat} -interp trilinear


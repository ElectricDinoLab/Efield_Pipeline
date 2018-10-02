#!/bin/bash

## Use: MNImove.sh subID zstatnumber

subid=$1
if [ ! -d /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/ ]; then
  echo Making FingerTap Output Directory.......
  mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/
  echo Complete
fi
# Copy the MNI template to the subject directory
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/MNI.nii.gz
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fingertap/MNI_orig.nii.gz

cd /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fs_${1}/mri/

mri_convert brain.mgz brain.nii
mri_convert aparc+aseg.mgz aparcaseg.nii

cp brain.nii ../../fingertap/
cp aparcaseg.nii ../../fingertap/

echo Complete

handknobmove.sh $1
handknobtransform.sh $1
#zstatmove.sh $1 $2

cd /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/
#rm MTsim

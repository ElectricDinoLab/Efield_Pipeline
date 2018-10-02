#!/bin/bash

## Use: movebrain.sh WMT#

subid=$1
folder1=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/fmriactivations/
subfol=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subid}/E-field/

# unzip brain and move it
cd ${subfol}
gunzip brain_reorient.nii.gz
cp brain_reorient.nii ${folder1}/${subid}.nii
gzip brain.nii

cd ${folder1}

echo Complete

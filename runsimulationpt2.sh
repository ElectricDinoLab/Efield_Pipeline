#!/bin/bash

## Preparation
EXPER=WMTMS.01

## 1st var = subject number
## 2nd var = dti (1 = yes, 0 = no)
## 3rd var = tkRAS x coordinates of target
## 4th var = tkRAS y coordinates of target
## 5th var = tkRAS z coordinates of target
## 6th var = modelnumb (DelayPar)
## 7th var = subject fmri folder (ex. 20170113_21672)
## 8th var = copenum (cope3)

subjectID=$1
dti=$2
modelnumb=$6
fmrifolder=$7
copenum=$8  # ex. cope2
fmrifolder2=${fmrifolder:1:5}"_Level2.gfeat" # change to 9 after done
copefolder=${copenum}".feat"

## Defining Various Directories
subjDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/
subsimDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/simnibs_sim/
skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
subsimOut=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
meshlabLoc=/Applications/meshlab.app/Contents/MacOS/meshlabserver
matlab=/Applications/MATLAB_R2016a.app/bin/matlab
subIDserver=WMT${subjectID:1:4}


## Move Files to Cabeza Server
echo "Moving files to server and running correlation"
cd ${subsimOut}
mkdir /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/
mkdir /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
cp *nii* /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/

## Copy zstat files
cp /Volumes/Cabeza/WMTMS.01/Analysis/CorrectTrials/${modelnumb}/${fmrifolder}/${fmrifolder2}/${copefolder}/stats/zstat1.nii.gz /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/


## FSL commands
transmat=${subIDserver}"_MNI_to_SIMNIBS.mat"
a="Efields_"${subIDserver}
b="Efields_"${subIDserver}".nii.gz"

cd /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
flirt -in /usr/local/fsl/data/standard/MNI152_T1_2mm_brain -ref brain.nii -out MNI_reg -omat ${transmat} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear
flirt -in zstat1.nii.gz -ref brain.nii -out ZSTAT -applyxfm -init ${transmat} -interp trilinear
gunzip *.gz
fslmerge -t ${a} E-*
fslmaths ${b} -Tmean mean_Efield
fslmaths mean_Efield -thr 0.4 EROI
gunzip EROI.nii.gz
cd /Volumes/Cabeza/WMTMS.01/Scripts/
${matlab} -nodisplay -nodesktop -r "correl_script('${subIDserver}'),quit" > /dev/null 2>&1

cd /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
gzip *nii

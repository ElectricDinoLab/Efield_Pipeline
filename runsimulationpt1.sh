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
fmrifolder2=${fmrifolder:9:5}"_Level2.gfeat"
copefolder=${copenum}".feat"

## Defining Various Directories
subjDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/
subsimDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/simnibs_sim/
skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
subsimOut=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
meshlabLoc=/Applications/meshlab.app/Contents/MacOS/meshlabserver
matlab=/Applications/MATLAB_R2016a.app/bin/matlab
subIDserver=WMT${subjectID:1:4}

## Checking if ROIanalysis directory exist, making them if not
if [ ! -d $subsimOut ]; then
  echo Making Subjects Output Directory.......
  mkdir $subsimOut
  echo Complete
fi

## Printing some stuff for fun
echo Preparing Simulation
echo Subject is ${subjectID}
echo Target is ${3} ${4} ${5}


# Creating Target Grid
echo Defining skin curvature
${meshlabLoc} -i ${skinloc}/skin.stl -o ${subsimOut}/skin.xyz -om vt vn > /dev/null 2>&1
echo Finished making skin.xyz...
echo Creating position list...
cd ${subsimOut}
${matlab} -nojvm -r "createsim('${subjectID}',[${3} ${4} ${5}],${dti}),quit" > /dev/null 2>&1
cd ${subjDir}

# Running Simulation
/Users/BSEL/simnibs_2.0.1//fem_efield/simnibs ${subsimOut}/simulation_${subjectID}.mat --fields JjEe


# Creating mask for simulation extraction
cd ${skinloc}
${matlab} -nodisplay -nodesktop -r "process_mask('${subjectID}'),quit" > /dev/null 2>&1

# Creating brain.nii for correlation
cd ${subjDir}/fs_${subjectID}/mri/
mri_convert brain.mgz brain.nii
cp brain.nii ${subsimOut}/

# Simulation Extraction
cd ${subsimDir}
for i in $(ls *merge.msh)
do
	declare b=${i:14:5}
	echo $b
	msh2nii --mesh=$i --mask=mask.nii --hdr=../${subjectID}_T1fs_conform.nii.gz --fields=eE --fn_out=$b > /dev/null 2>&1
done

mv *normE.nii.gz ../ROIanalysis
rm *E.nii.gz
rm *v.nii.gz
rm *J.nii.gz


# Move Files to Cabeza Server
cd ${subsimOut}
if [ ! -d /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/ ]; then
  echo Cant move files to Server.......
  echo skipped
fi
if [ -d /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/ ]; then
  echo Moving files to Server.......
  mkdir /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/
  mkdir /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
  cp *nii* /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
  echo Complete
fi



# Clean up files
#cd ${subsimDir}
#for i in $(ls *E-5-1*)
#do
#	mkdir VerificationFiles
#	cp $i VerificationFiles/
#done

#rm *elm_merge.msh
#rm *.geo
#rm *.pro

# Copy zstat files
cp /Volumes/Cabeza/WMTMS.01/Analysis/CorrectTrials/${modelnumb}/${fmrifolder}/${fmrifolder2}/${copefolder}/stats/zstat1.nii.gz /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/


# FSL commands
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

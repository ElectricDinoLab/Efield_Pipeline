#!/bin/bash

## Preparation
EXPER=WMTMS.01

subjectID=$1
target=$2
simDir=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/
subjDir=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subjectID}
subsimDir=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subjectID}/simulations
subsimOut=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subjectID}/E-field
meshlabLoc=/Applications/meshlab.app/Contents/MacOS/meshlabserver

## Checking if directories exist, making them if not
if [ ! -d $subjDir ]; then
  echo Making Subject Directory.......
  mkdir $subjDir
  echo Complete
fi

if [ ! -d $subsimDir ]; then
  echo Making Subjects Simulation Directory.......
  mkdir $subsimDir
  echo Complete
fi

if [ ! -d $subsimOut ]; then
  echo Making Subjects Output Directory.......
  mkdir $subsimOut
  echo Complete
fi

echo Preparing Simulation
echo Subject is ${subjectID}
echo Target is ${target}


## Creating Target Grid

echo Creating target Grid
echo Defining skin curvature
meshlabLoc -i ${subsimDir}/m2m_${subjectID}/skin.stl -o










## Simulation Extraction
for i in $(ls *merge.msh)
do
	declare b=${i:14:5}
	echo $b
	#msh2nii --mesh=$i --mask=mask.nii --hdr=../${subjectID}_T1fs_conform.nii.gz --fields=eE --fn_out=$b > /dev/null 2>&1
	msh2nii --mesh=$i --mask=mask.nii --hdr=../${subjectID}_T1fs_conform.nii.gz --fields=eE --fn_out=$b > /dev/null 2>&1
	
done

mv *normE.nii.gz ../ROIanalysis
rm *E.nii.gz
rm *v.nii.gz
rm *J.nii.gz

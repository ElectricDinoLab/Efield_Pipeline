#!/bin/bash

# usage:
# calcintensity.sh S206 22249 cope3
subid=$1
subjectID=$1
serverID=$2
interaction=$3
skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
mtsimloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/MTsim/
simulationloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/simnibs_sim/
dosingsimloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${subid}/DosingSim/
dosingdataloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/
parietalfmriloc=/Volumes/Cabeza/WMTMS.01/Analysis/TargetingModels/Interaction/*${serverID}/*Level2.gfeat/${interaction}.feat/stats/
#parietalfmriloc=/Volumes/Cabeza/WMTMS.01/Analysis/CAC_ParametricSlopes/DelayParModels/separate_models/*${serverID}/*Level2.gfeat/${interaction}.feat/stats/
parietalmaskloc=/Volumes/Cabeza/WMTMS.01/Analysis/CAC_ParametricSlopes/
matlab=/Applications/MATLAB_R2016a.app/bin/matlab
transmat=${subid}"_MNI_to_SIMNIBS.mat"
transmatloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/${transmat}


## Making Directories

if [ ! -d /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData ]; then
  echo Making Dosing Output Directory.......
  mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim
  mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData
  echo Complete
fi


## Moving Files into calculation Directory
echo Moving brain scan
# Brain and aparcaseg
cd /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fs_${1}/mri/
mri_convert brain.mgz brain.nii
mri_convert aparc+aseg.mgz aparcaseg.nii
cp brain.nii ../../DosingSim/DosingData/
cp aparcaseg.nii ../../DosingSim/DosingData/
## Creating masks for simulation extraction
cd ${skinloc}
${matlab} -nodisplay -nodesktop -r "process_mask('${subjectID}'),quit"
cp ${parietalmaskloc}/constrained_parietal_mask_FINAL.nii.gz ${dosingdataloc}/parietalmask_MNI.nii.gz


# fMRI activation
echo Moving zstat and transforming to individual space
cd ${dosingdataloc}
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/MNI.nii.gz
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/MNI_orig.nii.gz
cd ${parietalfmriloc}
cp zstat1.nii* ${dosingdataloc}/zstat_MNI.nii.gz
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/zstat_${subid}.nii.gz ]; then
  cd ${dosingdataloc}
  flirt -in MNI.nii.gz -ref brain.nii -out MNI_to_${subid} -omat ${transmatloc} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear
  flirt -in zstat_MNI.nii.gz -ref brain.nii -out zstat_${subid}.nii.gz -applyxfm -init ${transmat} -interp trilinear
fi
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/parietalmask_${subid}.nii.gz ]; then
  cd ${dosingdataloc}
  flirt -in parietalmask_MNI.nii.gz -ref brain.nii -out parietalmask_${subid}.nii.gz -applyxfm -init ${transmat} -interp trilinear
fi

# extract parietalsim
echo Extracting Parietal Efield
cd ${dosingsimloc}
cp mask.nii ${simulationloc}/mask.nii
cd ${simulationloc}

pwd
for i in $(ls *merge.msh)
do
  declare b=${i:14:3}
  echo b
	msh2nii --mesh=$i --mask=mask.nii --hdr=../${subjectID}_T1fs_conform.nii.gz --fields=eE --fn_out=$b > /dev/null 2>&1
done

cp *normE* ${dosingsimloc}

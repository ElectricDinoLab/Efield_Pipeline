#!/bin/bash

## Preparation
EXPER=WMTMS.01

## usage = rundosingsim.sh S258 1 -37.89 -62.47 18.69 23041 cope2 1.1
## 1st var = subject number
## 2nd var = dti (1 = yes, 0 = no)
## 3rd var = RAS x coordinates of target
## 4th var = RAS y coordinates of target
## 5th var = RAS z coordinates of target
## 6th var = serverid 22142
## 7th var = copenum (cope3)
## 8th var = hairdepth (3.2)

subjectID=$1
dti=$2
serverID=$6
copenum=$7  # ex. cope2
hairdepth=$8
#fmrifolder2=${fmrifolder:9:5}"_Level2.gfeat"
copefolder=${copenum}".feat"

## Defining Various Directories
subjDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/
subsimDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/simnibs_sim/
skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
subsimOut=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
meshlabLoc=/Applications/meshlab.app/Contents/MacOS/meshlabserver
matlab=/Applications/MATLAB_R2016a.app/bin/matlab
subIDserver=WMT${subjectID:1:4}


simulationloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/simnibs_sim/
dosingsimloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${subjectID}/DosingSim/
dosingdataloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/
parietalfmriloc=/Volumes/Cabeza/WMTMS.01/Analysis/TargetingModels/Interaction/*${serverID}/*Level2.gfeat/${copenum}.feat/stats/
#parietalfmriloc=/Volumes/Cabeza/WMTMS.01/Analysis/CAC_ParametricSlopes/DelayParModels/separate_models/*${serverID}/*Level2.gfeat/${interaction}.feat/stats/
parietalmaskloc=/Volumes/Cabeza/WMTMS.01/Analysis/CAC_ParametricSlopes/
transmat=${subjectID}"_MNI_to_SIMNIBS.mat"
transmatloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/${transmat}

if [ ! -d $subjDir ]; then
  echo Making Subject Directory.......
  mkdir $subjDir
  echo Complete
fi

if [ ! -d $subsimDir ]; then
  echo Making Simnibs Directory.......
  mkdir $subsimDir
  echo Complete
fi

if [ ! -d /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData ]; then
  echo Making Dosing Output Directory.......
  mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/
  mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData
  echo Complete
fi

rm -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/log.txt

if [ ! -f ${subjDir}/${subjectID}.msh ]; then
  echo Making Subject Mesh.......
  mkdir ${subjDir}/scans
  #TODO: check if the cabeza server is accessable
  cp /Volumes/Cabeza/WMTMS.01/Data/Anat/*${serverID}/*00?.nii.gz ${subjDir}/scans/
  cp /Volumes/Cabeza/WMTMS.01/Data/Anat/*${serverID}/*01?.nii.gz ${subjDir}/scans/
  cd ${subjDir}
  mri2mesh --all ${subjectID} scans/*_00?.nii.gz
  echo " Meshing completed!"
fi
if [ ${dti} -eq 1 ]; then
  if [ ! -f ${subjDir}/d2c_${subjectID}/CTI_vn_tensor.nii.gz ]; then
    if [ -f ${subjDir}/scans/*_01?.nii.gz ]; then
    cd ${subjDir}
    cp ../bvals.txt scans/bvals.txt
    cp ../bvecs.txt scans/bvecs.txt
    dwi2cond --all ${subjectID} scans/*01?.nii.gz scans/bvals.txt scans/bvecs.txt
    echo "DTI completed!"
    else
      echo "DTI could not be found locally (or copied from server)." >> ${subjDir}/log.txt
      cat ${subjDir}/log.txt
      exit 1;
    fi
  fi
fi


cd ${subjDir}/fs_${1}/mri
mri_convert brain.mgz brain.nii
mri_convert aparc+aseg.mgz aparcaseg.nii
cp brain.nii ../../DosingSim/DosingData/
cp aparcaseg.nii ../../DosingSim/DosingData/

## Creating mask for simulation extraction
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${subjectID}/simnibs_sim/mask.nii ]; then
  cd ${skinloc}
  ${matlab} -nodisplay -nodesktop -r "process_mask('${subjectID}'),quit"
fi

if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fs_${1}/mri/brain.nii ]; then
  echo Converting Brain Scan.......
  cd /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/fs_${1}/mri/
  mri_convert brain.mgz brain.nii
  echo Complete
fi

# fMRI activation
echo Moving zstat and transforming to individual space
cd ${dosingdataloc}
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/MNI.nii.gz
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/MNI_orig.nii.gz
cd ${parietalfmriloc}
cp zstat1.nii* ${dosingdataloc}/zstat_MNI.nii.gz
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/zstat_${subjectID}.nii.gz ]; then
  cd ${dosingdataloc}
  flirt -in MNI.nii.gz -ref brain.nii -out MNI_to_${subjectID} -omat ${transmatloc} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear
  flirt -in zstat_MNI.nii.gz -ref brain.nii -out zstat_${subjectID}.nii.gz -applyxfm -init ${transmat} -interp trilinear
fi
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/parietalmask_${subjectID}.nii.gz ]; then
  cd ${dosingdataloc}
  cp ${parietalmaskloc}/constrained_parietal_mask_FINAL.nii.gz ${dosingdataloc}/parietalmask_MNI.nii.gz
  flirt -in parietalmask_MNI.nii.gz -ref brain.nii -out parietalmask_${subjectID}.nii.gz -applyxfm -init ${transmat} -interp trilinear
fi

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

## Creating Target Grid
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${subjectID}/ROIanalysis/simulation_${subjectID}.mat ]; then
  cd ${subsimOut}
  ${matlab} -nodisplay -nodesktop -r "tkreg_target('${subjectID}',[${3} ${4} ${5}]),quit"
  echo Defining skin curvature
  ${meshlabLoc} -i ${skinloc}/skin.stl -o ${subsimOut}/skin.xyz -om vt vn > /dev/null 2>&1
  ${meshlabLoc} -i ${skinloc}/gm.stl -o ${subsimOut}/gm.xyz -om vt vn > /dev/null 2>&1
  echo Finished making skin.xyz...
  echo Creating position list...
  cd ${subsimOut}
  ${matlab} -nojvm -r "createsimv2('${subjectID}',${dti},${8}),quit"
  cd ${subjDir}
fi

# Running Simulation
/Users/BSEL/simnibs_2.0.1//fem_efield/simnibs ${subsimOut}/simulation_${subjectID}.mat --fields JjEe

if ls ${subsimDir}/*_elm_merge.msh | wc -l; then
  echo "Solutions ready (*.msh) for interpolation (*.nii.gz)."
else
  echo "No simulation results (meshes) could found." >> ${subjDir}/log.txt
  cat ${subjDir}/log.txt
  exit 1;
fi

## Simulation Extraction
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/000_normE.nii.gz ]; then
  cd ${subsimDir}
  for i in $(ls *merge.msh)
  do
  	declare b=${i:14:3}
    echo $b
  	msh2nii --mesh=$i --mask=mask.nii --hdr=../${subjectID}_T1fs_conform.nii.gz --fields=JjeE --fn_out=$b > /dev/null 2>&1
  done

  cp *normE* ${dosingsimloc}
  rm *E.nii.gz
  rm *v.nii.gz
  rm *J.nii.gz
fi

if ls ${dosingsimloc}/*_normE.nii.gz | wc -l; then
## Move Files to Cabeza Server
 if [ ! -d /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/ ]; then
   cd ${dosingsimloc}
   mkdir /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/
   mkdir /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
   cp *nii* /Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subIDserver}/E-field/
 fi
else
  echo "Efield magnitude files (*_normE.nii.gz, interpolated from tet mesh onto grid) could not be found." >> ${subjDir}/log.txt
  cat ${subjDir}/log.txt
  exit 1;
fi
# Run calculation script
#cd ${dosingsimloc}
#gunzip *nii*
#cd ${dosingdataloc}
#gunzip *${subjectID}.nii.gz
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/intensity.txt ]; then
  ${matlab} -nodisplay -nodesktop -r "calculateintensity('${subjectID}',${8}),quit"
fi

if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/DosingSim/DosingData/intensity.txt ]; then
  echo " file 'intensity.txt' not found." >> ${subjDir}/log.txt
fi
if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis/angle.txt ]; then
  echo "file 'angle.txt' not found." >> ${subjDir}/log.txt
fi

if [ ! -f /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}/skin.stl ]; then
  echo "file 'skin.stl' not found." >> ${subjDir}/log.txt
fi

if [ -f  /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/log.txt ]; then
  cat ${subjDir}/log.txt
fi

#cd ${dosingsimloc}
#gzip *nii
#cd ${dosingdataloc}
#gzip *nii

#python /Users/BSEL/Desktop/WMT+TMS_Subjects/Scripts/email_send_duke.py

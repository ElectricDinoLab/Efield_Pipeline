#!/bin/bash

subid=$1
subjectID=$1
skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
mtsimloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/MTsim/
matlab=/Applications/MATLAB_R2016a.app/bin/matlab

cd ${skinloc}
echo Making mask
${matlab} -nodisplay -nodesktop -r "process_mask('${subjectID}'),quit"  > /dev/null 2>&1
echo Complete


cd ${mtsimloc}

for i in $(ls *merge.msh)
do
	echo Extracting MTefield
	msh2nii --mesh=$i --mask=mask.nii --hdr=../${subjectID}_T1fs_conform.nii.gz --fields=eE --fn_out='MTefield' > /dev/null 2>&1
done

echo Moving fields

cp MTefield_normE.nii.gz ../fingertap/

echo Complete

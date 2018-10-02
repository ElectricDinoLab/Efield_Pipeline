#!/bin/bash
EXPER=WMTMS.01

subjectID=$1
echo $subjectID
skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
subsimDir=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/simnibs_sim/
matlab=/Applications/MATLAB_R2016a.app/bin/matlab

cd ${skinloc}
${matlab} -nodisplay -nodesktop -r "process_mask('${subjectID}'),quit"

cd ${subsimDir}
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
